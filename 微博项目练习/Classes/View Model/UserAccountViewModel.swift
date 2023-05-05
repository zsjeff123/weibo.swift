//
//  UserAccountViewModel.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/29.
//

//View Model的重要作用：封装网络方法

import Foundation

///用户账户视图模型---没有父类,不要继承
/*
 模型通常继承自NSObject -->可以使用KVC设置属性，简化对象构造
 如果没有父类，所有的内容，都要从头创建，量级更轻
 
 视图模型的作用：封装‘业务逻辑’，不是用来存储数据的，通常没有复杂的属性
 */
class UserAccountViewModel{
    ///单例 --- 解决避免重复从沙盒加载“归档”文件，让access_token便于被访问
    static let sharedUserAccount = UserAccountViewModel()
    
    ///用户模型
    var account: UserAccount?
    
    ///返回有效的token
    var accseeToken: String?{
        //如果token没有过期，返回account中的token属性(access_token)(计算型属性)
        if !isExpired{
            return account?.access_token
        }
        return nil
    }
    
    //用户登录标记
    var userLogin : Bool{
        //1.如果token有值，则说明登录成功
        //2.如果没有过期，则说明登录有效
        return account?.access_token != nil && !isExpired
    }
    
    //用户头像URL
    var avatarURL: NSURL{
        return NSURL(string: account?.avatar_large ?? "")!
    }
    
    //构造函数
    //不用override
    //归档保存的路径--计算型属性（类似有返回值的函数，可以让调用的时候，语义会更加清晰）
   private var accountPath: String{
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        
        return (path as NSString).appendingPathComponent("account.plist")
        
    }
    //判断账户是否过期
    //计算型属性
    private var isExpired:Bool{
        //如果account为nil,不会调用后面的属性，后面的比较也不会继续
        //判断用户账户过期日期与当前系统日期‘进行比较’
        //orderedDescending降序
        //可以自己改写日期，测试逻辑是否正确，创建日期的时候，如果给定为负数，返回比当前时间早的日期
        if account?.expiresData?.compare(NSDate() as Date) == ComparisonResult.orderedDescending{
            //代码执行到此，一定进行过比较
            return false
        }
        //如果过期返回true
        return true
    }
    //加载归档保存的用户信息
    //构造函数 --私有化->要求外部只能通过单例常量访问，而不能（）实例化
       private init(){
            
            //从沙盒解档数据，恢复当前数据--磁盘读写的速度最慢，不如内存读写效率高--改用单例来写static。。。（在前面）
            account = NSKeyedUnarchiver.unarchiveObject(withFile: accountPath)as? UserAccount
            //判断归档的数据token是否过期
            if isExpired{
                print("已经过期")
                //如果过期，则清空解档的数据
                account = nil}
            print(account as Any)
        }
        
    }
//MARK: - 用户账户相关的网络方法
/*
 代码重构的方法：
 1.新方法
 2.粘贴代码
 3.根据上下文调整参数和返回值
 4.移动其他‘子’方法
 */
extension UserAccountViewModel{
    
    //completion---完成回调（是否成功）
    //code---授权码
    func loadAccessToken(code: String,completion:@escaping(_ isSuccessed: Bool)->()){
    //4.加载accessToken
        NetworkTools.sharedTools.loadAccessToken(code: code) { result, error in
            
            //1>判断错误
            if error != nil{
                print("出错了")
                //失败的回调
                completion(false)
                return
            }
            //2>输出结果,在swift中任何AnyObject在使用前，都必须转换类型 ->as ?/! 类型
            //创建账户对象 - 保存在self.account属性中，不用重新设置account
            print(result as Any)
            self.account = UserAccount(dict: result as! [String:AnyObject])
            //调用函数
            self.loadUserInfo(account: self.account!, completion: completion)
             }
        }
        
        
        //调用用户信息的函数(扩展定义)
        private func loadUserInfo(account: UserAccount,completion:@escaping(_ isSuccessed: Bool)->()){
            NetworkTools.sharedTools.loadUserInfo(uid: account.uid! ) { result, error in
                
                if error != nil{
                    print("加载用户出错")
                    //失败的回调
                    completion(false)
                    return
                }
                //作了两个判断1.result一定有内容2.一定是字典
                //提示：如果使用guard let as/if let 统统使用？
                guard let dict = result as? [String:Any] else{
                    print("格式错误")
                    //失败的回调
                    completion(false)
                    return
                }
                //dict一定是一个字典
                //将用户信息保存
                account.screen_name = dict["screen_name"] as? String
                account.avatar_large = dict["avatar_large"] as? String
                print(account)
                
                //保存当前对象方法调用--会调用encode(with coder: NSCoder) 方法
                NSKeyedArchiver.archiveRootObject(account, toFile: self.accountPath)
                print(self.accountPath)
                //需要完成回调！！！
                completion(true)
            }
            
        }
    }

