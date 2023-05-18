//
//  EmoticonAttachment.swift
//  表情键盘
//
//  Created by 云动家 on 2023/5/8.
//

import UIKit

///表情符号附件--处理NSAttachment
class EmoticonAttachment: NSTextAttachment {
    
    //表情符号对象（表情模型）
    var emoticon: Emoticon
    
    //将当前附件中的emoticon转换成属性文本
    func imageText(font:UIFont) -> NSAttributedString{
        
        
        //1.图片的属性文本
        
        image = UIImage(contentsOfFile: emoticon.imagePath)
        
        let lineHeight = font.lineHeight
        bounds = CGRect(x: 0, y: -4, width: lineHeight, height: lineHeight)
        //获得图片文本
        let imageText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: self))
        //添加文字字体
        //作用范围是 NSRange(location: 0, length: 1)，即文本的第一个字符。
        imageText.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: 1))
        
        return imageText
    }
    // MARK: - 构造函数
    init(emoticon: Emoticon) {
        self.emoticon = emoticon
        super.init(data: nil, ofType: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
