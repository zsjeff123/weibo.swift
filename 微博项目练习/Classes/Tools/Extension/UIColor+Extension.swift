//
//  UIColor+Extension.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/11.
//

import UIKit


extension  UIColor{
    
    //随机颜色--用于调试
    class func  randomColor() -> UIColor{
        
        //0-255
        //生成浮点数
        let r = CGFloat(Int.random(in: 0...255)) / 255.0
        let g = CGFloat(Int.random(in: 0...255)) / 255.0
        let b = CGFloat(Int.random(in: 0...255)) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
