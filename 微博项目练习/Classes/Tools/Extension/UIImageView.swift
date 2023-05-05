//
//  UIImageView.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/26.
//

import UIKit
// MARK: - 便利构造函数
extension UIImageView{
    
    class func cz_iconViewImage(imageName:String) ->UIImageView{
        
        let  iconView1 = UIImageView()
        iconView1.image = UIImage(named: imageName)
        return iconView1
    }
}
