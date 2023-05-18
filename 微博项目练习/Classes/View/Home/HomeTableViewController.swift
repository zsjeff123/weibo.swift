//
//  HomeTableViewController.swift
//  微博项目练习
//
//  Created by 云动家 on 2023/4/25.
//

import UIKit
import SVProgressHUD

///原创微博Cell的可重用表示符号(全局访问)
let StatusCellNormalId = "StatusCellNormalId"
///转发微博Cell的可重用表示符号(全局访问)
let StatusCellRetweetedId = "StatusCellRetweetedId"

class HomeTableViewController: VisitorTableViewController{
    
    //调用视图模型
    //微博数据列表模型--懒加载
    private lazy var listViewModel = StatusListViewModel()
    
    //微博数据类型--数组
    //没有用了，被listViewModel.statuslist代替
    //var dataList: [Status]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !UserAccountViewModel.sharedUserAccount.userLogin {
            visitorView?.setupInfo(imageName: nil, title: "关注一些人，回这里看看有什么惊喜")
            return
            
        }
        //不要漏了这些调用方法的步骤
        prepareTableView()
        
        loadData()
        //refreshControl?.beginRefreshing()
        
        //注册通知--照片查看
        //n是通知传送对象
        NotificationCenter.default.addObserver(forName: NSNotification.Name(WBStatusSelectedPhotoNotification), object: nil, queue: nil) { [weak self](n) in
            
            guard let indexPath = n.userInfo?[WBStatusSelectedPhotoIndexPathKey] as? NSIndexPath else{
                return
            }
            guard let urls = n.userInfo?[WBStatusSelectedPhotoURLsKey] as? [NSURL] else{
                return}
            //判断cell是否遵守了展现动画的协议!!
            guard let cell = n.object as? PhotoBrowserPresentDelegate else {
                return
            }
            
          let vc = PhotoBrowserViewController(urls: urls, indexPath: indexPath)
            
            //1.设置modal的类型是自定义类型--Transition(转场)
            vc.modalPresentationStyle = UIModalPresentationStyle.custom
            
            //2.设置动画代理
            vc.transitioningDelegate = self?.photoBrowserAnimator
            
            //3.设置animator的代理参数
            //区分上面--一个是转场一个是动画
            self?.photoBrowserAnimator.setDelegateParams(presentDelegate: cell, indexPath: indexPath, dismissDelegate: vc)
            
            //4.Modal展现！！！
            //Modal 是一种用户界面模式，指的是在模态视图中显示内容的方式。在 iOS 应用程序中，模态视图通常以全屏或半屏的形式弹出，并在显示期间阻止用户与应用程序的其他部分进行交互。
            //当模态视图被打开时，它会将应用程序的主视图层次结构暂时隐藏起来，并在其上方显示一个新的视图层次结构。
            self?.present(vc, animated: true,completion: nil)
        }
    }
    
    //注销通知
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    ///准备表格
    private func prepareTableView(){
        //注册可重用Cell
        //用上自己定义的一个Cell
        tableView.register(StatusNormalCell.self, forCellReuseIdentifier: StatusCellNormalId)
        tableView.register(StatusRetweetedCell.self, forCellReuseIdentifier: StatusCellRetweetedId)
       // tableView.register(UITableViewCell.self, forCellReuseIdentifier: StatusCellNormalId)
        
        //取消表格分割线
        tableView.separatorStyle = .none
        
        //自动计算行高 - 需要自上而下的自动布局的控件，控件指定一个向下的约束
        //预估行高
        tableView.estimatedRowHeight = 400
        
        //下拉刷新控制默认没有   高度默认60
        //加上控件
        refreshControl = WBRefreshedControl()
        //添加下拉刷新监听方法
        refreshControl?.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        
        
        
        //设置tintcolor
        refreshControl?.tintColor = UIColor.blue
       
        //上拉刷新视图
        tableView.tableFooterView = pullupView
    }
    
    // MARK: - 加载首页数据
    @objc   private   func loadData(){
        //主动播放动画
        refreshControl?.beginRefreshing()
        
        listViewModel.loadStatus(isPullup: pullupView.isAnimating) { isSuccessed in
            
            //关闭刷新控件
            self.refreshControl?.endRefreshing()
            //关闭上拉刷新
            self.pullupView.stopAnimating()
            
            if !isSuccessed{
                SVProgressHUD.showInfo(withStatus: "加载数据错误，请稍后再试")
                return
            }
            print(self.listViewModel.statusList)
            
            //显示下拉刷新提示
            self.showPulldownTip()
            
            //刷新数据
            self.tableView.reloadData()
        }
        
        //用StatusListViewModel
        
        /*未写视图模型文件StatusListViewModel时的写法
         NetworkTools.sharedTools.loadStatus { result, error in
         if error != nil{
         print("出错了")
         return
         }
         //判断result的数据结构是否正确
         //[[String: Any]]字典数组的写法
         guard let result = result as? [String: Any],
         let array = result["statuses"] as? [[String: Any]] else {
         print("数据格式错误")
         return
         }
         //print(array)
         //拿到字典的数组--需要遍历字典的数组，字典转模型
         
         //1.可变的数组
         var dataList = [Status]()
         //2.遍历数组
         for dict in array{
         dataList.append(Status(dict: dict))
         }
         //3.测试
         print(dataList)
         
         //绑定的数据重新赋值来达到刷新效果
         self.dataList = dataList
         //4.刷新数据
         self.tableView.reloadData()
         
         }*/
       }
    
    //显示下拉刷新
    private func showPulldownTip(){
        //如果不是下拉刷新直接返回
        guard let count = listViewModel.pulldownCount else{
            return
        }
        print("下拉刷新\(count)")
        
        pulldownTipLabel.text = (count == 0) ? "没有新微博" : "刷新到\(count)条微博"
        
     
        
        
        let height:CGFloat = 44
        let rect = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)
        pulldownTipLabel.frame = CGRectOffset(rect, 0, -2.5 * height)
        
        //动画
        UIView.animate(withDuration: 1.0,animations:{
            self.pulldownTipLabel.frame = CGRectOffset(rect, 0, height)
        }){(_) -> Void in
            UIView.animate(withDuration: 1.0,animations:{
                self.pulldownTipLabel.frame = CGRectOffset(rect, 0, -2.5 * height)
            })
        }
        
    }
    
    // MARK: - 懒加载控件
    
    //下拉刷新提示标签
    private lazy var pulldownTipLabel: UILabel = {
        
        let label = UILabel.cz_messagelabel(title: "",fontSize: 18,color: UIColor.white)
        label.backgroundColor = UIColor.orange
    
        //添加到navigationBar
        navigationController?.navigationBar.insertSubview(label, at: 0)
        
        return label
    }()
    ///上拉刷新提示视图
    private lazy var pullupView: UIActivityIndicatorView = {
        
        let indicator = UIActivityIndicatorView(style:UIActivityIndicatorView.Style.whiteLarge)
        indicator.color = UIColor.lightGray
        return indicator
    }()
    ///照片查看转场动画代理
    private lazy var photoBrowserAnimator:PhotoBrowserAnimator = PhotoBrowserAnimator()
}


    // MARK: - 数据源方法
extension HomeTableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //dataList不一定有值，但是statusList懒加载一定有值
        //return dataList?.count ?? 0
        return listViewModel.statusList.count
    }
    
    
    //会调用行高方法
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //1.获取视图模型
        let vm = listViewModel.statusList[indexPath.row]
        
        //2.获取可重用cell会调用行高方法
        //cell-- cellId可判断是否是转发微博
        let cell = tableView.dequeueReusableCell(withIdentifier: vm.cellId , for:indexPath) as!StatusCell
        //测试微博信息内容
        //cell.textLabel?.text = dataList![indexPath.row].text
        
        /*未调用微博视图模型  var viewModel : StatusViewModel?的写法
         cell.textLabel?.text = listViewModel.statusList[indexPath.row].status.user?.screen_name*/
        
        //调用微博视图模型后的写法
        //将表视图获得的每行单元格的数据赋值给status Cell实例的viewModel属性
        //cell.viewModel = listViewModel.statusList,[indexPath.row]
        //“listViewModel.statusList”是一个包含多个StatusViewModel的数组，但是在将其分配给“cell.viewModel”时，它应该是一个单个的StatusViewModel实例。因此，需要根据indexPath.row获取数组中的特定元素来解决此问题
      //  let viewModel = listViewModel.statusList[indexPath.row]
        //cell.viewModel = viewModel
        
        //3.设置视图模型
        cell.viewModel = vm
        
        //4.判断是否是最后一条微博
        if indexPath.row == listViewModel.statusList.count - 1 && !pullupView.isAnimating{
            //开始动画
            pullupView.startAnimating()
            
            //上拉刷新数据
            loadData()
            
            print("上拉刷新")
        }
        
        
        return cell
        
    }
    
    //表格指定单元格高度
    //苹果官方文档提出，如果行高是固定值，就不要实行以下的行高代理方法
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return listViewModel.statusList[indexPath.row].rowHeight
        /*未在statusviewmodel文件中添加懒加载lazy  var rowHeight:时的写法
        //1.获得vm视图模型
        let vm = listViewModel.statusList[indexPath.row]
        
        return vm.rowHeight
    //判断是否有缓存的行高
        if vm.rowHeight != nil{
            print("计算行高\(String(describing: vm.status.text))")
            return vm.rowHeight!
        }
       
        //2.实例化cell
        //实例化对象时需要使用构造函数，构造函数是类中的一个方法，用于初始化实例。通过实例化类，我们可以访问类的各种方法和属性，并可以根据需要更新其状态。
        let cell = StatusCell(style: .default, reuseIdentifier: StatusCellNormalId)
        
        //3.返回行高--调用回vm
        //return cell.rowHeight(vm: vm)
        
        //3.计算高度
        vm.rowHeight = cell.rowHeight(vm: vm)
        return vm.rowHeight!    */
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("选中行\(indexPath)")
    }
    
}
    
