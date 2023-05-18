//
//  StatusCell.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/1.
//

import UIKit

///微博Cell中控件的间距数值
let StatusCellMargin: CGFloat = 12
///微博头像的宽度
let StatusCellIconWidth: CGFloat = 35

///微博Cell
class StatusCell: UITableViewCell {
   
    var offset = 0 // 在if语句和else语句之外声明变量
    ///微博视图模型
    var viewModel : StatusViewModel?{
        didSet{
            //设置工作
            topView.viewModel = viewModel
            
            let text = viewModel?.status.text ?? ""
            contentLabel.attributedText = EmoticonManager.sharedManager.emoticonText(string: text, font: contentLabel.font)
            
            //测试动态修改配图视图高度 - 实际开发中需要注意，如果动态修改约束的高度，可能会导致行高计算有误
            //在使用自动布局的时候，绝大多数报错，是因为约束错误或加多加少的原因
            //设置配图视图--设置视图模型之后，配图模型有能力计算大小
            pictureView.viewModel = viewModel
            pictureView.snp.updateConstraints{(make) -> Void in
                //print("配图视图大小\(pictureView.bounds)")
                make.height.equalTo(pictureView.bounds.height)
                //直接设置了宽度数值
                make.width.equalTo(pictureView.bounds.width)
                
          /*未写转发微博时的写法
           //根据配图数量，决定配图视图的顶部间距
                if let count = viewModel?.thumbnailUrls?.count, count > 0 {
                    offset = Int(StatusCellMargin) // 赋值给同一个变量
                }
                
                make.top.equalTo(contentLabel.snp.bottom).offset(offset) */
            }
            
        }
    }
    //根据指定的视图模型计算行高
    //vm --- 视图模型
    //return --- 返回视图模型对应的行高
    func rowHeight(vm: StatusViewModel) -> CGFloat{
        //1.记录视图模型 ->会调用上面的didSet设置微博视图模型内容以及更新‘约束’
        viewModel = vm
        //2.强制更新所有约束 -> 所有控件的frame都会被计算正确
        contentView.layoutIfNeeded()
        //3.返回底部视图的最大高度
        //所有的cell都有底部视图
        return CGRectGetMaxY(bottomView.frame)
        
    }
    
    
    // MARK: - 构造函数--调用函数
    override init(style: UITableViewCell.CellStyle,reuseIdentifier: String?){
        super.init(style:style,reuseIdentifier:reuseIdentifier)
        
        setupUI()
       
        //点击cell视图后不会变灰色
        selectionStyle = .none
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载控件
    ///顶部视图
    private lazy var topView: StatusCellTopView = StatusCellTopView()
    ///微博正文标签---便利构造函数
     lazy var contentLabel: UILabel = UILabel.cz_messagelabel(title: "微博正文",fontSize: 15,color: UIColor.darkGray,screenInset: StatusCellMargin)
    ///配图视图
     lazy var pictureView: StatusPictureView = StatusPictureView()
    ///底部视图
     lazy var bottomView: StatusCellButtomView = StatusCellButtomView()
   
}
// MARK: - 设置界面
extension StatusCell{
    //要加 @objc，不然StatusRetweetedCell的override--setupUI()会出现错误Non-@objc instance method 'setupUI()' is declared in extension of 'StatusCell' and cannot be overridden！！！
    //因为父类中的 setupUI() 方法没有被添加 @objc 标记，所以子类也不能添加 @objc 标记重写该方法。
    @objc func setupUI(){
        
        //1.添加控件
        //`contentView` 通常是指用于承载视图内容的容器视图，特别是在自定义 `UITableViewCell` 和 `UICollectionViewCell` 中经常用到。
        //对于 UITableViewCell 来说，contentView 通常包含了 textLabel, detailTextLabel, imageView, accessoryView 和 backgroundView 等子视图。
        //放在 contentView，左滑右滑不会影响单元格内的内容
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)
        //preferredMaxLayoutWidth是一个UIView属性，它指定了视图的首选最大布局宽度。它用于在自动布局过程中计算视图的大小。
        //实现正文的换行--未改UILabel+Extension时的写法
        //contentLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 2 * StatusCellIconWidth
        contentView.addSubview(pictureView)
        contentView.addSubview(bottomView)
       
        
        //2.自动布局
        //1>顶部视图
        topView.snp.makeConstraints{(make) -> Void in
           
           make.top.equalTo(contentView.snp.top)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
      
            make.height.equalTo(2*StatusCellMargin + StatusCellIconWidth)
        }
       //2>内容标签
         contentLabel.snp.makeConstraints{(make) -> Void in
         make.top.equalTo(topView.snp.bottom).offset(StatusCellMargin)
         make.left.equalTo(contentView.snp.left).offset(StatusCellMargin)
           
         }
        
  /*没有转发微博时的写法
   //3>配图视图
        pictureView.snp.makeConstraints{(make) -> Void in
            make.top.equalTo(contentLabel.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(contentLabel.snp.left)
            make.width.equalTo(300)
            make.height.equalTo(90)
            
        }
   */
        
         //4>底部视图
         bottomView.snp.makeConstraints{(make) -> Void in
         make.top.equalTo(pictureView.snp.bottom).offset(StatusCellMargin)
         make.left.equalTo(contentView.snp.left)
         make.right.equalTo(contentView.snp.right)
         make.height.equalTo(44)
             
         /*    //指定向下的约束
             make.bottom.equalTo(contentView.snp.bottom)
          */
         }
         
     
        
    }
}
