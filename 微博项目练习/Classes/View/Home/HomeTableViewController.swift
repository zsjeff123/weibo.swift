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
       
        
    }
    
    // MARK: - 加载首页数据
  private   func loadData(){
        
        listViewModel.loadStatus { isSuccessed in
            if !isSuccessed{
                SVProgressHUD.showInfo(withStatus: "加载数据错误，请稍后再试")
                return
            }
            print(self.listViewModel.statusList)
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
    
