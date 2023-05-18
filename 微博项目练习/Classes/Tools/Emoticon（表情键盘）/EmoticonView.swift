//
//  EmoticonView.swift
//  表情键盘
//
//  Created by 云动家 on 2023/5/7.
//

import UIKit

let EmoticonViewCellId = "EmoticonViewCellId"

class EmoticonView: UIView {

    //选中表情回调
    private var selectedEmoticonCallBack: (_ emoticon:Emoticon) ->()
    
    // MARK: - 监听方法
    /// 点击工具栏 item
    @objc private func clickItem(item: UIBarButtonItem) {
        print(item.tag)
        
        let indexPath = NSIndexPath(item: 0, section: item.tag)
        //滚动collectionView--来跳转
        collectionView.scrollToItem(at: indexPath as IndexPath, at: .left, animated: true)
    }
    
    
    // MARK: - 构造函数
    init(selectedEmoticon:@escaping (_ emoticon:Emoticon) -> ()){
    //记录闭包属性
            selectedEmoticonCallBack = selectedEmoticon
        //调用父类构造函数
        var rect = UIScreen.main.bounds
        rect.size.height = 216
        //super之前要把必选属性设置好，super后是自己的设置工作
        super.init(frame: rect)        //设置空间
        backgroundColor = UIColor.white
        setupUI()
        
        //滚到第一页
        //没有最近表情的--会直接跳到默认表情
        //主队列异步
        let indexPath = NSIndexPath(item: 0, section: 1)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indexPath as IndexPath, at: .left, animated: false)
        }
        
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - 懒加载控件
    /// 表情包数组
   private lazy var packages = EmoticonManager.sharedManager.packages
    /// 工具栏
   private  lazy var toolbar = UIToolbar()
    /// 表情集合视图
    private lazy var collectionView = UICollectionView(frame: CGRectZero,
                                                       collectionViewLayout: EmoticonViewLayout())
    
    /// 表情键盘视图布局(类中类--只允许被父类包含的类使用)
    private class EmoticonViewLayout: UICollectionViewFlowLayout {
         override func prepare() {
            
            super.prepare()
            let col: CGFloat = 7
            let row: CGFloat = 3
            let w =   collectionView!.bounds.width / col
            let margin = CGFloat(Int((collectionView!.bounds.height - row * w) * 0.5))
            itemSize = CGSize(width: w, height: w)
            minimumInteritemSpacing = 0
            minimumLineSpacing = 0
            sectionInset = UIEdgeInsets(top: margin, left: 0, bottom: margin, right: 0)
            //设置滚动方向水平
            scrollDirection = .horizontal
            //设置分页
            collectionView?.isPagingEnabled = true
            collectionView?.bounces = false
        }
    }
}


// MARK: - 设置界面
private extension EmoticonView {
    func setupUI() {
        
        backgroundColor = UIColor.white
        //1:添加空间
        addSubview(collectionView)
        addSubview(toolbar)
        
        
        //2:设置约束
        //1>工具条
        toolbar.snp.makeConstraints { (make) ->Void in
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.height.equalTo(36)
            
        }
        //2->collectionView
        collectionView.snp.makeConstraints { (make) ->Void in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left)
            make.bottom.equalTo(toolbar.snp.top)
            make.right.equalTo(self.snp.right)
        }
        //3>准备工具条
        prepareToolBar()
        prepareCollectionView()
        
    }
    
    //准备工作栏
    func prepareToolBar() {
        //0.tintcoloe
        tintColor = UIColor.darkGray
            //1.设置按钮内容
            var items = [UIBarButtonItem]()
            //toolbar中，通常是一组功能相近的操作，只是操作的类型不同，通常利用tag来区分
            var index = 0
            for p in packages {
                items.append(UIBarButtonItem(title: p.group_name_cn, style: .plain, target: self, action: #selector(clickItem)))
                items.last?.tag = index
                index += 1
                //添加弹簧
                items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            }
            //有五个空隙，删掉最后一个
            items.removeLast()
            //2.设置Items
            toolbar.items = items
        
    }
    
    ///collectionview数据准备
    ///准备表情集合视图
    func prepareCollectionView() {
        collectionView.backgroundColor = UIColor.white
        //注册cell
        collectionView.register(EmoticonViewCell.self, forCellWithReuseIdentifier: EmoticonViewCellId)
        
        //指定数据源
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        //设置代理
        collectionView.delegate = self
        
    }
}
// MARK: - UICollectionViewDataSource
extension EmoticonView:UICollectionViewDataSource,UICollectionViewDelegate{
    
    //返回分组数量--表情包的数量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       
        return packages.count
    }
    //返回每个表情包中的表情数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return packages[section].emoticons.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmoticonViewCellId, for: indexPath)as!EmoticonViewCell
        //--表情包--表情
        cell.emoticon = packages[indexPath.section].emoticons[indexPath.row]
       
        return cell
    
    }
    //点击选择事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //获取表情模型
        let em  = packages[indexPath.section].emoticons[indexPath.item]
        // 执行回调
        selectedEmoticonCallBack(em)
        
        //添加最近表情
        //第0个分组不应该参加排序
        if indexPath.section > 0 {
            
            EmoticonManager.sharedManager.addFavorite(em: em)
            
        }
    }
   
}


// MARK: - 表情视图 Cell
private class EmoticonViewCell: UICollectionViewCell {
    //表情模型--表情符号
    var emoticon: Emoticon?{
        didSet{
            //完整路径取图片
            emoticonButton.setImage(UIImage(contentsOfFile: emoticon!.imagePath), for: .normal)
            
                //设置emoji字符串（看上去是图片--实际是字符串）
                //不要加if emoticon?.emoji != nil{判断，否则会显示不正常，title的cell会被复用
                emoticonButton.setTitle(emoticon?.emoji, for: .normal)
                
            //设置删除按钮
            if emoticon!.isRemoved{
                emoticonButton.setImage(UIImage(named: "compose_emotion_delete"), for: .normal)
            }
        }
    }
    
    
    // MARK: -搭建界面（构造函数）
    override  init(frame: CGRect) {
        
        super.init(frame: frame)
        contentView.addSubview(emoticonButton)
        emoticonButton.backgroundColor = UIColor.white
        emoticonButton.frame = CGRectInset(bounds, 4, 4)
        emoticonButton.setTitleColor(UIColor.black, for: .normal)
        
        //emoji字符串字体大小和高度设置
        emoticonButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        
        //取消按钮的交互，换成cell的点击交互
        emoticonButton.isUserInteractionEnabled = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载控件
    /// 表情按钮
    private lazy var emoticonButton: UIButton = UIButton()
}

