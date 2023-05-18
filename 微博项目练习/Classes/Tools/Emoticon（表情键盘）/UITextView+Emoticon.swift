//
//  UITextView+Emoticon.swift
//  表情键盘
//
//  Created by 云动家 on 2023/5/9.
//


import UIKit


//代码复合--对重构完成的带啊吗进行检查
/*
 1.修改注释!!
 2.确认是否需要进一步重构
 3.再一次检查返回值和参数
 */
extension UITextView{
    
    //图片表情完整字符串内容
    var emoticonText:String {
        
        print(attributedText as Any)
        
        let  attrString = attributedText
        
        var  strM = String()
        
        //遍历属性文本
        //NSAttachment--图片表情
        attrString?.enumerateAttributes(in: NSRange(location: 0, length: attrString!.length), options: []){(dict, range, _) in
            if let attachment = dict[NSAttributedString.Key(rawValue: "NSAttachment") ] as? EmoticonAttachment{
                print("图片\(attachment.emoticon)")
                
                strM += attachment.emoticon.chs ?? ""
            }else{
                let str = (attrString!.string as NSString).substring(with: range)
                print("字符串\(str)")
                //拼接字符串
                strM += str
            }
        }
        return strM
    }
    
    //插入表情符号
    //em：表情模型
    func insertEmoticon(em:Emoticon){
        
        //1.空白表情
        if em.isEmpty{
            return
        }
        //2.删除按钮-->删除输出
        if em.isRemoved{
            //deleteBackward--删除文本！！（功能已做好）
            deleteBackward()
            return
        }
        //3.emoji
        if let emoji = em.emoji{
           replace(selectedTextRange!, withText: emoji)
            return
        }
        //4.插入图片表情
        insertImageEmoticon(em: em)
        
        //5.通知“代理”文本变化了
        //textviewDidchanged?表示代理如果没有实现方法，就什么都不做，更安全
        delegate?.textViewDidChange?(self)
        
    }
    ///插入图片表情
    private func insertImageEmoticon(em: Emoticon){
       
   /*     //1.图片的属性文本
        let attachment  = EmoticonAttachment(emoticon: em)
        attachment.image = UIImage(contentsOfFile: em.imagePath)
        //线宽表示字体的高度的调整
        //attachment 是一个 NSTextAttachment 对象，它是表示文本的特殊类型之一。NSTextAttachment 可以插入到富文本中，显示为图片或其它媒体内容
        //通过设置attachment 对象的 bounds 属性，我们可以控制表情图片的大小和位置
        //bounds是一个类似于矩形的结构体，用于描述视图在其自身坐标系中的位置和大小。
        //frame = center + bounds + transform
        //bounds(x.y) = contentoffset
        let lineHeight = font!.lineHeight
        attachment.bounds = CGRect(x: 0, y: -4, width: lineHeight, height: lineHeight)
        //获得图片文本
        let imageText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        //添加文字字体
        //作用范围是 NSRange(location: 0, length: 1)，即文本的第一个字符。
        imageText.addAttribute(NSAttributedString.Key.font, value: font!, range: NSRange(location: 0, length: 1))
        */
        let imageText = EmoticonAttachment(emoticon: em).imageText(font: font!)
        
        //2.转换成可变文本
        let  strM = NSMutableAttributedString(attributedString: attributedText)
        //3.插入文本
        strM.replaceCharacters(in: selectedRange, with: imageText)
        //4.替换属性文本
        //1)记录光标位置
        let range = selectedRange
        //2）设置属性文本
        attributedText = strM
        //3）恢复光标位置
        selectedRange =  NSRange(location: range.location + 1, length: 0)
    }
    
}
