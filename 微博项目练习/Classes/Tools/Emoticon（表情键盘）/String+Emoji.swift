//
//  String+Emoji.swift
//  表情键盘
//
//  Created by 云动家 on 2023/5/8.
//

import Foundation

extension String {
    
    // 从当前 16 进制字符串中扫描生成 emoji 字符串
    var emoji: String {
        //文本扫描器-扫描指定格式的字符串
        let scanner = Scanner(string: self)
        //unicode值
        var value: UInt64 = 0
        scanner.scanHexInt64(&value)
        //转换为unicode‘字符’
        let chr = Character(UnicodeScalar(UInt32(value))!)
        //转换成字符串
        return "\(chr)"
    }
}
