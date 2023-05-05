//
//  UIButton+Extension.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/25.
//

import UIKit
// MARK: - 便利构造函数
extension UIButton {
    
    /// 可以设置button前景图和背景图
    ///
    /// - Parameters:
    ///   - imageName: 前景图名
    ///   - backImageName: 背景图名
    class func cz_buttonImage(_ imageName: String, backImageName: String) -> UIButton {
        
        let btn1 = UIButton()
        btn1.setImage(UIImage(named: imageName), for: UIControl.State.normal)
        btn1.setBackgroundImage(UIImage(named: backImageName), for: UIControl.State.normal)
        btn1.setImage(UIImage(named: imageName + "_highlighted"), for: UIControl.State.highlighted)
        btn1.setBackgroundImage(UIImage(named: backImageName + "_highlighted"), for: UIControl.State.highlighted)
       //会根据背景图片大小调整尺寸
        btn1.sizeToFit()
        
        return btn1
    }
    
    
    ///设置访客页面的登录、注册按钮的便利构造函数
    class func cz_RLbutton(title: String, color: UIColor, imageName:String)->UIButton{
        let btn2 = UIButton()
        btn2.setTitle(title, for: UIControl.State.normal)
        btn2.setTitleColor(color, for: UIControl.State.normal)
        btn2.setBackgroundImage(UIImage(named: imageName), for: UIControl.State.normal)
        btn2.sizeToFit()
        
        return btn2
    }
    
    ///设置首页界面的转发、评论、赞的便利构造函数
    class func cz_SYbutton(title: String, fontSize: CGFloat,color: UIColor, imageName:String)->UIButton{
        let btn3 = UIButton()
        btn3.setTitle(title, for: UIControl.State.normal)
        btn3.setTitleColor(color, for: UIControl.State.normal)
        btn3.setImage(UIImage(named: imageName), for: UIControl.State.normal)
        btn3.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        btn3.sizeToFit()
        
        return btn3
    }
}
