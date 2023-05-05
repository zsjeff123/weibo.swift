//
//  WelcomeViewController.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/30.
//

import UIKit
import SDWebImage

class WelcomeViewController: UIViewController {
    
    //设置界面，属兔的层次结构
    override func loadView() {
        //直接使用背景图片作为根视图，不用关心图片的缩放问题
        view = backImageView
        //不要漏了加上setupUI方法的调用
        setupUI()
    }

    //视图加载完成后的后续处理，通常用来设置数据
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //异步加载用户头像
        iconView.sd_setImage(with: UserAccountViewModel.sharedUserAccount.avatarURL as URL, placeholderImage: UIImage(named: "avatar_default_big"))

    }
    //显示动画最好用viewDidAppear
    //视图已经显示，通常可以动画/键盘处理
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //1.更新约束，改变位置
        //snp.updateConstraints更新已经设置过的约束
        //如果用multiplier属性为只读属性，创建之后，不允许修改，要用offset
        iconView.snp.updateConstraints{(make) -> Void in
            make.bottom.equalTo(view.snp.bottom).offset(-view.bounds.height + 200)
            
        }
        
        //2.动画
        //动画的嵌套，欢迎Label在头像显示动画后再显示
        welcomeLabel.alpha = 0
        /*
         使用自动布局开发有一个原则：所有使用约束设置的控件，不要再设置‘frame’
         --原因是：自动布局系统会根据设置的约束，自动计算控件的frame
         --在layoutSubviews函数中设置frame
         --如果程序员主动修改frame，会引起自动布局系统计算的错误！
         
         自动布局工作原理：当有一个运行循环启动，自动布局系统，会‘收集’所有的约束变化，
         在运行循环结束前，调用layoutSubviews函数‘统一’设置frame
         ---如果希望某些约束提前更新！使用‘layoutIfNeeded()’函数让自动布局系统，提前更新当前收集的约束变化
         */
        UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options:[],animations: {
            //修改所有“可动画”属性
            //自动布局的动画
            self.view.layoutIfNeeded()
        }){(_) -> Void in
            UIView.animate(withDuration: 0.8, animations: {
                self.welcomeLabel.alpha = 1
            },completion: {(_) in
                print("ok")
                
                //发送通知到AppDelegate
                NotificationCenter.default.post(name: Notification.Name(rawValue: "WBSwitchRootViewControllerNotification"), object: nil)
            })
        }
    }
    
    // MARK:  - 懒加载控件
    //背景图片--用便利构造函数(文件UIImageView)
    private lazy var backImageView: UIImageView = UIImageView.cz_iconViewImage(imageName:"ad_background")
    //头像
    private lazy var iconView: UIImageView = {
        let iv = UIImageView.cz_iconViewImage(imageName: "avatar_default_big")
        //设置头像为圆角
        iv.layer.cornerRadius = 45
        iv.layer.masksToBounds = true
        
        return iv
        
    }()
    //欢迎Label--使用便利构造函数（文件UILabel+Extension）
    private lazy var welcomeLabel: UILabel = UILabel.cz_messagelabel(title: "欢迎归来",fontSize: 18)
}

// MARK:  - 设置页面
extension WelcomeViewController{
    private func setupUI() {
        
        //1.添加控件
        view.addSubview(iconView)
        view.addSubview(welcomeLabel)
        //2.自动布局
        iconView.snp.makeConstraints{(make) -> Void in
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(view.snp.bottom).offset(-200)
            make.width.equalTo(90)
            make.height.equalTo(90)
            
        }
        welcomeLabel.snp.makeConstraints{(make) -> Void in
            make.centerX.equalTo(iconView.snp.centerX)
            make.top.equalTo(iconView.snp.bottom).offset(16)
        }
    }
}
