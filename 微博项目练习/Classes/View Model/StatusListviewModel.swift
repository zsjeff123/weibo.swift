//
//  StatusListviewModel.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/1.
//

import Foundation
import SDWebImage

// MARK: -微博数据列表模型---封装网路方法（字典转模型）

class StatusListViewModel{
    //微博数据数组--上拉/下拉刷新
    //[Status]()-->实例化
    lazy var statusList = [StatusViewModel]()
    
    //加载网络数据
    //闭包
    //isPullup是否上拉刷新
    //completion完成回调
    func loadStatus(isPullup: Bool,completion: @escaping((_ isSuccessed: Bool)->())){
        
        //下拉刷新---数组中第一条微博的id
        let since_id = isPullup ? 0 :(statusList.first?.status.id ?? 0)
        //上拉刷新---数组中最后一条微博的id
        let max_id = isPullup ? (statusList.last?.status.id ?? 0) : 0
        
        NetworkTools.sharedTools.loadStatus (since_id: since_id, max_id: max_id){ result, error in
            
            
            if error != nil{
                print("出错了")
                
                completion(false)
                return
            }
            //判断result的数据结构是否正确
            guard let result = result as? [String: Any],
                  let array = result["statuses"] as? [[String: Any]]
            else {
                print("数据格式错误")
                
                completion(false)
                return
            }
            //遍历字典的数组，字典转模型
            //1.可变的数组
            var dataList = [StatusViewModel]()
            //2.遍历数组
            for dict in array{
                dataList.append(StatusViewModel(status: Status(dict: dict)))
                
            }
            print("刷新到\(dataList.count)")
            
            //3.拼接数据
            //下拉往上拼接，上拉往下
            //判断是否是上拉刷新
            //dataList---新加的数据
            if max_id > 0 {
                self.statusList += dataList
                //即self.statusList + dataList = self.statusList
                
            }else{
                self.statusList = dataList + self.statusList
            }
          
            //完成回调(没加缓存图片时的写法)
            //completion(true)
            
            //缓存单张图片--响应方法
            self.cacheSingleImage(dataList: dataList,completion: completion)
            
        }
    }
    
    ///缓存单张图片的方法
    ///completion上面func loadStatus的闭包传到下面来
    private func cacheSingleImage(dataList: [StatusViewModel],completion: @escaping((_ isSuccessed: Bool)->())){
        
        //调度组---缓存图片---界面更新---计算宽高比
        let group = DispatchGroup()
        //缓存的单张图片的数据长度
        var dataLength = 0
        
        //1.遍历视图模型
        for vm in dataList{
            //1>只缓存单张图片
            //判断是否为单张
            //continue--如果不是1，if就一直循环
            if vm.thumbnailUrls?.count != 1{
                continue
            }
            //2>获取URL
            let url = vm.thumbnailUrls![0]
            print("要缓存的\(url)")
            
            
            //3>下载图片--缓存是自动完成的
            //入组 - 监听后续的block（闭包）
            group.enter()
            
            //SDWebImage的核心下载函数，如果本地缓存已经存在，同样会通过完成回调返回
            SDWebImageManager.shared.loadImage(with: url as URL, options: [SDWebImageOptions.retryFailed, SDWebImageOptions.refreshCached], progress: nil, completed: { (image, _, _, _, _, _) -> Void  in
               
                //单张图片下载完成---计算长度
                //判断image是否为空
                if let img = image, let data = img.pngData(){
                    //累加二进制数据的长度
                   print(data.count)
                    dataLength += data.count
                }
            
                //出组
                //入组出组成对出现
                group.leave()

            })
            
          }
          
        //3.监听调度组完成
        //注意是group，不是DispatchGroup()！！！
       group.notify(queue: DispatchQueue.main) {
            print("缓存完成\(dataLength / 1024) K")
           
           //完成回调--控制器才开始刷新表格
           completion(true)
       }
        
    }
    
   }
    

