//
//  PhotoBrowserAnimaton.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/12.
//

import UIKit

//MARK: - 展现动画协议
protocol PhotoBrowserPresentDelegate: NSObjectProtocol{
    
    //指定 indexpath 对应的 imageview 用来做转场动画效果
    func imageViewForPresent(indexPath: NSIndexPath) -> UIImageView
    
    //动画转场的起始位置
    func photoBrowserPresentFromRect(indexPath: NSIndexPath) ->CGRect
    
    //动画转场的目标位置
    func  photoBrowserPresentToRect(indexPath: NSIndexPath) ->CGRect
}

//MARK: - 解除动画协议
protocol PhotoBrowserDismissDelegate: NSObjectProtocol{
    
    //解除转场的图像视图（包含了解除动画的起始位置）
    func imageViewForDismiss() -> UIImageView
    
    //解除转场的图像索引
    func indexPathForDismiss() -> NSIndexPath
}

//提供动画转场的代理---“相关方法”
class PhotoBrowserAnimator: NSObject,UIViewControllerTransitioningDelegate {
    
    //展现动画的代理
    weak var presentDelegate: PhotoBrowserPresentDelegate?
    //解除动画的代理
    weak var dismissDelegate: PhotoBrowserDismissDelegate?
    
    
    //动画图像的索引
    var indexPath: NSIndexPath?

    
    //是modal/dismiss展现的标记
    private var isPresented = false
    
    //设置代理相关参数/属性
    //presentDelegate--展现代理的对象
    //indexPath--图像索引
    func setDelegateParams(presentDelegate:PhotoBrowserPresentDelegate,indexPath:NSIndexPath,dismissDelegate:PhotoBrowserDismissDelegate){
        
        self.presentDelegate = presentDelegate
        self.dismissDelegate = dismissDelegate
        self.indexPath = indexPath
        
        
    }
    
    //返回提供 modal 展现的“动画的对象”，这里是self
    //要遵循协议--UIViewControllerAnimatedTransitioning
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresented = true
        
        return self
    }
    
    //返回提供 dismiss 展现的“动画的对象”，这里是self
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresented = false
        
        return self
    }
}


//MARK: - UIViewControllerAnimatedTransitioning
//实现具体的动画方法
extension PhotoBrowserAnimator:UIViewControllerAnimatedTransitioning{
    
    //动画时长
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.3
    }
    
    //实现具体的动画效果--一旦实现了此方法，所有的动画代码都交由程序员负责，其他默认动画会没有
    // transitionContext转场动画的上下文 - 提供动画所需要的素材
    //1.容器视图--containerview--会将modal要展现的视图包装再容器视图中!!!!
    //存放的视图要显示 -- 必须自己指定大小！不会通过自动布局填满屏幕
    //2.viewController(forKey:  fromVC/ toVC
    //3.view(forKey:  fromview/toView
    //4.completeTransition一定调用，无论转场是否被取消，都必须调用，否则，系统不做别的事处理
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        
        //自动布局系统不会对根视图做任何约束
//        let v = UIView(frame: UIScreen.main.bounds)
//        v.backgroundColor = UIColor.red
        
        //MainViewController --> PhotoBrowserViewController
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        print(fromVC as Any)
        //PhotoBrowserViewController ---> MainViewController
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        print(toVC as Any)
        
        //上面对应的view
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        print(fromView  as Any)
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        print(toView as Any)
       
        isPresented ? presentAnimation(transitionContext: transitionContext) : dismissAnimation(transitionContext: transitionContext)
    }
    
    ///解除转场动画
    private func dismissAnimation(transitionContext: UIViewControllerContextTransitioning){
        
        guard let presentDelegate = presentDelegate, let dismissDelegate = dismissDelegate else{
            return
        }
        
        //1.获取要 dismiss 的控制器的视图
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        //将fromView(显示的那个大图) 从父视图中删除
        fromView?.removeFromSuperview()
        
        //2.获取图像视图
        let iv = dismissDelegate.imageViewForDismiss()
        //添加到容器视图
        transitionContext.containerView.addSubview(iv)
        
        //3.获取dismiss的indexpath
        let indexPath = dismissDelegate.indexPathForDismiss()
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),animations:{ () -> Void in
            
            //让iv运动到目标位置
            iv.frame = presentDelegate.photoBrowserPresentFromRect(indexPath: indexPath)
            
        }){(_) -> Void in
           
            //将iv从父视图中删除
            iv.removeFromSuperview()
            //告诉系统---转场动画完成
            transitionContext.completeTransition(true)
        }
        
    }
    
    
    ///展现动画
    private func presentAnimation(transitionContext: UIViewControllerContextTransitioning){
        
        //判断参数是否存在
        guard let presentDelegate = presentDelegate,let indexPath = indexPath else{
            return
        }
        
        //1.目标视图
        //1>获取modal要展现的控制器的根视图
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        //2>将视图添加到容器视图中
        transitionContext.containerView.addSubview(toView)
        
        //2.获取目标控制器 - 照片查看控制器
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! PhotoBrowserViewController
        //隐藏collectionview
        toVC.collectionView.isHidden = true
        
        //3.图像视图
        //能够拿到参与动画的图像视图/起始位置/目标位置
        //1>获得图像视图
        let iv = presentDelegate.imageViewForPresent(indexPath: indexPath)
        //2>指定图像视图位置
        iv.frame = presentDelegate.photoBrowserPresentFromRect(indexPath: indexPath)
        //3>将图像视图添加到容器视图
        transitionContext.containerView.addSubview(iv)
        
        toView.alpha = 0
        
        //4.开始动画
        //transitionContext--上下文承接
        UIView.animate(withDuration: transitionDuration(using: transitionContext),animations:{ () -> Void in
            
            iv.frame = presentDelegate.photoBrowserPresentToRect(indexPath: indexPath)
            toView.alpha  = 1
        }){(_) -> Void in
            //将图像视图删除
            iv.removeFromSuperview()
            
            //显示目标视图控制器的collectionview
            toVC.collectionView.isHidden = false
            
            //告诉系统---转场动画完成
            transitionContext.completeTransition(true)
        }
        
        
    }
}
