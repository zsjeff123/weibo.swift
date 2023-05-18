//
//  PicturePickerController.swift
//  照片选择控件
//
//  Created by 云动家 on 2023/5/10.
//

import UIKit

//可重用cell
private let PicturePickerCellId = "PicturePickerCellId"

//选择照片的最大数量
private let PicturePickerMaxCount = 8

//照片选择控制器
class PicturePickerController: UICollectionViewController {
    
    //配图数组
    lazy var pictures = [UIImage]()
    //当前用户选中的照片索引
    private var selectedIndex = 0
    
    //MARK: - 构造函数
    init(){
        super.init(collectionViewLayout: PicturePickerLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //在collectionviewcontroller中collectview ！= view
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        
        //注册可重用cell
        self.collectionView!.register(PicturePickerCell.self, forCellWithReuseIdentifier: PicturePickerCellId)

        
    }
   //照片选择器布局
    private class PicturePickerLayout: UICollectionViewFlowLayout{
        
        override func prepare(){
            super.prepare()
            
            //通过分辨率计算
            let count:CGFloat = 4
            let margin = UIScreen.main.scale * 4
            let w = (collectionView!.bounds.width - (count + 1) * margin) / count

            itemSize = CGSize(width: w, height: w)
            sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: 0, right: margin)
            minimumInteritemSpacing = margin
            minimumLineSpacing = margin
            
            
        }
    }
    

}


// MARK: UICollectionViewDataSource
extension PicturePickerController{
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //保证末尾有一个加号按钮
        //数量到8后不可添加
        return pictures.count + (pictures.count == PicturePickerMaxCount ? 0 : 1)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PicturePickerCellId, for: indexPath) as! PicturePickerCell
        
        //设置图像
        //防止数组越界
        cell.image = (indexPath.item < pictures.count) ? pictures[indexPath.item] : nil
        //设置代理
        cell.pictureDelegate = self
    
        return cell
    }
}
//MARK: - PicturePickerCellDelegate
extension PicturePickerController: PicturePickerCellDelegate{
    
    @objc fileprivate func picturePickerCellDidAdd(cell:PicturePickerCell){
        print("添加照片")
        
        //判断是否允许访问相册
        if !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("无法访问照片库")
        }
        //记录当前用户选中的照片索引
        selectedIndex = collectionView!.indexPath(for: cell)!.item
        
        //显示照片选择器
        let picker = UIImagePickerController()
        picker.delegate = self
        // picker.allowsEditing = true---适合于头像选择（从UIImagePickerControllerEditedImage取）
       // picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    @objc fileprivate func picturePickerCellDidRemove(cell:PicturePickerCell){
        print("删除照片")
        
        //1.获取照片索引
        let indexPath = collectionView!.indexPath(for: cell)
        //2.判断索引是否超出上限
        if indexPath!.item >= pictures.count{
            return
        }
        //3.删除数据
        pictures.remove(at: indexPath!.item)
        //4.刷新视图--动画刷新
       // collectionView?.deleteItems(at: [indexPath!])[不好--在最大图片张数限制时会检测item数量，可能会出错]
        collectionView?.reloadData()
    }
}

//MARK: - UIImagePickerControllerDelegate,UINavigationControllerDelegate
extension PicturePickerController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    //照片选择完成显示
    //picker--照片选择器
    //info-- info字典
    //提示：一旦实现代理方法，必须自己dismiss
    //应用程序内存在100MB左右可接受！！！！！！！！！！！
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        print(info)
        //选中照片
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let  scaleImage = image.scaleToWith(width: 600)
        
        //将照片添加到数组
        //判断当前选中的索引是否超出数组上限
        if selectedIndex >= pictures.count{
            pictures.append(scaleImage)
        }else{
            //选中的照片的替换
            pictures[selectedIndex] = scaleImage
        }
        
        //刷新表格视图
        collectionView?.reloadData()
        
        //释放控制器
        dismiss(animated: true,completion: nil)
    }
    
  
}

//PicturePickerCellDelegate 代理
//如果协议中包含optional的函数，协议需要使用 @objc 修饰
@objc
private protocol PicturePickerCellDelegate: NSObjectProtocol{
    //`optional` 是一种“包装”类型（Wrapper Type），它将实际的值进行了包装，并且通过一个枚举类型中的 `.none` 成员来表示该值为空。
    
    //添加照片
    @objc optional func picturePickerCellDidAdd(cell:PicturePickerCell)
    //删除照片
    @objc optional func picturePickerCellDidRemove(cell:PicturePickerCell)
}


//照片选择cell
private class PicturePickerCell: UICollectionViewCell{
    
    //照片选择代理
    weak var pictureDelegate: PicturePickerCellDelegate?
    //照片添加
    var image: UIImage? {
        didSet{
            addButton.setImage(image ?? UIImage(named: "compose_pic_add"), for: .normal)
            
            //没有照片时，隐藏“删除”按钮
            removeButton.isHidden = (image == nil)
        }
    }
    
    //MARK: - 监听方法
    @objc func addPicture(){
        pictureDelegate?.picturePickerCellDidAdd?(cell: self)
      
    }
    @objc func removePicture(){
        pictureDelegate?.picturePickerCellDidRemove?(cell: self)
    }
    
    
    //MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 自动布局
    //contentView 是 iOS 中 UIScrollView 的子视图，它是用来显示 UIScrollView 中实际内容的视图控件。UIScrollView 是一种可以滚动其子视图的控件，而 contentView 则是 UIScrollView 的子视图中的一部分，用于展示子视图中的全部内容。
    private func setupUI(){
        //1.添加控件
        contentView.addSubview(addButton)
        contentView.addSubview(removeButton)
        //2.设置布局
        addButton.frame = bounds
        //将删除按钮放在cell右上角
        removeButton.snp.makeConstraints { (make) ->Void in
            make.top.equalTo(contentView.snp.top)
            make.right.equalTo(contentView.snp.right)
        }
        //3.监听方法
        addButton.addTarget(self, action: #selector(addPicture), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(removePicture), for: .touchUpInside)
        
        //4.设置填充模式
        addButton.imageView?.contentMode = .scaleAspectFill
    }
    
    //MARK: - 懒加载控件
    //添加按钮
    private lazy var addButton: UIButton = UIButton.cz_buttonImage("compose_pic_add", backImageName: nil)
    //删除按钮
    private lazy var removeButton: UIButton = UIButton.cz_buttonImage("compose_photo_close", backImageName: nil)
    
}
