//
//  MainViewController.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/25.
//

import UIKit

class MainViewController: UITabBarController {
    
    //MARK: 视图生命周期函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChilds()
        
        setupComposedButton()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 将添加按钮置前
        tabBar.bringSubviewToFront(composedButton)
    }
    // MARK: - 中间按钮 监听事件
    // FIXME: 没有实现的
    @objc private func clickComposeBtn() {
        // private 添加为私有
        // @objc 允许这个函数在运行时通过OC的消息机制被调用
        print("点击中间按钮")
        
        //判断用户是否登录
        var vc: UIViewController
        if UserAccountViewModel.sharedUserAccount.userLogin{
            vc = ComposeViewController()
        }else{
            vc = OAuthViewController()
        }
        
        let nav = UINavigationController(rootViewController: vc)
        present(nav,animated:true,completion:nil)
    }
    // MARK: - 中间的 + 号 按钮(懒加载按钮控件)
    private var composedButton : UIButton = UIButton.cz_buttonImage( "tabbar_compose_icon_add", backImageName: "tabbar_compose_button")
}
// MARK: - 设置界面
extension MainViewController{
       // 设置添加按钮
    private func setupComposedButton() {
        // 添加按钮
        tabBar.addSubview(composedButton)
         //调整按钮的位置（一开始会出现在左边）
        let count = CGFloat(children.count)
        let w = tabBar.bounds.width/count - 1

        composedButton.frame = tabBar.bounds.insetBy(dx: w * 2, dy: 0)
        //添加监听方法
        composedButton.addTarget(self, action: #selector(clickComposeBtn), for: .touchUpInside)
        
    }
    
    
    // 添加所有的控制器
    private func addChilds() {
        // 设置 tintColor-渲染颜色
        //性能提升技巧--如果能够用颜色解决，就不建议使用图片
        tabBar.tintColor = UIColor.orange
    addChild(HomeTableViewController(), title: "首页", imageName: "tabbar_home")
    addChild(MessageTableViewController(), title: "消息", imageName: "tabbar_message_center")
    addChild(UIViewController())
    addChild(DiscoverTableViewController(), title: "发现", imageName: "tabbar_discover")
    addChild(ProfileTableViewController(), title: "我的", imageName: "tabbar_profile")
    }
    
    // 添加控制器
    private func addChild(_ vc: UIViewController, title: String, imageName: String) {
        // 设置标题--由内至外设置
        vc.title = title
        // 设置图像
        vc.tabBarItem.image = UIImage(named: imageName)
        
        // 导航控制器
        let nav = UINavigationController(rootViewController: vc)
        addChild(nav)
    }
}

