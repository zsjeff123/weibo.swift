//
//  EmoticonPackage.swift
//  表情键盘
//
//  Created by 云动家 on 2023/5/8.
//

import UIKit

// MARK: - 表情包模型
class EmoticonPackage: NSObject {
    
    /// 表情包所在路径
    var id:String?
    /// 表情包mingc
    var group_name_cn: String?
    /// 表情包数组--保证在使用的时候，数组已经存在，可以直接追加数据
    lazy var emoticons = [Emoticon]()
    
    init(dict: [String: Any]) {
        super.init()
        
        id = dict["id"] as? String
        group_name_cn = dict["group_name_cn"] as? String
        //1.获得字典的数组
        if let array  = dict["emoticons"] as? [[String: String]] {
            //2.遍历数组
            var index = 0
            for var d in array {
                //com.xxxx/xxxx.png--->png
                //1>判断是否有png的值
                if let png = d["png"],let dir = id{
                    //2>重新设置字典的png的value
                    d["png"] = dir + "/" + png
                }
                
                let emoticon = Emoticon(dict: d)
                    emoticons.append(emoticon)
                
                //追加删除按钮--每隔20个添加一个按钮
                index += 1
                if index == 20 {
                   emoticons.append(Emoticon(isRemoved: true))
                   
                    index = 0
                }
            }
        }
        //2.添加空白按钮
        appendEmptyButton()
    }
    
    //在表情数组末尾，添加空白表情
    private func appendEmptyButton() {
       //取表情的余数
        let  count = emoticons.count % 21
        
        //已经排满的,就不要追加
        //只有最近和默认需要添加空白表情
        if  emoticons.count > 0 && count == 0 {
            
            return
        }
        //添加空白表情
        for _ in count..<20 {
            emoticons.append(Emoticon(isEmpty: true))
        }
        //最末尾再添加一个删除按钮
        emoticons.append(Emoticon(isRemoved: true))
    }
        
    
    //处理未定义属性
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        switch key {
        case "id": id = value as? String
        case "group_name_cn": group_name_cn = value as? String
        case "emoticons": emoticons = value as? [Emoticon] ?? []
            default: break}
        
    }
    
    /// 描述
    override var description: String{
        let dict = ["id": id as Any,"group_name_cn": group_name_cn as Any,"emoticons": emoticons as Any]
        return "\(dict)"
    }
}
