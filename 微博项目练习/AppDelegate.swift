//
//  AppDelegate.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/25.
//

import UIKit
import Alamofire

@UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //设置输出
        //实际用处不大
        QorumLogs.enabled = true
        QorumLogs.test()
        
        
        //设置AFN - 当通过AFN发起网络请求时，会在状态栏显示转动菊花（待定--看不太到效果）
       // AFNetworkActivityIndicatorManager.shared().isEnabled = true
        
        //调用全局外观
        setupAppearence()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        
        window?.rootViewController = defaultRootViewController
        
        window?.makeKeyAndVisible()
      
        //监听通知
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "WBSwitchRootViewControllerNotification"), object: nil, queue: nil) { [weak self] notification in
            //打印线程和通知
            print(Thread.current)
            print(notification)
            
            //访客页面跳转到欢迎界面
            let vc = notification.object != nil ? WelcomeViewController() : MainViewController()
            //切换控制器
            self?.window?.rootViewController = vc
        }
      /*注释：
       NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "WBSwitchRootViewControllerNotification"),   //通知名称，通知中心用来识别通知的
           object: nil,            //发送通知的对象，如果为nil,监听任何对象
           queue: nil)           //为nil,主线程--实现异步操作
       { [weak self] notification in         //闭包，弱引用weak self
       //切换根视图
            self?.window?.rootViewController = MainViewController()
        }
       */
        
      
        
        return true
    }
     //应用程序进入到后台
     func applicationDidEnterBackground(_ application: UIApplication) {
         //清除数据库缓存
         StatusDAL.clearDataCache()
         
     }
     
    deinit{
        //注销通知-注销指定的通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "WBSwitchRootViewControllerNotification"), object: nil)
    }
    /*注释：
     NotificationCenter.default.removeObserver(self,  //监听者
     name: NSNotification.Name(rawValue:        //监听的通知 "WBSwitchRootViewControllerNotification"),
     object: nil)           //发送通知的对象
     */
    
    ///设置全局外观--在很多应用程序中，都会在AppDelegate中设置所有需要控件的全局外观
    private func setupAppearence(){
        //修改导航栏的全局外观，要在控件创建之前，一经设置全局有效
        UINavigationBar.appearance().tintColor = UIColor.orange
    }
    //MARK: - 系统自带的方法（暂时不用）
    func applicationWillResignActive(_ application: UIApplication) {
       
    }

    //func applicationDidEnterBackground(_ application: UIApplication) {
        
   // }

    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
       
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}
//MARK: - 界面切换的代码
extension AppDelegate{
   ///启动的根视图控制器
    private var defaultRootViewController: UIViewController{
        //1.判断是否登录
        if UserAccountViewModel.sharedUserAccount.userLogin{
            return isNewVersion ? NewFeatureViewController() : WelcomeViewController()
        }
        //2.没有登录则返回主控制器
        return MainViewController()
        
    }
    
    
    //判断是否为新版本
    private var isNewVersion: Bool{
        //1.当前版本 - info.plist
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]as! String
        let version = Double(currentVersion)!
            print("当前版本\(version)")
        
        //2.'之前的版本'，把当前版本保存在用户偏好-如果key不存在，返回0.0(即sandboxVersion为0)
        //这次的当前版本就是下次的‘之前的版本'
        //用户偏好：使用 UserDefaults 类来读写用户偏好数据
        let sandboxVersionKey = "sandboxVersionKey"
        let sandboxVersion = UserDefaults.standard.double(forKey: sandboxVersionKey)
        print("之前版本\(sandboxVersion)")
        
        //3.保存当前版本
        UserDefaults.standard.set(version,forKey: sandboxVersionKey)
        
        //运行新版本
        return version > sandboxVersion
    }
    
}
