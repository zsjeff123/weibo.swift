//
//  User.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/1.
//

import UIKit

//用户模型
class User: NSObject {

    // 基本数据类型 & private 不能使用 KVC 设置
    ///用户UID
    var id: Int = 0
    /// 用户昵称
    var screen_name: String?
    /// 用户头像地址（中图），50×50像素
    var profile_image_url: String?
    /// 认证类型，-1：没有认证，0，认证用户，2,3,5: 企业认证，220: 达人
    var verified_type: Int = 0
    /// 会员等级 0-6
    var mbrank: Int = 0
    
    
    init(dict: [String: Any]) {
        
        super.init()
        
        setValuesForKeys(dict)
}
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        // 处理未定义的属性
                switch key {
                case "id":
                    id = (value as? Int)!
                case "screen_name":
                    screen_name = value as? String
                case "profile_image_url":
                    profile_image_url = value as? String
                case "verified_type":
                    verified_type = (value as? Int)!
                case "mbrank":
                    mbrank = (value as? Int)!
                default: break
                  //  debugPrint("Undefined key: \(key)")
                }
          
    }
    
    override var description: String {
        
        let dict = ["id": id as Any,"screen_name":screen_name as Any,"profile_image_url": profile_image_url as Any,"verified_type":verified_type as Any,"mbrank":mbrank as Any]
                
        return "\(dict)"
        
    }
}
