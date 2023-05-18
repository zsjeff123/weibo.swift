//
//  StatusRetweetedCell.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/3.
//

import UIKit

///转发微博的Cell
class StatusRetweetedCell: StatusCell {
    
    ///微博转发视图模型
    ///如果继承父类的属性
    ///1.需要override
    ///2.不需要super
    ///3.先执行父类的didset,再执行子类的didset ->好处：只关心子类相关设置即可！！
    ///super是对函数，不是属性！！！
    override var viewModel : StatusViewModel?{
        didSet{
            //转发微博的文字
            let text = viewModel?.retweetedText ?? ""
            retweetedLabel.attributedText = EmoticonManager.sharedManager.emoticonText(string: text, font: retweetedLabel.font)
            
            //修改配图视图顶部位置
            pictureView.snp.updateConstraints{(make) -> Void in
                //根据配图数量修改配图视图顶部约束
                if let count = viewModel?.thumbnailUrls?.count, count > 0 {
                    offset = Int(StatusCellMargin) // 赋值给同一个变量
                }
                
                make.top.equalTo(retweetedLabel.snp.bottom).offset(offset) 
            }
        }
        
    }

    // MARK: - 懒加载控件
    //背景图片
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        return button
    }()
    
    ///转发微博标签
    private lazy var retweetedLabel: UILabel = UILabel.cz_messagelabel(title: "转发微博转发微博转发微博转发微博转发微博",fontSize: 14,color: UIColor.darkGray,screenInset: StatusCellMargin)
    
   

}

// MARK: - 设置界面
extension StatusRetweetedCell{
    
    override func setupUI() {
        //调用父类的setup UI，设置父类控件的位置
        super.setupUI()
        //1.添加控件
        //要在配图视图的下面--->不可用addsubView
        contentView.insertSubview(backButton, belowSubview: pictureView)
        contentView.insertSubview(retweetedLabel, aboveSubview: backButton)
        //2.自动布局
        //1>背景按钮
        backButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentLabel.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.bottom.equalTo(bottomView.snp.top)
        }
        //2>转发微博标签
        retweetedLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(backButton.snp.top).offset(StatusCellMargin)
            make.left.equalTo(backButton.snp.left).offset(StatusCellMargin)
        }
        //3>配图视图
        pictureView.snp.makeConstraints{(make) -> Void in
            make.top.equalTo(retweetedLabel.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(retweetedLabel.snp.left)
            make.width.equalTo(300)
            make.height.equalTo(90)
        }
        
    }
}
