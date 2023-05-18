//
//  SQLiteManager.swift
//  FMDB演练
//
//  Created by 云动家 on 2023/5/16.
//

import Foundation


//数据库名称 - 关于数据名称 readme.db
private let dbName = "readme2.db"

class SQLiteManager{
    
    
    //单例
    static let sharedManager = SQLiteManager()
    
    //全局数据库操作队列
    let queue: FMDatabaseQueue
    
     init(){
        
        //0.数据库路径--全路径（可读可写）
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        path = (path as NSString).appendingPathComponent(dbName)
        
        print("数据库路径" + path)
        
        //1.打开数据库队列
        //如果数据库不存在，会建立数据库，然后，再创建队列
        //如果数据库存在，会直接创建队列并打开数据库
        queue = FMDatabaseQueue(path: path)!
        
        createTable()
    }
    //执行SQL返回字典数组
    //sql:SQL   return: 字典数组
    func execRecordSet(sql:String) -> [[String:Any]]{
        //定义结果---字典数组
        var result = [[String:Any]]()
        
        //"同步"执行SQL查询 - 默认在主线程上执行
        //同步没有开线程的能力
        SQLiteManager.sharedManager.queue.inDatabase { db in
            guard let rs =  db.executeQuery(sql, withArgumentsIn: []) else {
                print("没有结果")
                return
            }
            
            //逐行遍历所有的数据结构,next 表示还有下一行
            while rs.next() {
                //1.列数
                let colCount = rs.columnCount
               // print("列数\(colCount)")
                //创建字典
                var dict = [String:Any]()
                
                //2.遍历每一列
                for col in 0..<colCount{
                    //1>列名
                    let name = rs.columnName(for: col)
                    //2>值
                    let obj = rs.object(forColumnIndex: col)
                    
                  //  print("列数\(String(describing: name)) \(String(describing: obj))")
                    
                    //3>设置字典
                    dict[name!] = obj
                }
                //将字典插入数组
                result.append(dict)
            }
         //   print(result)
        }
        //返回结果
        return result
    }
    
    
     func createTable(){
        
        //1.从bundle中加载sql文件(bundle路径只读，创建应用程序时，准备的素材)
        //取路径
        let path = Bundle.main.path(forResource: "db.sql", ofType: nil)!
        //读取SQL字符串
        let sql = try!String(contentsOfFile: path)
       
        //2.执行SQL
        //executeUpdate单条添加
        //executeStatements多条添加--最好选择
        queue.inDatabase { db in
            
            if db.executeStatements(sql){
                print("创表成功")
            }else{
                print("创表失败")
            }
                
                
           
        }
    }
    
}
