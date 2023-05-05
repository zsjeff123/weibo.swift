//
//  Status.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/1.
//

import UIKit

///微博数据模型--用来字典转模型（使用kvc方法）
class Status: NSObject {
    //首页--------------------------------------------
    /// 微博ID
    var id: Int = 0
    
    /// 微博信息内容
    var text: String?
    
    ///微博创建时间
    var created_at: String?
    
    /// 微博来源
    var source: String?
    
    ///缩略图配图数组---key为thumbnail_pic
    ///pic_urls是一个字典数组类型
    var pic_urls: [[String: String]]?
    
    ///用户模型
    var user: User?
    
    //转发-------------------------------------------------
    ///被转发的原微博信息片段
    var retweeted_status: Status?
    
    
    init(dict: [String: Any]) {
        
        super.init()
        
        //setValuesForKeys(withDictionary:) 是 NSObject 类的一个方法，它的作用是根据传入的字典参数，以 key-value 的方式设置对象的属性值。
       
        //如果使用KVC时，value是一个字典，会直接给属性转换成字典
        setValuesForKeys(dict)
    }
    
    //优先判断，相对于override func setValue(_ value: Any?, forUndefinedKey key: String)
    override func setValue(_ value: Any?, forKey key: String) {
        //判断key是否为user
        if key == "user", let dict = value as? [String: Any] {
            //字典转模型
            user = User(dict: dict)
            return
        }
        //判断key是否等于retweeted_status
        if key == "retweeted_status", let dict = value as? [String: Any] {
            //字典转模型
            retweeted_status = Status(dict: dict)
            return
        }
        
        super.setValue(value, forKey: key)
    }
    
    
    //为了避免冗余属性导致的错误，修改后  setValuesWithDict(dict)，避免出现'this class is not key value coding-compliant for the key id.'的错误
    //为了有效地将字典转模型
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        switch key {
        case "id":
            id = (value as? Int)!
        case "text":
            text = value as? String
        case "created_at":
            created_at = value as? String
        case "source":
            source = value as? String
        case "pic_urls":
            pic_urls = value as? [[String: String]]
        case "retweeted_status":
            retweeted_status = value as? Status
        default: break
            //debugPrint("Undefined key: \(key)")
        }
    }
    
 override var description: String {
        
     let dict = ["id": id as Any,"text":text as Any,"created_at": created_at as Any,"source":source as Any,"user":user as Any,"pic_urls":pic_urls as Any,"retweeted_status":retweeted_status as Any]
                
        return "\(dict)"
        
    }
}
