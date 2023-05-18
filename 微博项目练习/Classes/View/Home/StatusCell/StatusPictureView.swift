//
//  StatusPictureView.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/2.
//

import UIKit
import SDWebImage

///照片之间的间距
private let StatusPictureViewItemMargin: CGFloat = 8
//可重用表示符
private let StatusPictureCellId = "StatusPictureCellId"

///配图视图
class StatusPictureView: UICollectionView{
   
    ///微博视图模型
    var viewModel : StatusViewModel?{
        didSet{
            //自动计算大小
            sizeToFit()
            
            //刷新数据--避免视图tableview 、collectionview重用
            //很重要---不要漏！！！
            //如果不刷新，后续的collectionView一旦被复用，不再调用数据源方法
            reloadData()
        }
    }
    
    //要想设置尺寸调用sizeToFit()，需要重写 sizeThatFits方法
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return calcViewSize()
    }
    
    // MARK: - 构造函数
    /*UICollectionViewFlowLayout 是 UICollectionView 的布局类，它继承自 UICollectionViewLayout。它可以通过集成和修改继承方法来定义集合视图的布局，实现流畅滚动和响应式更新。
    UICollectionViewFlowLayout 主要用于实现以下布局方式：
    流式布局（Flow layout）
    线性布局（Linear layout）
    瀑布流布局（Waterfall layout）*/
    init(){
        let layout = UICollectionViewFlowLayout()
        //设置图片间的间距--itemSize默认为50*50
        layout.minimumInteritemSpacing = StatusPictureViewItemMargin
        layout.minimumLineSpacing = StatusPictureViewItemMargin
        
        super.init(frame: CGRectZero,collectionViewLayout: layout)
        backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        
        //设置数据源--自己当自己的数据源
        //应用场景：自定义视图的小框架
        dataSource = self
        
        //设置代理
        delegate = self
        
        //注册可重用Cell
        //用的是配图Cell
        register(StatusPictureViewCell.self, forCellWithReuseIdentifier: StatusPictureCellId)
        
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - UICollectionViewDataSource,UICollectionViewDelegate（数据源、代理方法）
extension StatusPictureView: UICollectionViewDataSource,UICollectionViewDelegate{
    
    //代理
    //选中照片
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //测试
        //photoBrowserPresentFromRect(indexPath: indexPath as NSIndexPath)
       // photoBrowserPresentToRect(indexPath: indexPath as NSIndexPath)
        
        
        print("点击照片\(indexPath)\(String(describing: viewModel?.thumbnailUrls))")
        //传递的数据-->当前的URL数组/当前用户选中的索引
        //通知：名字（通知中心监听），object（发送通知的同时传递对象--单值）。userInfo（发送通知的同时传递对象--多值---使用的数据字典，要定义key）
        let userInfo = [WBStatusSelectedPhotoIndexPathKey: indexPath, WBStatusSelectedPhotoURLsKey: viewModel!.thumbnailUrls!] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name(WBStatusSelectedPhotoNotification), object: self, userInfo: userInfo)
            
    }
    
    
    
    //数据源
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel?.thumbnailUrls?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatusPictureCellId, for: indexPath)as!StatusPictureViewCell
        
        cell.imageURL = viewModel!.thumbnailUrls![indexPath.item]
        //cell.backgroundColor = UIColor.yellow
        
        return cell
    }
    
    
    
}

// MARK: - 照片查看器的展现协议
extension StatusPictureView: PhotoBrowserPresentDelegate{
    
    //创建一个imageView来参与动画，原来的不动
    func imageViewForPresent(indexPath: NSIndexPath) -> UIImageView {
        
        let iv = UIImageView()
        //1.设置内容填充模式
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        //2.设置图像（缩略图缓存）
        //sdwebImage如果已经存在本地缓存，不会发起网络请求
        if let url = viewModel?.thumbnailUrls?[indexPath.item]{
            iv.sd_setImage(with: url as URL)
            
        }
        
        return iv
        
    }
    
    //起始位置
    func photoBrowserPresentFromRect(indexPath: NSIndexPath) -> CGRect {
        //1.根据 indexpath 获得用户选择的cell
        let cell = self.cellForItem(at: indexPath as IndexPath)
        
        //2.通过cell知道cell对应在屏幕上的准确位置（cell--collectionview）
        //在不同视图之间的‘坐标系的转换’,self.是cell的父视图!!!---convert方法
        //由collectionview将cell的frame位置转换为keywindow的frame位置
        let rect = self.convert(cell!.frame, to: UIApplication.shared.keyWindow!)

        //       测试代码
//        let v = UIView(frame: rect)
//        v.backgroundColor = UIColor.red
        
//        let v = imageViewForPresent(indexPath: indexPath)
//        v.frame = rect
        
     //   UIApplication.shared.keyWindow?.addSubview(v)
        
        return rect
    }
      //目标位置
    func photoBrowserPresentToRect(indexPath: NSIndexPath) -> CGRect {
        
        //根据缩略图的大小，等比例计算目标位置
        guard let key = viewModel?.thumbnailUrls?[indexPath.item].absoluteString else{
            return CGRectZero
        }
        
        //从sdwebimage获取本地缓存图片
        guard let image = SDImageCache.shared.diskImageData(forKey: key) else{
            return CGRectZero
        }
        //根据图像大小，计算全屏的大小
        var rect = CGRect.zero // 将 rect 变量的声明放在外部
        // 根据图像大小，计算全屏的大小
        if let image = UIImage(data: image) {
            let w = UIScreen.main.bounds.width
            var h = image.size.height * w / image.size.width
            // 对高度进行额外处理--可能超出屏幕
            let screenHeight = UIScreen.main.bounds.height
            var y: CGFloat = 0
            if h < screenHeight {
                // 图片短，垂直居中显示
                y = (screenHeight - h) * 0.5
            } else {
                // 图片高度超出屏幕，调整高度并居上显示
                
            }
            rect = CGRect(x: 0, y: y, width: w, height: h)
            
        }
        //测试位置
//                let v = imageViewForPresent(indexPath: indexPath)
//                v.frame = rect
//
//                UIApplication.shared.keyWindow?.addSubview(v)
        
        return rect
    }
    
}

// MARK: - 计算视图大小
extension StatusPictureView{
    
    ///计算视图大小
    private func calcViewSize() -> CGSize{
        //1.准备
        //每行的照片数量
        let rowCount: CGFloat = 3
        //最大宽度
        let maxWidth = UIScreen.main.bounds.width-2 * StatusCellMargin
        let itemWidth = (maxWidth - 2 * StatusPictureViewItemMargin)/rowCount
        
        //2.设置layout的itemSize
        //在 Swift 中，`layout` 通常指的是界面布局（UI Layout）的过程，用于在屏幕上对视图进行位置和大小的排列。iOS 中最常用的布局系统是 Apple 提供的 Auto Layout，即自动布局系统，它是一种声明式的布局方式，使用约束（Constraints）来描述视图间的关系。
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth) //正方形
        
        //3.获取图片数量
        let count = viewModel?.thumbnailUrls?.count ?? 0
        //计算开始
        //1>没有图片
        if count == 0{
            return CGSizeZero
        }
        //2>一张图片
        if count == 1{
            //--临时指定大小
            var size = CGSize(width: 150, height: 120)
            
            //利用SDWedImage 检查本地的缓存图像
            //SDWedImage设置缓存图片的文件名--完整的url-->MD5
            //提取单图
            //key是单图url的完整字符串--absoluteString转成字符串
            ///这个写法很重要！！！
            if let key = viewModel?.thumbnailUrls?.first?.absoluteString {
                if let data = SDImageCache.shared.diskImageData(forKey: key),
                    let image = UIImage(data: data) {
                    size = image.size
                }
            }
            
            //图像过窄处理--针对长图
            size.width = size.width < 40 ? 40 : size.width
            //图像过宽处理，等比缩放
            if size.width > 300 {
                let w : CGFloat = 300
                let h = size.height * w / size.width
                size = CGSize(width: w, height: h)
            }
          
            
            //`layout.itemSize` 是一个用于设置 `UICollectionViewFlowLayout` 布局对象中单元格（Item）大小的属性。
            //内部图片的大小
            layout.itemSize = size
            //配图视图的大小
            return size
        }
        //3>四张图片2*2的大小
        if count == 4{
            let w = 2 * itemWidth + StatusPictureViewItemMargin
            return CGSize(width: w, height: w)
        }
        //4>其他图片按照九宫格来显示
        //先计算出行数
        let row = CGFloat((count - 1)/Int(rowCount) + 1)    //要记住(重要公式)!!
        let h = row * itemWidth + (row - 1)*StatusPictureViewItemMargin
        let w = rowCount * itemWidth + (rowCount - 1)*StatusPictureViewItemMargin
        return CGSize(width: w, height: h)
    }
}

// MARK: - 配图Cell
//懒加载属性
private class StatusPictureViewCell:UICollectionViewCell{
   // iconView的内容
    var imageURL: NSURL?{
        didSet{
            iconView.sd_setImage(with: imageURL as URL?,
                                 placeholderImage: nil,
                                 options: [SDWebImageOptions.retryFailed,
                                    SDWebImageOptions.refreshCached])
            
            //根据文件扩展名判断是否是gif,但是不是所有的gif都会动
            let ext = (((imageURL?.absoluteString ?? "") as NSString).pathExtension)
            gifIconView.isHidden = (ext != "gif")
            /*注释：
iconView.sd_setImage(with: imageURL as URL?,
            placeholderImage: nil,  //在调用OC的框架时，可/必选项不严格
            options: [SDWebImageOptions.retryFailed, //SD超时时长15s，一旦超时会进入黑名单，不再下载图片
            SDWebImageOptions.refreshCached])   //如果URL不变，图像变 -->会刷新图片
             */
        }
    }
    // MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        //1.添加控件
        contentView.addSubview(iconView)
        iconView.addSubview(gifIconView)
        
        //2.设置布局--提示因为cell的图片会变化，另外，不同的cell大小可能不一样
        iconView.snp.makeConstraints { (make) -> Void  in
            make.edges.equalTo(contentView.snp.edges)
        }
        gifIconView.snp.makeConstraints { (make) -> Void  in
            make.right.equalTo(iconView.snp.right)
            make.bottom.equalTo(iconView.snp.bottom)
        }
    }
    
    // MARK: - 懒加载控件
    private lazy var iconView: UIImageView = {
        let iv = UIImageView()
        //设置填充模式（会有裁切--clipsToBounds）
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    //GIF提示图片
    private lazy var gifIconView: UIImageView = UIImageView.cz_iconViewImage(imageName: "timeline_image_gif")
}


