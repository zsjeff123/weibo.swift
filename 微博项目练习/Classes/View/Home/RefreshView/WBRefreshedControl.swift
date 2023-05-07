//
//  WBRefreshedControl.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/5.
//

import UIKit

///下拉刷新控件偏移量
private let WBRefreshContrilOffset: CGFloat = -60

///自定义XIB加载刷新控件--负责处理“刷新逻辑”
class WBRefreshedControl: UIRefreshControl {
   
    // MARK: - 重写系统方法
    //刷新完后关闭动画
    override func endRefreshing() {
        super.endRefreshing()
        //停止动画
        refreshView.stopAnimation()
    }
    //主动触发开始刷新动画 - 不会触发监听方法
    override func beginRefreshing() {
        super.beginRefreshing()
        //开始动画
        refreshView.startAnimation()
    }
    
    // MARK: - KVO监听方法（主线程异步）--重要
    //frame下拉y一直变小，向上变大
    //默认y为0
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if frame.origin.y > 0{
            return
        }
        //判断是否正在刷新
        if isRefreshing{
            refreshView.startAnimation()
            return
        }
        
        if frame.origin.y < WBRefreshContrilOffset && !refreshView.rotateFlag{
            print("反过来")
            refreshView.rotateFlag = true
            
        }else if frame.origin.y >= WBRefreshContrilOffset && refreshView.rotateFlag{
            print("转过来")
                refreshView.rotateFlag = false
           
        }
        //print(frame)
    }
  
    // MARK: - 构造函数--调用函数
    //无论XIB或storyboard都可以使用控件
    override init() {
        super.init()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init()
        setupUI()
    }
    
    // MARK: - 界面设置
    private func setupUI(){
        //隐藏圆圈图片
        tintColor = UIColor.clear
        //添加控件
        addSubview(refreshView)
       
        //自动布局--从“XIB加载的控件”需要指定大小约束-- size
        refreshView.snp.makeConstraints{(make) -> Void in
            make.center.equalTo(self.snp.center)
            make.size.equalTo(refreshView.bounds.size)
            
        }
        //使用KVO监听位置变化--位置：frame
        //利用多线程控制控件下拉上拉才调用KVO！！！
        //主队列--当主线程有任务，就不调度队列中的任务执行
        //主线程就是加载首页的一些东西！！
        //让当前运行循环中所有代码执行完毕后，运行循环结束前---开始监听
        //方法触发在下一次运行循环开始
        //主线程异步执行---让 addObserver(_:forKeyPath:options:context:) 方法在主线程上异步执行，以避免堵塞 UI 线程
        DispatchQueue.main.async {
            self.addObserver(self, forKeyPath: "frame", options: [], context: nil)
        }
        
        
    }
    //释放KVO(删除KVO监听方法)
    deinit{
        self.removeObserver(self, forKeyPath: "frame")
    }
    
    
    // MARK: - 懒加载控件
    private lazy var refreshView = WBRefreshedView.refreshView()
    
}

///刷新视图---负责处理“动画显示”
class WBRefreshedView: UIView{
    
    ///旋转标记
    var rotateFlag = false{
        didSet{
            rotateTipIcon()
        }
    }
    
    @IBOutlet weak var loadingIconView: UIImageView!
    @IBOutlet weak var tipView: UIView!
    
    @IBOutlet weak var tipIconView: UIImageView!
    
    //从XIB加载视图
    class func refreshView() -> WBRefreshedView{
        //推荐使用UINib的方法加载XIB
        let nib = UINib(nibName: "WBRefreshView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! WBRefreshedView
    }
    
    //旋转图标动画
    func rotateTipIcon(){
        
        //来适应“就近原则”
        var angle = CGFloat(Double.pi)
        angle += rotateFlag ? -0.0000001 : 0.0000001
        
        //旋转动画---特点：顺时针优先 + “就近原则”--动画实现效果来选择显示效果
        //指定了180度旋转动画
        UIView.animate(withDuration: 0.5) { () -> Void in
            self.tipIconView.transform = CGAffineTransformRotate(self.tipIconView.transform, CGFloat(angle))
        }
        
    }
    
    //播放加载动画
  func startAnimation(){
       
      tipView.isHidden = true
      //判断动画是否已经被添加
      let key = "transform.rotation"
      if loadingIconView.layer.animation(forKey: key) != nil{
          return
      }
      print("加载动画播放")
      //设置动画
        let anim = CABasicAnimation(keyPath: key)
        anim.toValue = 2 * Double.pi
        anim.repeatCount = MAXFLOAT
        anim.duration = 2
        anim.isRemovedOnCompletion = false
        loadingIconView.layer.add(anim,forKey:key)
    }
    //停止加载动画
     func stopAnimation(){
        tipView.isHidden = false
        loadingIconView.layer.removeAllAnimations()
        
    }
}
