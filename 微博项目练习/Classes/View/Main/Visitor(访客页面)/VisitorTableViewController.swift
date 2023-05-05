//
//  VisitorTableViewController.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/25.
//

import UIKit

class VisitorTableViewController: UITableViewController {
    
    ///用户登录标记
    ///应用程序每个控制器各自有各自不同的控制器
    /// 从实例化private var userLogon = UserAccountViewModel().userLogin到单例
    private var userLogon = UserAccountViewModel.sharedUserAccount.userLogin
  
  
    ///访客视图
    var visitorView : VisitorView?
    
    
    //根据用户登录的情况，决定显示的根视图
    override func loadView() {
        super.loadView()
        
        if !userLogon {
            setupVisitorView()
        }
    }
    
    
    ///设置访客页面
    private func setupVisitorView(){
        //替换根视图
        visitorView = VisitorView()
        view = visitorView
        //修改导航栏的全局外观，要在控件创建之前，一经设置全局有效，不可在这里加，要在Appdelegate设置
        
        ///添加注册、登录的监听方法
        visitorView?.registerButton.addTarget(self, action: #selector(clickRegister), for: .touchUpInside)
        visitorView?.loginButton.addTarget(self, action: #selector(clickLogin), for: .touchUpInside)
        
        
        //设置导航栏按钮--注册、登录
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: .plain, target: self, action:#selector(clickRegister) )
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: .plain, target: self, action:#selector(clickLogin) )
    }
}

// MARK: - 访客视图监听方法



extension VisitorTableViewController{
    
  @objc  func  clickRegister(){
        print("注册")
    }
    
   @objc  func clickLogin(){
        print("登录")
        let vc = OAuthViewController()
        let nav = UINavigationController(rootViewController:vc)
       present(nav, animated: true,completion: nil)
    }
}
