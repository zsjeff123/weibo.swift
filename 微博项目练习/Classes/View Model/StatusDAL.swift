//
//  StatusDAL.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/17.
//

import Foundation

//最大缓存时间
private let maxCacheDateTime: TimeInterval = 60//7 * 24 * 60 * 60

//数据访问层
//目标：专门负责处理本地SQLite和网络数据
class StatusDAL{
    
    
        //清理缓存的工作，千万不要交给用户
        //一定要定期清理数据库的缓存
        //一般不会把 图片/音频/视频 放到数据库中，占用磁盘空间大
    //数据库删除数据后，不会变小
    
       // 清理‘早于过期日期’的缓存数据
       class func clearDataCache() {
           //1.准备日期
           let date = Date(timeIntervalSinceNow: -maxCacheDateTime)
           // 日期格式转换
           let df = DateFormatter()
           // 指定区域 - 在模拟器不需要，在真机需要
           df.locale = Locale(identifier: "en_US_POSIX")
           //指定日期格式
           df.dateFormat = "yyyy-MM-dd HH:mm:ss"
           //获取日期结果
           let dateString = df.string(from: date)
           
           //2.执行SQL
           //提示：开发调试 删除SQL的时候，一定先写SELECT* ，确认无误之后，再转换成DELETE
           let sql = "DELETE FROM T_Status WHERE createTime < ?;"
           SQLiteManager.sharedManager.queue.inDatabase { db in
               if db.executeUpdate(sql, withArgumentsIn: [dateString]){
                   print("删除了\(db.changes) 条缓存数据")
               }
           }
       }
    
    
    //加载微博数据
    class func loadStatus(since_id: Int,max_id: Int,completion: @escaping(_ array:[[String:Any]]?) -> ()){
        
        //1.检查本地是否存在缓存数据
         let array = checkChacheData(since_id: since_id, max_id: max_id)
        
        //2.如果有，返回缓存数据
        if array!.count > 0{
            print("查询到缓存数据")
            //通知调用方 array
            completion(array!)
            
            return
        }
        
        
        //3.如果没有，加载网络数据
        print("加载网络数据")
        NetworkTools.sharedTools.loadStatus (since_id: since_id, max_id: max_id){ result, error in
            
            
            if error != nil{
                print("出错了")
                
                completion(nil)
                return
            }
            //判断result的数据结构是否正确
            guard let result = result as? [String: Any],
                  let array = result["statuses"] as? [[String: Any]]
            else {
                print("数据格式错误")
                
                completion(nil)
                return
            }
            //4.将网络返回的数据，保存到本地数据库，以便后续使用
            //----缓存网络数据----
            StatusDAL.saveCacheData(array: array)
            
            //5.通过闭包返回网络数据
            completion(array)
            
        }
        
        
        
    }
    
    //目标：检查本地数据库中，是否存在需要的数据
    //参数：下拉/上拉
    class func checkChacheData(since_id: Int,max_id: Int) -> [[String:Any]]? {
        
        print("检查本地数据\(since_id) \(max_id)")
        
        //0.用户id
        guard let userid = UserAccountViewModel.sharedUserAccount.account?.uid else{
            print("用户没有登录")
            return nil
        }
        
        //1.准备SQL
        //如果SQL比较复杂，提前测试SQL能够正常执行
        var sql = "SELECT statusid, status, userid FROM T_Status \n"
        sql += "WHERE userid = \(userid) \n"
        
        if since_id > 0{     //下拉刷新
            sql += "     AND statusid > \(since_id) \n"
        }else if max_id > 0 {      //上拉刷新
            sql += "     AND statusid > \(max_id) \n"
        }
        
        sql += "ORDER BY statusid DESC LIMIT 20;"
        
        print("查询数据SQL -> " + sql)
        
       //2.执行SQL -> 返回结果集合
       let array1 = SQLiteManager.sharedManager.execRecordSet(sql: sql)
        
      //  print(array1)
        
        
        //3.遍历数组 -> dict["status"] json反序列化(二进制变文字)
        
       var arrayM = [[String: Any]]()
        for dict in array1 {
            let jsonData = dict["status"] as! Data
            // 反序列化 -> 一条完整微博数据字典
            let result = try!JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
                    // 添加到数组
                    arrayM.append(result)
            
                }
            
        //返回结果 - 如果没有查询到数据，会返回一个空的数组
      return arrayM
       
    }
    
    //目标：将网络返回的数据，保存到本地数据库
    //参数：网络数据--网络返回的字典数组
    //对现有函数不做大的改动，找到合适的切入点，尽快测试
    //数据库开发，难点在SQL的编写
    //调用数据库方法-->如果是插入数据，应该使用事务！！
    class func saveCacheData(array: [[String:Any]]){
        
        //print("网络数据\(array)")
        
        //0.用户id
        guard let userid = UserAccountViewModel.sharedUserAccount.account?.uid else{
            print("用户没有登录")
            return
        }
        
        //1.准备SQL
        //参数：1.微博id--通过字典获取
        //2.微博json--字典序列化
        //3.userid---登录的用户
        let sql = "INSERT OR REPLACE INTO T_Status (statusid, status, userid) VALUES (?,?,?);"
        
        //2.遍历数组 - 如果不能确认数据插入消耗的时间，可以在实际开发中，写测试代码
        SQLiteManager.sharedManager.queue.inTransaction { db, rollback in
            for dict in array{
                //1>微博id
                let statusid = dict["id"] as! Int
                //2>序列化字典 -> 二进制数据
                let json = try!JSONSerialization.data(withJSONObject: dict,options: [])
                //3>插入数据
                if !db.executeUpdate(sql, withArgumentsIn:  [statusid,json,userid]){
                    print("插入数据失败")
                    //回滚
                    rollback.pointee = true
                    //break
                    break
                }
            }
        }
        print("数据插入完成")
        
    }
}
