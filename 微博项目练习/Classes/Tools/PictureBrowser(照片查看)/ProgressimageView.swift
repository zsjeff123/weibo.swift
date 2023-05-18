//
//  ProgressimageView.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/12.
//

import UIKit


//带进度的图像视图
//本身在UIImageView的drawRect中绘图--不会执行drawRect函数--要加一个另外的uiview才可调用
class ProgressimageView: UIImageView {

    //外部传递的进度值0-1
    var progress: CGFloat = 0{
        didSet{
            progressView.progress = progress
        }
    }
    
    //MARK: - 构造函数
    //一旦给构造函数指定了参数，系统不再提供默认的构造函数
    init(){
        super.init(frame: CGRectZero)
        
        setupUI()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 设置界面
    private func setupUI(){
        //1.添加控件
        addSubview(progressView)
        progressView.backgroundColor = UIColor.clear
        
        //2.设置布局
        progressView.snp.makeConstraints { make in
            make.edges.equalTo(self.snp.edges)
        }
    }
    
    
    //MARK: - 懒加载控件
    private lazy var progressView: ProgressView = ProgressView()
    
}

//进度视图
private class ProgressView:UIView{
    
    //内部传递的进度值0-1
    var progress: CGFloat = 0{
        didSet{
            //重绘视图
            setNeedsDisplay()
        }
    }
    //rect = bounds
    override func draw(_ rect: CGRect) {
        
        let center = CGPoint(x: rect.width * 0.5, y: rect.height * 0.5)
        let r = min(rect.width, rect.width) * 0.5
        let start = CGFloat( -Double.pi/2.0)
        let end = start + progress * 2 * CGFloat(Double.pi)
        
        /*
         参数
         1.中心点
         2.半径
         3.起始弧度
         4.截止弧度
         5.是否顺时针
         */
        let path = UIBezierPath(arcCenter: center, radius: r, startAngle: start, endAngle: end, clockwise: true)
        //让path添加到中心点的连线，而不是圆的上方为起始点
        path.addLine(to: center)
        path.close()
        UIColor(white: 1.0, alpha: 0.3).setFill()
        path.fill()
        
    }
    
}
