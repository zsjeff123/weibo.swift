//
//  StatusCellTopView.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/1.
//

import UIKit

///Cell顶部视图
class StatusCellTopView: UIView {

    ///微博顶部视图模型
    var viewModel : StatusViewModel?{
        didSet{
            //设置工作
            //姓名
           nameLabel.text = viewModel?.status.user?.screen_name
            //头像
            //注意这里的类型转换image-->url
           iconView.sd_setImage(with: (viewModel?.userProfileUrl)!  as URL, placeholderImage: viewModel?.userDefaultsIconView)
            //会员图标
           memeberIconView.image = viewModel?.userMemberImage
            //认证图标
            vipIconView.image = viewModel?.userVipImage
            
            // MARK: - TODO时间、来源转换后面写--已完成
            //时间
            timeLabel.text = viewModel?.createAt
            
            //来源
            sourceLabel.text = viewModel?.status.source
            
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
    
    // MARK: - 懒加载控件
    //头像
    private lazy var iconView: UIImageView = UIImageView.cz_iconViewImage(imageName: "avatar_default_big")
    //姓名
    private lazy var nameLabel: UILabel = UILabel.cz_messagelabel(title: "王老五",fontSize: 14)
    //会员图标
    private lazy var memeberIconView: UIImageView = UIImageView.cz_iconViewImage(imageName: "common_icon_membership_level1")
    //认证图标
    private lazy var vipIconView: UIImageView = UIImageView.cz_iconViewImage(imageName: "avatar_vip")
    //时间标签
    private lazy var timeLabel: UILabel =
    UILabel.cz_messagelabel(title: "现在",fontSize: 11,color: UIColor.orange)
    //来源标签
    private lazy var sourceLabel: UILabel = UILabel.cz_messagelabel(title: "来源",fontSize: 11)
}

// MARK: - 设置界面
extension StatusCellTopView{
    private func setupUI(){
       
        backgroundColor = UIColor.white
        
        //0.添加表格间分割线(分割视图)
        let sepView = UIView()
        sepView.backgroundColor = UIColor.lightGray
        addSubview(sepView)
        
        //1.添加控件
        addSubview(iconView)
        addSubview(nameLabel)
        addSubview(memeberIconView)
        addSubview(vipIconView)
        addSubview(timeLabel)
        addSubview(sourceLabel)
        
        //2.自动布局
        //分割线的布局
        sepView.snp.makeConstraints{(make) -> Void in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.height.equalTo(StatusCellMargin)
        }
        
        
        iconView.snp.makeConstraints{(make) -> Void in
            make.top.equalTo(sepView.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(self.snp.left).offset(StatusCellMargin)
            make.width.equalTo(StatusCellIconWidth)
            make.height.equalTo(StatusCellIconWidth)}
        nameLabel.snp.makeConstraints{(make) -> Void in
            make.top.equalTo(iconView.snp.top)
            make.left.equalTo(iconView.snp.right).offset(StatusCellMargin)}
        memeberIconView.snp.makeConstraints{(make) -> Void in
            make.top.equalTo(nameLabel.snp.top)
            make.left.equalTo(nameLabel.snp.right).offset(StatusCellMargin)}
        vipIconView.snp.makeConstraints{(make) -> Void in
            make.centerX.equalTo(iconView.snp.right)
            make.centerY.equalTo(iconView.snp.bottom)}
        timeLabel.snp.makeConstraints{(make) -> Void in
            make.bottom.equalTo(iconView.snp.bottom)
            make.left.equalTo(iconView.snp.right).offset(StatusCellMargin)}
        sourceLabel.snp.makeConstraints{(make) -> Void in
            make.bottom.equalTo(timeLabel.snp.bottom)
            make.left.equalTo(timeLabel.snp.right).offset(StatusCellMargin)}
            
            
        }
        
    
    }
    

