//
//  UILabel+Extension.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/26.
//

import UIKit
// MARK: - 便利构造函数
extension UILabel{
    
    ///color默认为深灰色,fontsize默认14
    ///screenInset:相对于屏幕左右的缩进，默认为0，居中显示，如果设置，则左对齐
    class func cz_messagelabel(title:String,fontSize:CGFloat=14,color:UIColor=UIColor.darkGray,screenInset: CGFloat = 0) -> UILabel{
        
        let label1 = UILabel()
        
        label1.text=title
        //界面设计避免使用纯黑色
        label1.textColor = color
        //字体大小
        label1.font = UIFont.systemFont(ofSize: fontSize)
        //可换行(要加自动布局的宽高来实现)
        label1.numberOfLines = 0
        //文本换行（一定要的）
        if screenInset == 0 {
            label1.textAlignment = .center
        }else{
            //设置换行宽度
            label1.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 2 * screenInset
            //左对齐方式
            label1.textAlignment = .left
        }
        
        return label1
        
    }
}
