//
//  ComposeViewController.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/5/9.
//

import UIKit
import SnapKit
import SVProgressHUD

// MARK: - 撰写微博控制器
class ComposeViewController: UIViewController {
    
    ///照片选择控制器
    private lazy var picturePickerController = PicturePickerController()
    
    ///表情键盘属性(表情键盘视图)
    private lazy var emoticonView: EmoticonView = EmoticonView{[weak self](emoticon) -> () in
       
        self?.textView.insertEmoticon(em:emoticon)  //表情文字
    }
    
    // MARK: - 监听方法
    //关闭
    @objc private func close(){
        //先关闭键盘
        textView.resignFirstResponder()
        
        dismiss(animated: true,completion: nil)
    }
    
    //发布微博
    @objc private func sendStatus(){
        
        //1.获取文本内容
        let text = textView.emoticonText
        //2.发布微博
        let image = picturePickerController.pictures.last
        NetworkTools.sharedTools.sendStatus(status: text,image: image) { result, error in
            if error != nil{
                print("出错了")
                SVProgressHUD.showInfo(withStatus: "您的网络用户不给力")
                return
            }
            print(result as Any)
            //关闭控制器
            self.close()
        }
    }
    
    //选择照片
    @objc private func selectPictrue(){
        print("选择照片")
        //退掉键盘
        textView.resignFirstResponder()
        //0.判断如果已经更新了约束，不再执行后续代码!!!
        if picturePickerController.view.frame.height > 0 {
            return
        }
        //1.修改照片选择控制器视图的约束
        picturePickerController.view.snp.updateConstraints { make in
            make.height.equalTo(view.bounds.height * 0.65)
            
        }
            
        //2.修改文本视图的约束，remake（重新约束）将之前所有的约束删除
            textView.snp.remakeConstraints { (make) in
                make.bottom.equalTo(picturePickerController.view.snp.top)
                make.left.equalTo(view.snp.left)
                make.right.equalTo(view.snp.right)
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            }
         //3.动画更新约束
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
            
    }
    
    //选择表情
    @objc private func selectEmoticon(){
        //如果使用的是系统键盘---为nil
        print("选择表情\(String(describing: textView.inputView))")
        
        //1.退掉键盘
        textView.resignFirstResponder()
        
        //2.设置键盘(两个键盘可切换)
        textView.inputView = textView.inputView == nil ? emoticonView : nil
        
        //3.重新激活键盘
        textView.becomeFirstResponder()
    }
   
    //键盘变化处理
    @objc private func keyboardChanged(n: NSNotification){
      //1.获取目标的rect - 字典中的‘结构体’是NSValue
        let rect = (n.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        print(rect)
        //获取目标的动画时长 - 字典中的数值为NSNumber
        let duration = (n.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        //动画曲线数值
        let curve = (n.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue
        
        
        let offset = -UIScreen.main.bounds.height + rect.origin.y
        //2.更新约束
        toolbar.snp.updateConstraints{(make) -> Void in
            make.bottom.equalTo(view.snp.bottom).offset(offset)
        }
        //3.动画
        UIView.animate(withDuration: duration) { () -> Void in
            
            //设置动画曲线
            UIView.setAnimationCurve(UIView.AnimationCurve(rawValue: curve)!)
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - 键盘处理
    override func viewDidLoad() {
        //添加键盘通知
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardChanged), name: UIResponder.keyboardWillChangeFrameNotification,  object: nil)
    }
    deinit{
        //注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 视图生命周期
     //设置根视图
    override func loadView() {
        view = UIView()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //激活键盘 --如果已经存在照片控制器视图，不再激活键盘
        if picturePickerController.view.frame.height == 0{
            textView.becomeFirstResponder()
        }
    }
    // MARK: - 懒加载控件
    //工具条
    private lazy var toolbar = UIToolbar()
    //文本视图
    private lazy var textView:UITextView = {
        let tv = UITextView()
        
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.textColor = UIColor.darkGray
        
        //始终允许垂直滚动
        tv.alwaysBounceVertical = true
        //拖拽关闭键盘
        tv.keyboardDismissMode = UIScrollView.KeyboardDismissMode.onDrag
        
        //设置文本视图的代理
        tv.delegate = self
        
        return tv
        
    }()
    //占位标签
    private lazy var placeHolderLabel: UILabel =
        UILabel.cz_messagelabel(title:"分享新鲜事...",fontSize: 18,color: UIColor.lightGray)
    
}
// MARK: - UITextViewDelegate
extension ComposeViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = textView.hasText
        placeHolderLabel.isHidden = textView.hasText
    }
}

// MARK: - 设置界面
private extension ComposeViewController{
    
    func setupUI(){
        
        //0.取消自动调整滚动视图间距（写法被弃用）
       // automaticallyAdjustsScrollViewInsets = false
        
        //1.设置背景颜色
        view.backgroundColor = UIColor.white
        //2.设置控件
        prepareNavigationBar()
        prepareToolbar()
        prepareTextView()
        preparePicturePicker()
        
    }
    ///准备照片选择控制器
    private func preparePicturePicker(){
        
        //0.添加子控制器
        addChild(picturePickerController)
        
        //1.添加视图 --加了根视图
        view.addSubview(picturePickerController.view)
        //把toolbar显示回来
        view.insertSubview(picturePickerController.view, belowSubview: toolbar)
        
        //2.自动布局
        picturePickerController.view.snp.makeConstraints{(make) -> Void in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(0)
        
            
        }
        //3.动画更新约束
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    ///准备文本视图
    private func prepareTextView(){
        view.addSubview(textView)
        
        textView.snp.makeConstraints{(make) -> Void in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            //注意这个写法
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(toolbar.snp.top)
        }
        
      
        
        //添加占位标签
        textView.addSubview(placeHolderLabel)
        
        placeHolderLabel.snp.makeConstraints{(make) -> Void in
            make.top.equalTo(textView.snp.top).offset(8)
            make.left.equalTo(textView.snp.left).offset(5)
        }
    }
    
    ///准备工具栏
    private func prepareToolbar(){
        //1.添加控件
        view.addSubview(toolbar)
        //设置背景颜色
        toolbar.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        //2.自动布局
        toolbar.snp.makeConstraints{(make) -> Void in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(44)
        }
        //3.添加按钮
        //定义数组itemSettings,用于表示要添加的子控件的信息
        let itemSettings = [["imageName":"compose_toolbar_picture","actionName":"selectPictrue"],["imageName":"compose_mentionbutton_background"],["imageName":"compose_trendbutton_background"],["imageName":"compose_emoticonbutton_background","actionName":"selectEmoticon"],["imageName":"compose_add_background"]]
        //定义数组items,用于表示所有的子控件
        var items = [UIBarButtonItem]()
        
        //遍历itemSettings数组
        for dict in itemSettings{
   //便利构造函数之前的写法
     //根据子控件的信息创建UIButton对象
            let button = UIButton.cz_buttonImage(dict["imageName"]!, backImageName: nil)
            //判断actionName是否存在，如果存在，则为子控件添加点击事件处理方法
            if let actionName = dict["actionName"]{
                
                button.addTarget(self, action: Selector(actionName), for: .touchUpInside)
                
            }
           let item = UIBarButtonItem(customView: button)
            items.append(item)
        
            //添加可变长度的控件，用于填充子控件之间的空隙
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            
        }
        //去掉最后一个多余的可变长度控件
        items.removeLast()
        //一旦赋值，相当于做了一次copy
        toolbar.items = items
    }
    
    ///设置导航栏
    private func prepareNavigationBar(){
        //1.左右按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发布", style: .plain, target: self, action: #selector(sendStatus))
        //禁用发布微博按钮
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        
        
        //2.标题视图titleview(不用title)
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 32))
       
        navigationItem.titleView = titleView
        //3.添加子控件
        let titleLabel = UILabel()
        titleLabel.text = "发微博"
        titleLabel.font = UIFont.systemFont(ofSize: 15)

        let nameLabel = UILabel()
        if let screenName = UserAccountViewModel.sharedUserAccount.account?.screen_name {
            nameLabel.text = screenName
        } else {
            nameLabel.text = ""
        }
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        nameLabel.textColor = UIColor.lightGray
        titleView.addSubview(titleLabel)
        titleView.addSubview(nameLabel)
        //给子控件添加约束
        titleLabel.snp.makeConstraints{(make) -> Void in
            make.centerX.equalTo(titleView.snp.centerX)
            make.top.equalTo(titleView.snp.top)
        }
        nameLabel.snp.makeConstraints{(make) -> Void in
            make.centerX.equalTo(titleView.snp.centerX)
            make.bottom.equalTo(titleView.snp.bottom)
        }
    }
}
