//
//  VisitorView.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/25.
//

import UIKit
import SnapKit
/*访客视图的协议(代理)
protocol VisitorViewDelegate : NSObjectProtocol{
   ///注册
    func visitorViewDidRegister()
    ///登录
    func visitorViewDidLogin()
}*/

//访客视图-处理用户未登录的界面显示
class VisitorView: UIView {
    
    ///定义代理(一定是弱引用)--不太会
   // weak var delegate : VisitorViewDelegate?
    // MARK: - 监听方法
    /*
    /// 用户注册监听方法
    @objc private func clickRegister() {
        print("用户注册")
    }
    /// 用户登录监听方法
    @objc private func clickLogin() {
        print("用户登录")
    }*/
    // MARK: - 生命周期与部分设置
    //initwithframe是UIView的指定构造函数
    //使用纯代码开发使用的
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       setUI()
    }
    //initwithframe方法附带方法--使用storyboard & XIB 开发加载的函数
    required init?(coder: NSCoder) {
        //不要storyboard
        fatalError("init(coder:) has not been implemented")
    }
   
    //imageName：图片名称。  首页设置为nil（用了可选）  title:消息文字
    func setupInfo(imageName:String?,title:String){
        //设置消息Label的文字
        messageLabel.text = title
        //如果图片名称为nil,说明是首页，直接返回
        guard let imgeName = imageName else{
            //播放动画
            startAnim()
            
            return
        }
        iconView.image = UIImage(named: imgeName)
        //隐藏小房子
        houseIconView.isHidden = true
        //将遮罩图像移动到底层
        sendSubviewToBack(maskIconView)
        
    }
    ///开启首页转轮动画
    private func startAnim() {
        //核心动画旋转
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        //2 * Double.pi表示一个圆的周长
        anim.toValue = 2 * Double.pi
        //不停转（无限循环）,MAXFLOAT代表无穷
        anim.repeatCount = MAXFLOAT
        //动画时长
        anim.duration = 20
        
        // 动画完成不删除，如果 iconView 被释放，动画会一起销毁！
        // 在设置连续播放的动画非常有用！
        //让动画无论退出界面与否一直播放
        anim.isRemovedOnCompletion = false
        
        // 将动画添加到首页nil图层
        iconView.layer.add(anim, forKey: nil)
    }
    
    
    
    
    
    // MARK: - 私有控件
        /// 懒加载属性只有调用 UIKit 控件的指定构造函数，其他都需要使用类型
  ///图像视图
    private var iconView : UIImageView = UIImageView.cz_iconViewImage(imageName: "visitordiscover_feed_image_smallicon")
    ///小房子
     private var  houseIconView : UIImageView = UIImageView.cz_iconViewImage(imageName: "visitordiscover_feed_image_house")
    ///遮罩图像
    private var maskIconView : UIImageView = UIImageView.cz_iconViewImage(imageName: "visitordiscover_feed_mask_smallicon")
    /*未用便利构造函数
    /// 图像视图,imageView默认image大小
    private var iconView : UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_smallicon"))
       
    /// 小房子
    private var houseIconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_house"))
        
    /// 遮罩图像 - 不要使用 maskView(因为系统用这个--是内置的)
    private var maskIconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_mask_smallicon"))
    */
   ///消息文字
    private var messageLabel : UILabel = UILabel.cz_messagelabel(title: "关注一些人，回这里看看有什么惊喜")
    
    /*消息文字(未用便利构造函数)
    private var messageLabel: UILabel = {
       let label = UILabel()
        
        label.text="关注一些人，回这里看看有什么惊喜"
        //界面设计避免使用纯黑色
        label.textColor = UIColor.darkGray
        //字体大小
        label.font = UIFont.systemFont(ofSize: 14)
        //可换行(要加自动布局的宽高来实现)
        label.numberOfLines = 0
        //文本居中对齐
        label.textAlignment = NSTextAlignment.center
        
        return label
   }()*/
    ///注册按钮
     var registerButton : UIButton = UIButton.cz_RLbutton(title: "注册", color: UIColor.orange, imageName: "common_button_white_disable")
    ///登录按钮
     var loginButton : UIButton = UIButton.cz_RLbutton(title: "登录", color: UIColor.darkGray, imageName: "common_button_white_disable")
    /*未用便利构造函数的正常设置按钮方法
    ///注册按钮
    private var registerButton: UIButton = {
        let button = UIButton()
        //设置普通状态下按钮文字
        button.setTitle("注册", for: UIControl.State.normal)
        //设置普通状态下按钮文字颜色
        button.setTitleColor(UIColor.orange, for: UIControl.State.normal)
        //设置普通状态下按钮的背景图片
        button.setBackgroundImage(UIImage(named: "common_button_white_disable"),for: UIControl.State.normal)
        return button
    }()
    ///登录按钮
    private var loginButton: UIButton = {
        let button = UIButton()
        //设置普通状态下按钮文字
        button.setTitle("登录", for: UIControl.State.normal)
        //设置普通状态下按钮文字颜色
        button.setTitleColor(UIColor.darkGray, for: UIControl.State.normal)
        //设置普通状态下按钮的背景图片
        button.setBackgroundImage(UIImage(named: "common_button_white_disable"),for: UIControl.State.normal)
        return button
    }()*/
}
// MARK: - 访客页面设置
extension VisitorView{
    ///设置页面
    private func setUI(){
        // 1. 添加控件
        addSubview(iconView)
        addSubview(maskIconView)
        addSubview(houseIconView)
        addSubview(messageLabel)
        addSubview(registerButton)
        addSubview(loginButton)
        /*2.设置自动布局:
         --添加约束需要添加到父视图
         --子视图最好有统一的参照物
         */
        //translatesAutoresizingMaskIntoConstraints 默认是true，支持使用setFrame的方式设置控件位置，false支持使用自动布局设置
        //  取消 autoresizing,false 支持使用自动布局来设置控件位置,subviews为页面视图
        /*for v in subviews {
         v.translatesAutoresizingMaskIntoConstraints = false
         }*/
        // 1> 图像视图
        //snapkit写法
        //make可理解为要添加的约束对象
        iconView.snp.makeConstraints{(make) -> Void in
            //指定centerX属性：等于‘参照对象’.snp.‘参照属性值’
            //offset指定相对视图的偏移量
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY).offset(-60)
        }
        /*自动布局写法
         addConstraint(NSLayoutConstraint(item: iconView,
         attribute: .centerX,
         relatedBy: .equal,
         toItem: self,
         attribute: .centerX,
         multiplier: 1.0,
         constant: 0))
         addConstraint(NSLayoutConstraint(item: iconView,
         attribute: .centerY,
         relatedBy: .equal,
         toItem: self,
         attribute: .centerY,
         multiplier: 1.0,
         constant: -60))
         */
        // 2> 小房子
        //snapkit写法
        houseIconView.snp.makeConstraints{(make) -> Void in
            make.center.equalTo(iconView.snp.center)
            
        }
        /*自动布局写法
         addConstraint(NSLayoutConstraint(item: houseIconView,
         attribute: .centerX,
         relatedBy: .equal,
         toItem: iconView,
         attribute: .centerX,
         multiplier: 1.0,
         constant: 0))
         addConstraint(NSLayoutConstraint(item: houseIconView,
         attribute: .centerY,
         relatedBy: .equal,
         toItem: iconView,
         attribute: .centerY,
         multiplier: 1.0,
         constant: 0))
         */
        // 3> 提示标签
        //snapkit写法
        messageLabel.snp.makeConstraints{(make) -> Void in
            make.centerX.equalTo(iconView.snp.centerX)
            make.top.equalTo(iconView.snp.bottom).offset(16)
            make.width.equalTo(224)
            make.height.equalTo(36)
            
        }
            
            /*自动布局写法
             addConstraint(NSLayoutConstraint(item: messageLabel,
             attribute: .centerX,
             relatedBy: .equal,
             toItem: iconView,
             attribute: .centerX,
             multiplier: 1.0,
             constant: 0))
             addConstraint(NSLayoutConstraint(item: messageLabel,
             attribute: .top,
             relatedBy: .equal,
             toItem: iconView,
             attribute: .bottom,
             multiplier: 1.0,
             constant: 16))
             addConstraint(NSLayoutConstraint(item: messageLabel,
             attribute: .width,
             relatedBy: .equal,
             toItem: nil,
             attribute: .notAnAttribute,
             multiplier: 1.0,
             constant: 236))
             addConstraint(NSLayoutConstraint(item: messageLabel,
             attribute: .height,
             relatedBy: .equal,
             toItem: nil,
             attribute: .notAnAttribute,
             multiplier: 1.0,
             constant: 36))
             */
            // 4> 注册按钮
            //snapkit写法
            registerButton.snp.makeConstraints{(make) -> Void in
                make.left.equalTo(messageLabel.snp.left)
                make.top.equalTo(messageLabel.snp.bottom).offset(16)
                make.width.equalTo(100)
                make.height.equalTo(36)
            }
            /*自动布局写法
             addConstraint(NSLayoutConstraint(item: registerButton,
             attribute: .left,
             relatedBy: .equal,
             toItem: messageLabel,
             attribute: .left,
             multiplier: 1.0,
             constant: 0))
             addConstraint(NSLayoutConstraint(item: registerButton,
             attribute: .top,
             relatedBy: .equal,
             toItem: messageLabel,
             attribute: .bottom,
             multiplier: 1.0,
             constant: 16))
             addConstraint(NSLayoutConstraint(item: registerButton,
             attribute: .width,
             relatedBy: .equal,
             toItem: nil,
             attribute: .notAnAttribute,
             multiplier: 1.0,
             constant: 100))
             addConstraint(NSLayoutConstraint(item: registerButton,
             attribute: .height,
             relatedBy: .equal,
             toItem: nil,
             attribute: .notAnAttribute,
             multiplier: 1.0,
             constant: 36))
             */
            // 5> 登录按钮
            //snapkit写法
            loginButton.snp.makeConstraints{(make) -> Void in
                make.right.equalTo(messageLabel.snp.right)
                make.top.equalTo(registerButton.snp.top)
                make.width.equalTo(registerButton.snp.width)
                make.height.equalTo(registerButton.snp.height)
            }
            /*自动布局写法
             addConstraint(NSLayoutConstraint(item: loginButton,
             attribute: .right,
             relatedBy: .equal,
             toItem: messageLabel,
             attribute: .right,
             multiplier: 1.0,
             constant: 0))
             addConstraint(NSLayoutConstraint(item: loginButton,
             attribute: .top,
             relatedBy: .equal,
             toItem: messageLabel,
             attribute: .bottom,
             multiplier: 1.0,
             constant: 16))
             addConstraint(NSLayoutConstraint(item: loginButton,
             attribute: .width,
             relatedBy: .equal,
             toItem: nil,
             attribute: .width,
             multiplier: 1.0,
             constant: 100))
             addConstraint(NSLayoutConstraint(item: loginButton,
             attribute: .height,
             relatedBy: .equal,
             toItem: nil,
             attribute: .width,
             multiplier: 1.0,
             constant: 36))
             */
            // 6> 遮罩图像
        //snapkit写法
        maskIconView.snp.makeConstraints{(make) -> Void in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.bottom.equalTo(registerButton.snp.bottom)
        }
        
            /* VFL可视化语言来写
             H：水平方向    V：垂直方向     ｜ ：边界   []：包装边界
             */
            // views: 是字典，【名字：控件名，】定义 VFL 中的控件名称和实际名称映射关系
            // metrics: 是字典，【名字：NSNumber】定义 VFL 中 () 指定的常数(某数值)影射关系
    /*        let viewDict = ["maskIconView": maskIconView,
                            "registerButton": registerButton]
            let metric = ["spacing": -36]
            
            addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[maskIconView]-0-|",
                options: [],
                metrics: nil,
                views: viewDict))
            addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[maskIconView]-(spacing)-[registerButton]",
                options: [],
                metrics: metric,
                views: viewDict))
     */
            ///设置背景颜色来填充空白
            ///苹果电脑--实用工具--数码测色计--显示原生值
            ///灰度图 R = G = B ，在UI元素中，大多数都使用灰度图，或者纯色图（安全色）
            backgroundColor = UIColor(white: 237.0/255.0, alpha: 1.0)
            
            
        }
    }
