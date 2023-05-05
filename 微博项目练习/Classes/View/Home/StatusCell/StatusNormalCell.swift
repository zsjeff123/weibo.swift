//
//  StatusNormalCell.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/3.
//

import UIKit

///原创微博的Cell
class StatusNormalCell: StatusCell {
    
    ///微博视图模型
    override var viewModel : StatusViewModel?{
        didSet{
            //修改配图视图大小
            pictureView.snp.updateConstraints{(make) -> Void in
                //根据配图数量，决定配图视图的顶部间距
                if let count = viewModel?.thumbnailUrls?.count, count > 0 {
                    offset = Int(StatusCellMargin) // 赋值给同一个变量
                }
                
                make.top.equalTo(contentLabel.snp.bottom).offset(offset)
                
            }
        }
        
    }

    override func setupUI() {
        //不要漏
        super.setupUI()
        //3>配图视图
             pictureView.snp.makeConstraints{(make) -> Void in
                 make.top.equalTo(contentLabel.snp.bottom).offset(StatusCellMargin)
                 make.left.equalTo(contentLabel.snp.left)
                 make.width.equalTo(300)
                 make.height.equalTo(90)
                 
             }
    }

}
