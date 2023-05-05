//
//  OAuthViewController.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/28.
//

import UIKit
import SVProgressHUD


//用户登录控制器
class OAuthViewController: UIViewController {
    
    private  lazy  var webView = UIWebView()
    
    // MARK: - 监听方法
    /// 登录返回页面
    @objc private func close() {
        SVProgressHUD.dismiss()
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - 自动填充用户名和密码 - web 注入（以代码的方式向web页面添加内容）
    @objc private func autoFill(){
        
        let js = "document.getElementById('userId').value = '18028335883';" + "document.getElementById('password').value = 'ocb123456'"
        //让webview 执行 js
        webView.stringByEvaluatingJavaScript(from: js)
        
    }
    
    // MARK: - 设置页面
    
    override func loadView() {
        view = webView
        
        //设置代理
        webView.delegate = self
        
    //设置导航栏
        title = "登录新浪微博"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "自动填充", style: .plain, target: self, action: #selector(autoFill))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //在开发中，如果纯代码开发，视图最好都指定背景颜色，如果为nil,会影响渲染效率
        view.backgroundColor = UIColor.white
        print(view.backgroundColor as Any)
        
        
      //加载页面
        self.webView.loadRequest(URLRequest(url: NetworkTools.sharedTools.oauthURL as URL))
        
        
    }
    
}

// MARK: - UIWebViewDelegate
extension OAuthViewController:UIWebViewDelegate{
    /// 监测webView将要加载请求时返回的结果
    ///
    /// - Parameters:
    ///   - webView: webView
    ///   - request: 要加载的请求,返回false不加载，返回true加载
    ///   - navigationType: 导航类型 点击链接加载\点击表单提交加载....
    /// - Returns: 是否加载request
    /// 如果IOS的代理方法中有返回bool,通常返回true很正常，返回false不能正常工作
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        //目标：如果是百度则不加载
        //1.判断访问的主机地址是否为www.baidu.com
        guard let url = request.url, url.host == "www.baidu.com" else{
            return true
        }
        //2.从百度地址的url中提取‘code=’是否存在
        guard let query = url.query,query.hasPrefix("code=")  else{
            print("取消授权")
            close()
            return false
        }
        //3.从query字符串中提取‘code=’后面的授权码
        //字符串切片来替换substring(from:)方法，使用fromIndex的索引值代替from参数
        let code = String(query[query.index(after: query.firstIndex(of: "=")!)...])
        //let code = query.substring(from: "code=".endIndex)[此方法已被弃用]
        
        print(query)
        print("授权码是"+code)
        /*
        //主机地址
        print(url.host as Any)
        //查询字符串
        print(url.query as Any)
        print(request)*/
        
        //4.加载accessToken
        UserAccountViewModel.sharedUserAccount.loadAccessToken(code: code) { isSuccessed in
            
            //completion的完整代码
            if !isSuccessed {
            
                SVProgressHUD.showInfo(withStatus: "您的网络不给力")
                //延迟关闭，不然self.close()关闭页面太快,1秒的延迟
                /*DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.close()
                }*/
                delay(delta: 0.5) {
                    self.close()
                }
               return
            }
                print("成功了")
                print(UserAccountViewModel.sharedUserAccount.account as Any)
            
            //停止指示器
            SVProgressHUD.dismiss()
            
            //用户成功登录，则退出当前控制器，并发送切换根视图的通知
            //通知中心发通知是同步进行的---一旦发送通知，会先执行监听方法，直接结束后，才执行后续代码
            //dismiss方法不会再立即将控制器销毁
            self.dismiss(animated: false, completion: { NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WBSwitchRootViewControllerNotification"), object: "welcome")
                
            })
            
        }
        /*未写UserAccountViewModel时的写法
         NetworkTools.sharedTools.loadAccessToken(code: code) { result, error in
            
            //1>判断错误
            if error != nil{
                print("出错了")
                return
            }
            //2>输出结果,在swift中任何AnyObject在使用前，都必须转换类型 ->as ?/! 类型
            print(result as Any)
            let account = UserAccount(dict: result as! [String:AnyObject])
            //调用函数
            self.loadUserInfo(account: account)
        }
        */
        return false
    }
    
    //调用用户信息的函数(扩展定义)
   /*未写UserAccountViewModel时的写法
    private func loadUserInfo(account: UserAccount){
        NetworkTools.sharedTools.loadUserInfo(uid: account.uid!, accessToken: account.access_token!) { result, error in
            
            if error != nil{
                print("加载用户出错")
                return
            }
            //作了两个判断1.result一定有内容2.一定是字典
            //提示：如果使用guard let as/if let 统统使用？
            guard let dict = result as? [String:Any] else{
                print("格式错误")
                return
            }
            //dict一定是一个字典
            //将用户信息保存
            account.screen_name = dict["screen_name"] as? String
            account.avatar_large = dict["avatar_large"] as? String
            print(account)
            
            //保存当前对象方法调用
            account.saveUserAccount()
        }
        
    }*/
    //等待页面加载时有转轮旋转
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
}

