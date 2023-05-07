//
//  NetworkTools.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/28.
//

import UIKit
import AFNetworking

/// Swift 的枚举支持任意数据类型
/// switch / enum 在 OC 中都只是支持整数
enum HMRequestMethod : String {
    case GET
    case POST
}

// MARK: - 网络工具
class NetworkTools: AFHTTPSessionManager {
    
    // MARK: - 应用程序信息
    private let appKey = "2600334383"
    private let appSecret = "4fedacfce9e50750362e907a0dd4661e"
    private let redirectUrl = "http://www.baidu.com"
    
    ///网络请求完成回调，类似OC的type Define,类似替代回调闭包的过程
    typealias HMRequestCallBack = (_ result: Any?, _ error: Error?)->()
     
    //单例
    static let sharedTools: NetworkTools = {
        
        // 实例化对象
        let tools = NetworkTools(baseURL: nil)
        
        // 设置响应反序列化支持的数据类型
        tools.responseSerializer.acceptableContentTypes?.insert("text/plain")
        
        // 返回对象
        return tools
    }()
    ///返回token字典
    private var tokenDict: [String:Any]?{
        //判断token是否有效
        if let token = UserAccountViewModel.sharedUserAccount.account?.access_token{
            return ["access_token": token]
        }
        return nil
    }
    
    
}
// MARK: - OAuth相关方法
extension NetworkTools{
    
    ///OAuth授权URL
    ///-see:[https://open.weibo.com/wiki/Oauth2/authorize](https://open.weibo.com/wiki/Oauth2/authorize)
    var oauthURL : NSURL{
        
        let  urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(appKey)&redirect_uri=\(redirectUrl)"
        
        return NSURL(string: urlString)!
    }
    
    ///加载Access Token
    func loadAccessToken(code:String,completion:@escaping HMRequestCallBack){
        
        let urlString = "https://api.weibo.com/oauth2/access_token"
        
        let params = ["client_id":appKey,
                      "client_secret":appSecret,
                      "grant_type":"authorization_code",
                      "code":code,
                      "redirect_uri":redirectUrl]
        //用的是POST方法
        //一般写法，不用json
        request(method:.POST,URLString: urlString, parameters: params, completion: completion)
     /*
        //测试返回的数据内容-- AFN默认的响应格式是json，会直接反序列化
        //要确认数据格式的问题
        //如果是NSNumber，则没有引号，在做KVC指定属性类型非常重要
        //1>设置相应数据格式是二进制的
        responseSerializer = AFHTTPResponseSerializer()
        //2>发起网络请求
        post(urlString, parameters: params, headers: nil, progress: nil, success: {(_,result) -> Void in
            
            //将二进制数据转换成字符串
            let json = NSString(data: (result as! NSData) as Data, encoding: NSUTF8StringEncoding)
            
            print(json ?? NSString())
            
        },failure: nil)
      */
    }
}
// MARK: - 微博首页数据相关方法
extension NetworkTools{
   
    ///加载微博数据
    ///completion: @escaping HMRequestCallBack--完成回调
    ///--see :[https://open.weibo.com/wiki/2/statuses/home_timeline](https://open.weibo.com/wiki/2/statuses/home_timeline)
    ///since_id    false    int64    若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
   /// max_id    false    int64    若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
    func loadStatus(since_id: Int,max_id: Int,completion: @escaping HMRequestCallBack){
       
        //1.获取token字典
        guard var params = tokenDict else{
            //如果字典tokenDict为nil,通知调用方token无效
            completion(nil,NSError(domain: "cn.itcast.error" as String, code: -1001, userInfo: ["message":"token为空"]))
            return
        }
        
        //判断是否下拉
        if since_id > 0{
            params["since_id"] = since_id
        }else if max_id > 0{
            //上拉参数
            //-1这样微博才连续，不会有重复
            params["max_id"] = max_id - 1
        }
        
        //2.准备网络参数
    let urlString = "https://api.weibo.com/2/statuses/home_timeline.json"
        
        //3.发起网络请求
        request(method:.GET,URLString: urlString, parameters: params, completion: completion)
    }
}
// MARK: - 用户相关方法
extension NetworkTools{
    ///加载用户信息
    ///see--[https://open.weibo.com/wiki/2/users/show](https://open.weibo.com/wiki/2/users/show)
    func loadUserInfo(uid: String,completion: @escaping HMRequestCallBack){
        
        //1.获取用户信息
        guard var params = tokenDict else{
            //如果字典tokenDict为nil,通知调用方token无效
            completion(nil,NSError(domain: "cn.itcast.error" as String, code: -1001, userInfo: ["message":"token为空"]))
            return
        }
        
        //2.处理网络参数
        let urlString = "https://api.weibo.com/2/users/show.json"
        params ["uid"] = uid
        request(method:.GET,URLString: urlString, parameters: params, completion: completion)
        
    }
}

// MARK: - 封装 AFN 网络方法
extension NetworkTools{
    /// 封装 AFN 的 GET / POST 请求
    ///
    /// - parameter method:     GET / POST
    /// - parameter URLString:  URLString
    /// - parameter parameters: 参数字典
    /// - parameter completion: 完成回调
    private func request(method: HMRequestMethod = .GET, URLString: String, parameters: [String: Any]?, completion: @escaping HMRequestCallBack) {
        
        // 定义成功回调
        let success = { (task: URLSessionDataTask, result: Any?)->() in
            completion(result, nil)
        }
        // 定义失败回调
        let failure = { (task: URLSessionDataTask?, error: Error)->() in
            //开发网络应用的时候，错误不要提示给用户，但是错误一定要输出
            print(error)
            completion(nil,error)
            
        }
        if method == HMRequestMethod.GET{
            get(URLString, parameters: parameters, headers: nil, progress: nil, success: success, failure: failure)
        } else {
            post(URLString, parameters: parameters, headers: nil, progress: nil, success: success, failure: failure)
        }
            
        
    }
}
