//
//  Common.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/26.
//


///目的：提供全局共享属性或者方法，类似pch文件
import UIKit

// MARK: - 全局通知定义
///切换根视图控制器的通知---一定要够长，要有前缀
let WBSwitchRootViewControllerNotification = "WBSwitchRootViewControllerNotification"

///选中照片的通知
let WBStatusSelectedPhotoNotification = "WBStatusSelectedPhotoNotification"
///选中照片的key ----IndexPath(用于通知的监听)
let WBStatusSelectedPhotoIndexPathKey = "WBStatusSelectedPhotoIndexPathKey"
///选中照片的key ----URL数组(用于通知的监听)
let WBStatusSelectedPhotoURLsKey = "WBStatusSelectedPhotoURLsKey"

///全局外观渲染颜色-->延展出“皮肤”的管理类
let WBAppearanceTintColor = UIColor.orange

// MARK: - 全局函数，可以直接使用
///延迟在主线程的执行函数
///delta为延迟时间， callFunc()为要执行的闭包
func delay(delta: Double, callFunc: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delta) {
        callFunc()
    }
}
