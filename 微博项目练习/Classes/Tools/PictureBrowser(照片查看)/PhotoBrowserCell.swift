//
//  PhotoBrowserCell.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/11.
//

import UIKit
import SDWebImage
import SVProgressHUD

//代理--实现关闭照片查看控制器
protocol PhotoBrowserCellDelegate: NSObjectProtocol{
    //视图控制器将要关闭
    func photoBrowserCellShouldDismiss()
    //通知代理缩放的比例
    func photoBrowserCellDidZoom(scale:CGFloat)
}

//照片查看Cell
class PhotoBrowserCell: UICollectionViewCell {
    
    //代理
    weak var photoDelegate: PhotoBrowserCellDelegate?
    
    //MARK: - 监听方法
    @objc private func tapImage(){
        
        photoDelegate?.photoBrowserCellShouldDismiss()
    }
    
    //手势识别是对touch的一个封装，uiscrollview支持捏合手势，一般做过手势监听的控件，都会屏蔽掉touch事件  -- 下面的方法用不了
  //  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
   // }
    
    //MARK: - 图像地址
  
    var imageURL:NSURL?{
        didSet{
            guard let url = imageURL else{
                return
            }
            
            //1.得到缩略图---url缩略图的地址
            //1>从磁盘加载缩略图的图像
            //placeholder占位图像
           let placeholderImage =  SDImageCache.shared.imageFromCache(forKey: url.absoluteString)
            
            
       /*     imageView.image  = placeholder
            //2>设置大小
            imageView.sizeToFit()
            //3>设置中心点
            imageView.center = scrollView.center
        */
            
            setPlaceHolder(image: placeholderImage)
            
            //2.异步加载大图
            //sdwebimage有一个功能，一旦设置了URL，准备异步加载---清楚之前的图片/如果之前的图片也是异步加载，但是没有完成，取消之前的异步操作！
            //如果url对应的图像已经被缓存，直接从磁盘读取，不会再走网络加载
            //几乎所有的第三方框架，进度回调都是异步的
            imageView.sd_setImage(with: bmiddleURL(url: url as URL), placeholderImage: nil, options: [SDWebImageOptions.retryFailed,SDWebImageOptions.refreshCached], progress:{ (current, total, _) in
                //更新进度--圆在慢慢被填充的动画
                DispatchQueue.main.async { ()->Void in
                    self.placeHolder.progress  = CGFloat(current) / CGFloat(total)
                }
                
            }){(image, _, _, _) in
                //判断图像下载是否成功
                if image == nil{
                    SVProgressHUD.showInfo(withStatus: "您的网络不给力")
                }
                //隐藏占位图像
                self.placeHolder.isHidden = true
                //设置图像视图位置
               self.setPosition(image: image!)
            }
            
            
      //      imageView.sd_setImage(with: bmiddleURL(url: url as URL)){(image, _, _, _) in
                
                //设置图像视图位置
        //        self.setPosition(image: image!)
           // }
        }
    }
    
    //设置占位图像视图的内容
    //image---本地缓存的缩略图，如果缩略图下载失败，image为nil
    private func setPlaceHolder(image: UIImage?){
        //显示占位视图
        placeHolder.isHidden = false
        //设置占位视图的图像、位置和尺寸
        placeHolder.image = image
        placeHolder.sizeToFit()
        placeHolder.center  = scrollView.center
    }
    
    
    //重设scrollView内容属性--因为放大图片scrollview的cell会有可能被重用（transform变化导致）
    private func resetScrollView(){
        //重设imageView的transform属性
        imageView.transform = CGAffineTransformIdentity
        //重设scrollView的属性
        //contentInset` 是 UIScrollView 类的一个属性，用于设置滚动视图的内容区域的内边距
        //contentOffset 是 UIScrollView 类的一个属性，用于设置或获取滚动视图内容区域的偏移量
        //`contentSize` 是 UIScrollView 类的一个属性，用于设置或获取滚动视图内容区域的大小
        scrollView.contentInset  = UIEdgeInsets.zero
        scrollView.contentOffset  = CGPoint.zero
        scrollView.contentSize = CGSize.zero
        

    }
    
    //设置imageView的位置 ---居中显示
    private func setPosition(image: UIImage){
        //自动调整大小--计算的大小
        let size = self.displaySize(image: image)
        //判断图片的高度!!
        if size.height < scrollView.bounds.height{
            //上下居中显示
            imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            //内容边距 -- 会调整控件位置，但是不会影响控件的滚动！！（防止缩放后有些地方滚动看不到）
            let y = (scrollView.bounds.height - size.height) * 0.5
            scrollView.contentInset = UIEdgeInsets(top: y, left: 0, bottom: 0, right: 0)
        }else{   //较长图片
            imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            //跟图片一样大就行
            scrollView.contentSize = size
            
        }
        
        
            }
    
    //根据scrollview的宽度计算等比例缩放之后的图片尺寸
    private func displaySize(image: UIImage) -> CGSize {
        let w = scrollView.bounds.width
        let h = image.size.height * w / image.size.width
        return CGSize(width: w, height: h)
     }
    
    ///返回中等尺寸图片URL -- bmiddleurl
    ///url----缩略图url
    ///returns--中等尺寸URL
    private func bmiddleURL(url: URL) -> URL{
        //1.转换成string
        var urlString = url.absoluteString
        //2.替换string（URL·中的）单词 -- 自己接结果
        urlString = urlString.replacingOccurrences(of: "/thumbnail/", with: "/bmiddle/")
        return URL(string: urlString)!
    }
    
    
    //MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        //1.添加控件
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(placeHolder)
        //2.设置位置
        var rect = bounds
        rect.size.width -= 20
        scrollView.frame = rect
        
       //3.设置scrollview缩放
        scrollView.delegate = self
        scrollView.minimumZoomScale  = 0.5
        scrollView.maximumZoomScale = 2.0
        
        //4.添加手势识别
        let tap = UITapGestureRecognizer(target: self, action:#selector(tapImage) )
        //imageView默认不支持用户交互--要设置
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }
    
    
    //MARK: - 懒加载控件
  lazy var scrollView:UIScrollView = UIScrollView()
  lazy var imageView:UIImageView  = UIImageView()
    
    //占位图像
    private lazy var placeHolder:ProgressimageView = ProgressimageView()
}


//MARK: - UIScrollViewDelegate
extension PhotoBrowserCell:UIScrollViewDelegate{
    
    //返回被缩放的视图--实质是通过transform来设置的
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    //缩放完成后执行一次
    //view--被缩放的视图
    //scale -- 被缩放的比例
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        //如果缩放比例 < 1，直接关闭
        if scale < 1 {
            photoDelegate?.photoBrowserCellShouldDismiss()
            return
        }
        var offsetY = (scrollView.bounds.height - view!.frame.height) * 0.5
        //如果offsetY小于0，说明图片Y值超出屏幕最大值，此时让offsetY为0
        offsetY = offsetY < 0 ? 0 : offsetY
         
        var offsetX = (scrollView.bounds.width - view!.frame.width) * 0.5
        //如果offsetX小于0，说明图片X值超出屏幕最大值，此时让offsetX为0
        offsetX = offsetX < 0 ? 0 : offsetX
        
        //设置间距
        //让放大的图片位置在左上角
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetY, bottom: 0, right: 0)
    }
    
    //只要缩放就会被调用
    /*
      a d ==> 缩放比例
      a b c d ==> 共同决定旋转
     tx ty ==> 设置位移
     定义控件位置 frame = center + bounds * transform
      */
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
         //通知代理缩放的比例
        photoDelegate?.photoBrowserCellDidZoom(scale: imageView.transform.a)
    }
}
