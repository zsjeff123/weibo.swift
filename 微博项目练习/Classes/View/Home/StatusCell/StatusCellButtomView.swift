//
//  StatusCellButtomView.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/1.
//

import UIKit

///Cell底部视图
class StatusCellButtomView: UIView {
    
    // MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载控件
    //转发按钮
    //" "加空格可以使图片和文字不会靠太近
    private lazy var retweetedButton: UIButton = UIButton.cz_SYbutton(title: " 转发", fontSize: 12, color: UIColor.darkGray, imageName: "timeline_icon_retweet")
    //评论按钮
    private lazy var commentButton: UIButton = UIButton.cz_SYbutton(title:  " 评论", fontSize: 12, color: UIColor.darkGray, imageName: "timeline_icon_comment")
    //点赞按钮
    private lazy var likeButton: UIButton = UIButton.cz_SYbutton(title: " 赞", fontSize: 12, color: UIColor.darkGray, imageName: "timeline_icon_unlike")
}
    // MARK: - 设置界面
extension StatusCellButtomView{
    
    private func setupUI(){
        //0.设置背景颜色
        backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        //1.添加控件
        addSubview(retweetedButton)
        addSubview(commentButton)
        addSubview(likeButton)
        
        //2.自动布局
        retweetedButton.snp.makeConstraints{(make) -> Void in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left)
            make.bottom.equalTo(self.snp.bottom)
        }
        commentButton.snp.makeConstraints{(make) -> Void in
            make.top.equalTo(retweetedButton.snp.top)
            make.left.equalTo(retweetedButton.snp.right)
            make.width.equalTo(retweetedButton.snp.width)
            make.height.equalTo(retweetedButton.snp.height)
            
        }
        likeButton.snp.makeConstraints{(make) -> Void in
            make.top.equalTo(commentButton.snp.top)
            make.left.equalTo(commentButton.snp.right)
            make.width.equalTo(commentButton.snp.width)
            make.height.equalTo(commentButton.snp.height)
            //使三个按钮拉开
            make.right.equalTo(self.snp.right)
        }
        
        //3.分割视图（两个分割线）
        let sep1 = sepView()
        let sep2 = sepView()
        addSubview(sep1)
        addSubview(sep2)
          //布局
        let w = 1
        let scale = 0.4
        
        sep1.snp.makeConstraints{(make) -> Void in
            make.left.equalTo(retweetedButton.snp.right)
            make.centerY.equalTo(retweetedButton.snp.centerY)
            make.width.equalTo(w)
            make.height.equalTo(retweetedButton.snp.height).multipliedBy(scale)
        }
        sep2.snp.makeConstraints{(make) -> Void in
            make.left.equalTo(commentButton.snp.right)
            make.centerY.equalTo(retweetedButton.snp.centerY)
            make.width.equalTo(w)
            make.height.equalTo(retweetedButton.snp.height).multipliedBy(scale)
        }
    }
    //添加两个分割线分割三个按钮
    //通过添加两个UIView控件实现
    private func sepView() -> UIView{
        let v = UIView()
        v.backgroundColor = UIColor.darkGray
        return v
    }
}
