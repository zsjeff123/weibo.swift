//
//  PhotoBrowserViewController.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/11.
//

import UIKit
import SVProgressHUD

///可重用cell标识符号
private let PhotoBrowserViewCellId = "PhotoBrowserViewCellId"

///照片浏览器
class PhotoBrowserViewController: UIViewController {

    //照片URL数组
    private var urls: [NSURL]
    //当前选中的照片索引
    private var currentIndexPath: NSIndexPath
    
    // MARK: - 监听方法
    //关闭照片
    @objc private func close(){
        dismiss(animated: true,completion: nil)
    }
    //保存照片
    @objc private func save(){
        print("保存照片")
        
        //1.拿到照片
        let cell = collectionView.visibleCells[0] as!PhotoBrowserCell
        //imageview很可能因为网络问题没有图片
        guard let image = cell.imageView.image else{
            return
        }
        //2.保存图片
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image: didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //当保存图片完毕后执行这个方法
    //didFinishSavingWithError外部参数，error内部参数
    @objc private func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject?){
        let message = (error  == nil) ? "保存成功" : "保存失败"
        //用进度条显示保存进度
        SVProgressHUD.showInfo(withStatus: message)
        
    }
    
    // MARK: - 构造函数
    //属性都可以是必选，不用在后续考虑解包的问题
    init(urls: [NSURL], indexPath: NSIndexPath) {
        self.urls = urls
        self.currentIndexPath = indexPath
        
        //调用父类方法
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //loadView() 是一个视图控制器方法，用于创建和设置视图控制器的根视图---自定义视图控制器的根视图
    //loadview函数执行完成，view上的元素要全部创建完成
    //如果view = nil,系统会在调用view的getter方法时，自动调用loadview，创建view
    override func loadView() {
        //1.设置根视图
        var rect = UIScreen.main.bounds
        rect.size.width += 20
        view = UIView(frame: rect)
       
        //2.设置界面
        setupUI()
    }
    
    //viewDidLoad是在视图创建完成后被调用。loadview执行完后被执行
    //主要做数据加载，或者其他处理
    override func viewDidLoad() {
        super.viewDidLoad()

       print(urls)
        print(currentIndexPath)
        //让collectionview滚动到指定位置来显示图片（即点哪张显示哪张）!!!
        collectionView.scrollToItem(at: currentIndexPath as IndexPath, at: .centeredHorizontally, animated: false)
        
    }
    
    
    // MARK: - 懒加载控件
     lazy var  collectionView:UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: PhotoBrowserViewLayout())
    //关闭按钮
    private lazy var closeButton:UIButton = UIButton.cz_SYbutton(title: "关闭", fontSize: 14, color: UIColor.white, imageName: "",backColor: UIColor.darkGray)
    //保存按钮
    private lazy var saveButton:UIButton = UIButton.cz_SYbutton(title: "保存", fontSize: 14, color: UIColor.white, imageName: "",backColor: UIColor.darkGray)
    
    // MARK: - 自定义流水布局
    private class PhotoBrowserViewLayout: UICollectionViewFlowLayout{
        
        override func prepare() {
            super.prepare()
            
            itemSize = collectionView!.bounds.size
            minimumLineSpacing = 0
            minimumInteritemSpacing = 0
            
            scrollDirection = .horizontal
            collectionView?.isPagingEnabled = true
            collectionView?.bounces = false
            collectionView?.showsHorizontalScrollIndicator = true
            
        }
    }
  
}

// MARK: - 设置页面
private extension PhotoBrowserViewController{
    
    private func setupUI(){
        //1.添加控件
        view.addSubview(collectionView)
        view.addSubview(closeButton)
        view.addSubview(saveButton)
        //2.设置布局
        collectionView.frame = view.bounds
        closeButton.snp.makeConstraints { (make) ->Void in
            make.bottom.equalTo(view.snp.bottom).offset(-8)
            make.left.equalTo(view.snp.left).offset(8)
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
        saveButton.snp.makeConstraints { (make) ->Void in
            make.bottom.equalTo(view.snp.bottom).offset(-8)
            make.right.equalTo(view.snp.right).offset(-28)
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
        //3.监听方法
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        
        //4.准备控件
        prepareCollectionView()
    }
    
    //准备collectionView
    private func prepareCollectionView(){
        //1.注册可重用cell
        collectionView.register(PhotoBrowserCell.self, forCellWithReuseIdentifier: PhotoBrowserViewCellId )
        //2.设置数据源
        collectionView.dataSource = self
        
    }
    
}

// MARK: - UICollectionViewDataSource
extension PhotoBrowserViewController:UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoBrowserViewCellId, for: indexPath)as! PhotoBrowserCell
        
       // cell.backgroundColor = UIColor.black
        cell.imageURL = urls[indexPath.item]
        
        //设置代理
        cell.photoDelegate = self
        
        return cell
    }
}


// MARK: - PhotoBrowserCellDelegate
//遵守协议
extension PhotoBrowserViewController:PhotoBrowserCellDelegate{
    
    func photoBrowserCellShouldDismiss() {
        
        
        //之前上面写过的close方法
        close()
    }
    
    func photoBrowserCellDidZoom(scale: CGFloat) {
        
        let isHidden = (scale < 1)
        hideControls(isHidden: isHidden)
        if isHidden {
            
            //1.根据scale修改根视图的透明度 和 缩放比例
            view.alpha = scale
            view.transform = CGAffineTransformMakeScale(scale, scale)
            
        }else{
            view.alpha = 1.0
            view.transform = CGAffineTransformIdentity
        }
    }
    
    //隐藏或显示控件
    private func hideControls(isHidden: Bool){
        closeButton.isHidden = isHidden
        saveButton.isHidden = isHidden
        
        collectionView.backgroundColor = isHidden ? UIColor.clear : UIColor.black
    }
    
}

// MARK: - 解除转场动画协议
extension PhotoBrowserViewController:PhotoBrowserDismissDelegate{
    //解除转场的图像视图（包含了解除动画的起始位置）
    func imageViewForDismiss() -> UIImageView{
        
        let iv = UIImageView()
        
        //设置填充模式
        iv.contentMode  = .scaleAspectFill
        iv.clipsToBounds = true
        
        //设置图像 - 直接从当前展示动画后显示的cell中获取
        let cell = collectionView.visibleCells[0] as!PhotoBrowserCell
        iv.image = cell.imageView.image
        
        //设置位置 - 坐标转换(由父视图进行转换)
        iv.frame = cell.scrollView.convert(cell.imageView.frame, to: UIApplication.shared.keyWindow!)
        
        //测试代码
        //UIApplication.shared.keyWindow?.addSubview(iv)
        
        return iv
        
    }
    
    //解除转场的图像索引
    func indexPathForDismiss() -> NSIndexPath{
        
        return collectionView.indexPathsForVisibleItems[0] as NSIndexPath
    }
}
 
