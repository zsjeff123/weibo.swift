//
//  UserAccount.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/28.
//

import UIKit

///用户账号模型
///要遵循NSCoding协议才可调用encode(with coder: NSCoder) 方法
class UserAccount: NSObject,NSCoding {
   
    

    //用户授权的唯一票据，用于调用微博的开放接口
     var access_token : String?
    
    //access_token 的生命周期，单位是秒数 
    //一旦从服务器获得过期的时间，立刻计算准确的时间
    var expires_in: TimeInterval = 0 {
        didSet {
            expiresData = NSDate(timeIntervalSinceNow: expires_in)
        }
    }
    /*var expires_in : TimeInterval = 0 {
        didSet{
            expiresData = NSData(timeIntervalSince(expires_in))
        }
    }*/
     ///过期日期
    var expiresData : NSDate?
    
    //授权用户的UID，本字段只是为了方便开发者，减少一次 user/show 接口调用而返回的，第三方应用不能用此字段作为用户登录状态的识别，只有 access_token 才是用户授权的唯一票据。
     var uid : String?
    
    //用户昵称
    var screen_name : String?
    //用户头像地址（大图），180×180像素
    var avatar_large : String?
    
    
    //字典转模型
    init(dict:[String:Any]){
        super.init()
        
       setValuesForKeys(dict)
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        // 处理未定义的属性
                switch key {
                case "access_token":
                    access_token = value as? String
                case "expires_in":
                    expires_in = (value as? Double)!
                case "uid":
                    uid = value as? String
                default: break 
                    //debugPrint("Undefined key: \(key)")
                }
    }
    //取到信息变成数组
    override var description: String{
        
        let dict = ["access_token": access_token as Any,
                            "expires_in": expires_in as Any,
                            "uid": uid as Any,
                    "expiresData":expiresData as Any,
                    "screen_name":screen_name as Any,
                    "avatar_large":avatar_large as Any]
                return "\(dict)"
        /*let keys = ["access_token","expires_in","uid"]
        return dictionaryWithValues(forKeys: keys).description*/
    }
    //MARK: - 保存当前对象
   /*未写UserAccountViewModel时的写法
    func saveUserAccount(){
        //保存路径
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        //保存为plist文件
        //as在swift中大多只有三个地方用“桥接”
        //1>string as NSString
        //2>NSArray as [array]
        //3>NSDictionary as [String:Any]
        path = (path as NSString).appendingPathComponent("account.plist")
        //在实际开发中，一定要确保文件真的保存了！
        print(path)
        //归档保存
        NSKeyedArchiver.archiveRootObject(self, toFile: path)
    }*/
    
    
    //MARK: - '键值'归档和解档
    ///归档--在把当前对象保存到磁盘前，将对象编码成二进制数据--跟网络的序列化很像
    ///aCoder--编码器
    func encode(with coder: NSCoder) {
        
        coder.encode(access_token, forKey: "access_token")
        coder.encode(expiresData, forKey: "expiresData")
        coder.encode(uid, forKey: "uid")
        coder.encode(screen_name, forKey: "screen_name")
        coder.encode(avatar_large, forKey: "avatar_large")
    }
    ///解档---从磁盘加载二进制文件，转换成对象时调用--跟网络的反序列化很像
    ///return--当前对象
    ///aDecoder--解码器
    ///required---没有继承性，所有的对象只能解档出当前的对象
    required init?(coder aDecoder:NSCoder){
        
        access_token = aDecoder.decodeObject(forKey: "access_token") as?String
        expiresData = aDecoder.decodeObject(forKey: "expiresData") as?NSDate
        uid = aDecoder.decodeObject(forKey: "uid") as?String
        screen_name = aDecoder.decodeObject(forKey: "screen_name") as?String
        avatar_large = aDecoder.decodeObject(forKey: "avatar_large") as?String
       
        
    }
}

//在extension中只允许写便利构造函数，而不能写指定构造函数
//也不能定义存储型属性，定义存储型属性，会破坏类本身的结构
extension UserAccount{
    
}
