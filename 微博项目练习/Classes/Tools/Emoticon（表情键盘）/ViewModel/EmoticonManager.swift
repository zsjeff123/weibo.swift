//
//  EmoticonViewModel.swift
//  表情键盘
//
//  Created by 云动家 on 2023/5/8.
//

import UIKit

// MARK: - 表情包管理器（单例视图模型）
class EmoticonManager{
   
   static let sharedManager = EmoticonManager()
    //表情包数组
   lazy  var packages = [EmoticonPackage]()
    
    // MARK: - 最近表情
    //添加最近表情 -> 把表情模型添加到package[0]的表情数组
    //内存排序的处理方法！
    func addFavorite(em: Emoticon){
        
        //0.表情次数 + 1
        em.times += 1
        
        //1.判断表情是否被添加
        if !packages[0].emoticons.contains(em){
            packages[0].emoticons.insert(em, at: 0)
            
            //删除倒数第二个按钮，倒数第一个是删除按钮
            packages[0].emoticons.remove(at: packages[0].emoticons.count - 2)
        }
        //2.排序当前数组
        packages[0].emoticons.sort(by: { (em1, em2) -> Bool in
            em1.times > em2.times
        })
    }
    
    
    // MARK: - 生成属性字符串
    //将字符串转换成属性字符串
    func emoticonText(string: String, font: UIFont) -> NSAttributedString{
        
        let strM = NSMutableAttributedString(string: string)
        
        //1.准备正则表达式--[]是正则表达式关键字，需要转义--用\\
        let pattern = "\\[.*?\\]"
        let regex = try! NSRegularExpression(pattern: pattern,options: [])
        
        //2.匹配多项内容
       let results = regex.matches(in: strM.string, options: [], range: NSRange(location: 0, length: string.count))
        
        //3.得到匹配的数量
        var count = results.count
        
        
        //4.倒着遍历查找到的范围（保证第一次匹配完整）
        while count > 0 {
            let range = results[count - 1].range(at: 0)
           
            count -= 1
            //1>从字符串中获取表情子串
            let emStr = (string as NSString).substring(with: range)
            
            //2>根据 emStr 查找对应的表情模型
            if let em = emoticonWithString(string: emStr){
                
                //3>根据em建立表情图片属性文本
                //属性文本
                let attrText = EmoticonAttachment(emoticon: em).imageText(font: font)
                
                //4>替换属性字符串中的内容
                strM.replaceCharacters(in: range, with: attrText)
            }
            
            
        }
        
        
        return strM
        
    }
    
    
    
    //根据表情字符串，在表情包中查找对应的表情
    //string--表情字符串
    //Emoticon--表情模型
    private func emoticonWithString(string:String) -> Emoticon?{
        
        //遍历表情包数组
        for package in packages{
            
            //过滤emoticons数组，查找em.chs == string 的表情模型
             let emoticon = package.emoticons.filter { em in
               return em.chs == string
            }.last
            
            if emoticon != nil {
                return emoticon
            }
        }
        
        return nil
    }
    // MARK: - 构造函数
   private init(){
       //0. 添加最近的分组
       packages.append(EmoticonPackage(dict: ["group_name_cn":"最近A"]))
       
       
        //1.emoticons.plist路径--如果文件不存在-- path==nil
        let path = Bundle.main.path(forResource: "emoticons", ofType: "plist", inDirectory: "Emoticons.bundle")
        
      
        
        //2.加载字典
        let dict = NSDictionary(contentsOfFile: path!) as![String:Any]
       
        //3.提取package中的id字符串对应的数组
      let array = (dict["packages"] as! NSArray).value(forKey: "id")as![String]
        
        //4.遍历数组，字典转模型--准备加载info.plist
        for id in array {
            loadInfoPlist(id: id)
            
        }
        print(packages)
    }
    
    //加载id目录下的info.plist文件
    private func loadInfoPlist(id:String){
        //1.创建路径
        let path = Bundle.main.path(forResource:"info", ofType: "plist", inDirectory: "Emoticons.bundle/\(id)")!
       //2.加载字典
        let dict = NSDictionary(contentsOfFile: path) as! [String:AnyObject]
        
        
        //3.字典转模型追加到packages数组
        let package = EmoticonPackage(dict: dict)
        packages.append(package)
        
       
                        
}
        }
