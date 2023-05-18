//
//  Emoticon.swift
//  表情键盘
//
//  Created by 云动家 on 2023/5/8.
//

import UIKit

// MARK: - 表情模型
class Emoticon: NSObject {
        /// 表情文字
        var chs: String?
        /// 表情图片文件名 +表情包路径
        var png: String?
        ///完整路径
    var imagePath:String{
        //判断是否有图片
        if png == nil{
            return""
        }
        //拼接完整路径
        return Bundle.main.bundlePath + "/Emoticons.bundle/" + png!
    }
    
        /// emoji的字符串编码
     var code: String?{
        didSet{
            emoji = code?.emoji
            //把String+Emoji中的emoji附过来
        }
    }
    
        ///emoji的字符串
        var emoji: String?
    /// 是否删除按钮标记
    var isRemoved = false
    /// 是否空白按钮标记
    var isEmpty = false
    
    ///表情使用次数
    var times = 0
    
   
    // MARK: - 构造函数
    init(dict:[String: Any]){
        super.init()
        setValuesForKeys(dict)
    }
    // MARK: - 构造函数
    init(isRemoved: Bool) {
        self.isRemoved = isRemoved
    }
    // MARK: - 构造函数
    init(isEmpty: Bool) {
    self.isEmpty = isEmpty
    }
    
    
    //处理未定义属性
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        switch key {
        case "chs": chs = value as? String
        case "png": png = value as? String
        case "code": code = value as? String
        default: break
            
        }
        
    }
            
    /// 描述
    override var description: String{
            
        let dict = ["chs": chs as Any,"png": png as Any,"code": code as Any,"isRemoved": isRemoved as Any]
            return "\(dict)"
    }
}
