//
//  UIBarButtonItem+Extension.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/9.
//
import UIKit

extension UIBarButtonItem{
    
    convenience init(imageName:String,target: Any?,actionName:String?) {
        let button = UIButton.cz_buttonImage(imageName, backImageName: nil)
        //判断actionName是否存在，如果存在，则为子控件添加点击事件处理方法
        if let actionName = actionName{
            
            button.addTarget(target, action: Selector(actionName), for: .touchUpInside)
            
        }
        
        self.init(customView: button)
    }
}
