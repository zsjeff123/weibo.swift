//
//  StatusViewModel.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/1.
//

import UIKit

///微博视图模型---处理单条微博的业务逻辑
///CustomStringConvertible是Swift标准库中的一个协议，用于提供一种自定义描述对象的方法。
///实现CustomStringConvertible协议的对象可以通过自定义描述方法description返回一个字符串来自定义描述对象。
class StatusViewModel:CustomStringConvertible {
    //微博的模型
    var status: Status
    
    //可重用标识符
    var cellId: String{
        return status.retweeted_status != nil ? StatusCellRetweetedId : StatusCellNormalId
    }
    
    //行高
    lazy  var rowHeight: CGFloat = {
        //1.cell ---定义cell
        var cell: StatusCell
    
        //根据是否是转发微博，决定cell的创建
         //实例化Cell
        if self.status.retweeted_status != nil{
            cell = StatusRetweetedCell(style: .default, reuseIdentifier: StatusCellRetweetedId)
        }else{
            cell = StatusNormalCell(style: .default, reuseIdentifier: StatusCellNormalId)
        }
         //返回行高
         return cell.rowHeight(vm:self)
         
     }()
    
/*  //没有转发微博时的写法
 ///微博首页缓存的行高！！
    //懒加载属性
    //这样向下滚页面会计算，向上回来时已被记住，不计算行高
   lazy  var rowHeight: CGFloat = {
       
      // print("计算缓存行高\(String(describing: self.status.text))")
        //实例化Cell
        let cell = StatusRetweetedCell(style: .default, reuseIdentifier: StatusCellRetweetedId)
        //返回行高
        return cell.rowHeight(vm:self)
        
    }()*/
    
    //微博发布日期 - 计算型属性
    var createAt: String{
        
        return NSDate.sinaDate(string: status.created_at ?? "")!.dateDescription
    }
        
    //用户头像URL
    //头像在user内饰字符串，需要转换为URL才能用
    var userProfileUrl: NSURL{
        return NSURL(string: status.user?.profile_image_url ?? "")!
    }
    //用户默认头像
    var userDefaultsIconView: UIImage{
        return UIImage(named: "avatar_default_big")!
    }
    
    //用户会员图标（可选类型）
    //会员等级0-6
   var userMemberImage: UIImage?{
        //根据mbrank图像
        //先对status.user？.mbrank进行解包，并将解包后的值赋值给mbrank常量。接着判断mbrank是否在0到7之间，不然会出错
        if let mbrank = status.user?.mbrank, mbrank > 0 && mbrank < 7 {
            return UIImage(named: "common_icon_membership_level\(status.user!.mbrank)")
        }
        return nil
    }
    
    //用户认证图标
    //认证类型，-1:没有认证，0，认证用户，2，3，5:企业认证，220:达人
    var userVipImage: UIImage?{
        switch(status.user?.verified_type ?? -1){
        case 0: return UIImage(named: "avatar_vip")
        case 2,3,5: return UIImage(named: "avatar_enterprise_vip")
        case 220: return UIImage(named: "avatar_grassroot")
        default: return nil
        }
    }
    
    //缩略图URL数组--存储型属性！！！
    //如果是原创微博，可以有图，可以没有图
    //如果是转发微博，一定没有图，retweeted_status中，可以有图，也可以没有图
    //一条微博，最多只有一个pic_urls
    var thumbnailUrls: [NSURL]?
    
    //被转发原创微博的文字
    var retweetedText: String?{
        //1.判断是否转发微博，如果没有，则直接返回nil
        guard let s = status.retweeted_status else {
            return nil
        }
        //2.s就是转发微博，text为转发微博的文字内容
        return "@" + (s.user?.screen_name ?? "") + ":" + (s.text ?? "")
    }
    
    
    //构造函数--保证模型的参数是必选的
    init(status: Status) {
        self.status = status
        
        //根据模型，来生成缩略图的数组
        //转发微博的图片优先级高
        if let urls = status.retweeted_status?.pic_urls ?? status.pic_urls{            //创建缩略图数组
            thumbnailUrls = [NSURL]()
            //遍历字典数组 -> 数组如果可选，不允许遍历，原因：数组是通过下标来检索数据,nil不能检索
            //遍历字典数组
            for dict in urls{
                //因为字典是按照key来取值，如果key错误，会返回nil
                let url = NSURL(string: dict["thumbnail_pic"]!)
                //相信服务器返回的URL字符串一定能生成
                thumbnailUrls?.append(url!)
            }
        }
    }
    
    //描述信息
    //用于首页的配图显示
    var description: String{
        return status.description + "配图数组\(thumbnailUrls ?? [] as NSArray as! [NSURL])"
    }
}
