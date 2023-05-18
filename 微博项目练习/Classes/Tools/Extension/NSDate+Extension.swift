//
//  NSDate+Extension.swift
//  测试时间
//
//  Created by 云动家 on 2023/5/18.
//

import Foundation

extension NSDate{
    
    //将新浪微博格式的字符串转换成日期
    class func sinaDate(string: String) -> NSDate?{
        
        //1.转换成日期
        let df = DateFormatter()
        
        df.locale = Locale(identifier: "en")
        df.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        
        return  df.date(from: string) as? NSDate
    }
    
    //当前时间的描述信息
    //今天：刚刚。X分钟前 X小时前
    //昨天：HH：mm
    //MM-dd HH:mm(一年前)
    //yyyy-MM-dd HH:mm(更早期)
    var dateDescription: String{
        
        //取出当前日厉 - 提供了大量相关的操作函数
        let calender = NSCalendar.current
        
        //处理今天的日期
        if calender.isDateInToday(self as Date){
            
            let delta = Int(Date().timeIntervalSince(self as Date))
            
            if delta < 60 {
                return "刚刚"
            }
            if delta < 3600{
                return "\(delta / 60)分钟前"
                
            }
            
            return "\(delta / 3600)小时前"
        }
        
        //非今天日期
        var fmt = "HH:mm"
        if calender.isDateInYesterday(self as Date){
           fmt =  "昨天 " + fmt
        }else{
            fmt = "MM-dd " + fmt
            
            //直接获取“年”的数值
            // print(calender.component(.year, from: self as Date))
            
            //比较两个日期之间是否有一个完整的年度差值
            let comps = calender.dateComponents([.year], from: self as Date, to: NSDate() as Date)
            print(comps.year as Any)
            
            if comps.year! > 0 {
                fmt = "yyyy-" + fmt
            }
        }
        //根据格式字符串生成描述字符串
        let df = DateFormatter()
        
        df.locale = Locale(identifier: "en")
        df.dateFormat = fmt
        
        return df.string(from: self as Date)
        
    }
}
