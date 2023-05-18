//
//  UIImage+Extension.swift
//  照片选择控件
//
//  Created by 云动家 on 2023/5/10.
//

import UIKit

extension UIImage{
    //将图像缩放到指定宽度，如果小于指定宽度直接返回
    func scaleToWith(width: CGFloat) -> UIImage{
        //1.判断宽度
        //size.width--->image
        if width > size.width{
            return self
        }
        //2.计算比例
        let height = size.height * width / size.width
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        //3.使用核心绘图绘制新的图像(固定的五个步骤)
        //1>上下文
        UIGraphicsBeginImageContext(rect.size)
        //2>绘图 --在指定区域拉伸绘制
        self.draw(in: rect)
        //3>取结果
        let result = UIGraphicsGetImageFromCurrentImageContext()
        //4>关闭上下文
        UIGraphicsEndImageContext()
        //5>返回结果
        return result!
    }
}
