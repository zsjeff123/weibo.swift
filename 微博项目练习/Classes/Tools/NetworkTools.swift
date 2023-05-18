//
//  NetworkTools.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/28.
//

import UIKit
//import AFNetworking
import Alamofire



// MARK: - 网络工具
class NetworkTools {
    
   

    
    // MARK: - 应用程序信息
    private let appKey = "2600334383"
    private let appSecret = "4fedacfce9e50750362e907a0dd4661e"
    private let redirectUrl = "http://www.baidu.com"
    
    ///网络请求完成回调，类似OC的type Define,类似替代回调闭包的过程
    typealias HMRequestCallBack = (_ result: Any?, _ error: Error?)->()
     
    //单例
    static let sharedTools = NetworkTools()
  /*  ///返回token字典
    private var tokenDict: [String:Any]?{
        //判断token是否有效
        if let token = UserAccountViewModel.sharedUserAccount.account?.access_token{
            return ["access_token": token]
        }
        return nil
    }*/
    
    
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
        request(method:.post,URLString: urlString, parameters: params, completion: completion)
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

// MARK: - 发布微博
extension NetworkTools{
    
    
    //status微博文本
    //completion完成回调
    //see:[https://open.weibo.com/wiki/2/statuses/share](https://open.weibo.com/wiki/2/statuses/share)
    func sendStatus(status:String,image:UIImage?,completion:@escaping HMRequestCallBack){
        
    /*    //1.获取token字典
        guard var params = tokenDict else{
            //如果字典tokenDict为nil,通知调用方token无效
            completion(nil,NSError(domain: "cn.itcast.error" as String, code: -1001, userInfo: ["message":"token为空"]))
            return
        }*/
        //1.创建参数字典
        var params = [String:Any]()
        
        //2.设置参数
        
        params["status"] = status
        
        //3.判断是否上传图片
        if image == nil {
           let urlString = "https://api.weibo.com/2/statuses/update.json"
            //发起网络请求
            tokenRequest(method:.post,URLString: urlString, parameters: params, completion: completion)
            
        } else {
          let  urlString = "https://upload.api.weibo.com/2/statuses/upload.json"
            let data = UIImage.pngData(image!)
            upload(URLString: urlString, data: data()! as NSData, name: "pic", var: params, completion: completion)
        }
        
        
        
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
       
  /*     //1.获取token字典
        guard var params = tokenDict else{
            //如果字典tokenDict为nil,通知调用方token无效
            completion(nil,NSError(domain: "cn.itcast.error" as String, code: -1001, userInfo: ["message":"token为空"]))
            return
        }*/
        //1.创建参数字典
        var params = [String:Any]()
        
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
        tokenRequest(method:.get,URLString: urlString, parameters: params, completion: completion)
    }
}
// MARK: - 用户相关方法
extension NetworkTools{
    ///加载用户信息
    ///see--[https://open.weibo.com/wiki/2/users/show](https://open.weibo.com/wiki/2/users/show)
    func loadUserInfo(uid: String,completion: @escaping HMRequestCallBack){
        
        //1.创建参数字典
        var params = [String:Any]()
  /*      //1.获取用户信息
        guard var params = tokenDict else{
            //如果字典tokenDict为nil,通知调用方token无效
            completion(nil,NSError(domain: "cn.itcast.error" as String, code: -1001, userInfo: ["message":"token为空"]))
            return
        }*/
        
        //2.处理网络参数
        let urlString = "https://api.weibo.com/2/users/show.json"
        params ["uid"] = uid
        tokenRequest(method:.get,URLString: urlString, parameters: params, completion: completion)
        
    }
}

// MARK: - 封装 AFN 网络方法
extension NetworkTools{
    
    
 /*太慢--不理解--后面再看
  //向parameters字典中追加token参数
    //`inout` 是 Swift 中的一个关键字，用于定义一个参数是引用类型，即传递参数时直接传递该变量的内存地址。
    private func appendToken( parameters:inout [String:Any]?) -> Bool{
        
        //判断token是否有效
        guard let token = UserAccountViewModel.sharedUserAccount.account?.access_token else{
            return false
        }
        //判断参数字典是否有值
        if parameters == nil{
            parameters = [String: Any]()
        }
        //设置token
        parameters!["access_token"] = token
        return true
    }
    */
    ///使用token进行网络请求
    ///
    /// - parameter method:     GET / POST
    /// - parameter URLString:  URLString
    /// - parameter parameters: 参数字典
    /// - parameter completion: 完成回调
    private func tokenRequest(method: HTTPMethod, URLString: String,  parameters: [String: Any]?, completion: @escaping HMRequestCallBack){
       
       
        
        
        //1.设置token参数--将token添加到parameters字典中
        //判断token是否有效
        guard let token = UserAccountViewModel.sharedUserAccount.account?.access_token else{
            //如果字典tokenDict为nil,通知调用方token无效
            completion(nil,NSError(domain: "cn.itcast.error" as String, code: -1001, userInfo: ["message":"token为空"]))
            return
        }
        //设置parameters字典
        //将方法参数赋值给局部变量
        var parameters = parameters
        //判断参数字典是否有值
        if parameters == nil{
            parameters = [String: Any]()
        }
        parameters!["access_token"] = token
        //2.发起网络请求
        request(method: method,URLString: URLString, parameters: parameters, completion: completion)
    }
    
    /// 封装 AFN 的 GET / POST 请求
    ///
    /// - parameter method:     GET / POST
    /// - parameter URLString:  URLString
    /// - parameter parameters: 参数字典
    /// - parameter completion: 完成回调

    private func request(method: HTTPMethod, URLString: String, parameters: [String: Any]?, completion: @escaping HMRequestCallBack) {
            
        AF.request(URLString, method: method, parameters: parameters).responseJSON { response in
                
            //判断是否失败
            if let error = response.error {
                print("网络请求失败：\(error.localizedDescription)")
            }
                
            //完成回调
            completion(response.value, response.error)
        }
    
        
        
  /*      // 定义成功回调
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
            */
        
    }
    ///上传文件
    private func upload(URLString: String,data:NSData,name:String,`var` parameters: [String: Any]?, completion: @escaping HMRequestCallBack){
        
        //1.设置token参数--将token添加到parameters字典中
        //判断token是否有效
        guard let token = UserAccountViewModel.sharedUserAccount.account?.access_token else{
            //如果字典tokenDict为nil,通知调用方token无效
            completion(nil,NSError(domain: "cn.itcast.error" as String, code: -1001, userInfo: ["message":"token为空"]))
            return
        }
        //设置parameters字典
        //将方法参数赋值给局部变量
        var parameters = parameters
        //判断参数字典是否有值
        if parameters == nil{
            parameters = [String: Any]()
        }
        parameters!["access_token"] = token
        
        
        //data--要上传文件的二进制数据
        //name--是服务器定义的字段名称 -- 后台接口文档会提示
        //fileName 是保存在服务器的文件名，但是：现在通常可以乱写，后台会做后续处理
          //根据上传的文件，生成缩略图、中等图、高清图
          //保存在不同路径，并自动生成文件名
        //fileName是HTTP协议定义的·属性
        //mimeType/contentType：客户端告诉服务器，二进制数据的准确类型
        //如果不想告诉服务器准确的类型--application/octet-stream
        
        //上传文件--不太成功（先不用了）
//        AF.upload(multipartFormData: { formData in
//
//            //拼接上传文件的二进制数据
//            formData.append(data as Data, withName: name, fileName: "xxx", mimeType: "application/octet-stream")
//
//            //遍历参数字典，生成对应的参数数据
//            if let parameters = parameters {
//                for (key, value) in parameters {
//                    let str = "\(value)"
//                    let strData = str.data(using: .utf8)!
//                    formData.append(strData, withName: key)
//                }
//            }
//
//        }, to: <#T##URLConvertible#>).uploadProgress(queue: .main, closure: { progress in
//            //上传进度回调
//            print("Upload Progress: \(progress.fractionCompleted)")
//        }).validate(statusCode: 200..<300).responseJSON(completionHandler: { response in
//            switch response.result {
//            case .success(let value):
//                print(value)
//            case .failure(let error):
//                print(error)
//            }
//        })
//       post(URLString, parameters: parameters, headers: nil, constructingBodyWith: {(formData) -> Void in
//           formData.appendPart(withFileData: data as Data, name: name, fileName: "xxx", mimeType: "application/octet-stream")
//
//       }, progress: nil, success: {(_,result) -> Void in completion(result,nil)
//
//       }){ (_,error) -> Void in
//           print(error)
//           completion(nil,error)
//
//       }
    }
}
