//
//  NewFeatureViewController.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/30.
//

import UIKit
import SnapKit

///可重用Cell Id
private let WBNewFeatureViewCellId = "WBNewFeatureViewCellId "
///新特性图像的数量
private let WBNewFeatureImageCount = 4

class NewFeatureViewController: UICollectionViewController {
    
    // MARK: - 构造函数
    init(){
        //super.指定的构造函数
        //不要漏了Flow
        //用不了懒加载，懒加载属性必须要在控制器实例化之后才会被创建
        let layout = UICollectionViewFlowLayout()
        //设置每个单元格
        layout.itemSize = UIScreen.main.bounds.size
        layout.minimumInteritemSpacing = 0 //设置单元格的兼具为0
        layout.minimumLineSpacing = 0   //设置行间距为0
        layout.scrollDirection = .horizontal  //设置滚动方向是横向
        //构造函数，完成后内部属性才会被创建
        super.init(collectionViewLayout: layout)
        collectionView?.isPagingEnabled = true //开启分页
        collectionView?.bounces = false   //去掉弹簧效果
        //去掉水平方向上的滚动条
        collectionView?.showsHorizontalScrollIndicator = false
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //当该值为 true 时，状态栏（上面显示时间的栏）将被隐藏。当该值为 false 时，状态栏将被显示。
    //注意，在实现这个属性时，你需要按照属性的格式而不是方法的格式进行重写
    //推荐隐藏状态栏，可以每个控制器分别设置，默认是NO（显示）
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //注册可重用Cell
        self.collectionView!.register(NewFeatureCell.self, forCellWithReuseIdentifier: WBNewFeatureViewCellId)
        
        
    }
    
    
    
    //返回每个分组中，格子的数量
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return WBNewFeatureImageCount
    }
    //Cell方法：返回每个单元格
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WBNewFeatureViewCellId, for: indexPath) as!NewFeatureCell
        
        // Configure the cell
        cell.imageIndex = indexPath.item
        
        return cell
    }
    //scrollview停止滚动的方法
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //在最后一页才调用动画方法
        //根据contentOffset计算页数
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        //判断是否为最后一页
        if page != WBNewFeatureImageCount - 1{
            return
        }
        //Cell播放动画
        if let cell = collectionView?.cellForItem(at: IndexPath(item: page, section: 0)) as? NewFeatureCell {
            // 执行cell的动画
            //显示动画
            cell.showButtonAnim()
        }
    }
}
    // MARK: -新特性cell的类，私有
    private class NewFeatureCell : UICollectionViewCell{
        
        ///图像属性
        var imageIndex: Int = 0{
            didSet{
                iconView.image = UIImage(named: "new_feature_\(imageIndex + 1)")
                
                //隐藏按钮
                startButton.isHidden = true
            }
        }
        
    
        
        //监听方法
        //点击开始体验按钮--进行页面跳转到主页面
        @objc private func clickStartButton(){
            print("开始体验")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "WBSwitchRootViewControllerNotification"), object: nil)
        }
        //显示按钮动画
        func showButtonAnim(){
            //显示按钮
            startButton.isHidden = false
            
            startButton.transform = CGAffineTransformMakeScale(0, 0)
            //禁用startButton按钮的用户交互功能，使其无法响应用户操作
            startButton.isUserInteractionEnabled = false
            /*注释：
             UIView.animate(withDuration: 1.6,  //动画时长
             delay: 0,           //动画延时
             usingSpringWithDamping: 0.6,  //弹力系数，0-1，越小越弹
             initialSpringVelocity: 10,    //初始速度，模拟重力加速度
             options: [],       //动画选项
             animations: {() -> Void in
             self.startButton.transform = CGAffineTransform.identity
             }){(_) -> Void in
             print("ok")
             self.startButton.isUserInteractionEnabled = true
             }*/
            UIView.animate(withDuration: 1.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10,options: [], animations: {() -> Void in
                self.startButton.transform = CGAffineTransform.identity
            }) {(_) -> Void in
                print("ok")
                self.startButton.isUserInteractionEnabled = true
            }
        }
        
        //重写指定的构造函数
        //frame的大小是.layout.itemSize指定的
        override init(frame: CGRect){
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI(){
            //1.添加控件
            addSubview(iconView)
            addSubview(startButton)
            //不能单独在这里设置隐藏
            //startButton.isHidden = true
            
            //2.指定位置
            iconView.frame = bounds
            //自动布局开始体验按钮的尺寸
            startButton.snp.makeConstraints{(make) -> Void in
                make.centerX.equalTo(self.snp.centerX)
                make.bottom.equalTo(self.snp.bottom).multipliedBy(0.7)
            }
            //3.监听方法调用
            startButton.addTarget(self, action: #selector(NewFeatureCell.clickStartButton), for: .touchUpInside)
        }
        // MARK: -懒加载控件
        ///加载图像
        private lazy var iconView: UIImageView = UIImageView()
        
        ///开始体验按钮
        ///cz_RLbutton自己设置的便利构造函数---在<UIButton+Extension>文件里
        private lazy var startButton: UIButton = UIButton.cz_RLbutton(title:"开始体验",color: UIColor.white,imageName:"new_feature_finish_button")
    }

