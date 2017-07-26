//
//  tools.swift
//  qian8new
//
//  Created by zhiyuan10 on 2016/11/16.
//  Copyright © 2016年 leeey. All rights reserved.
//

import Foundation
import UIKit

extension Double {
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}




extension NSObject {
    class var nameOfClass: String {
        return NSStringFromClass(self).components(separatedBy: ".").last! as String
    }
    
    //用于获取 cell 的 reuse identifier
    class var identifier: String {
        return String(format: "%@_identifier", self.nameOfClass)
    }
}




func today()->String{
    let date = Date()
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "yyyy-MM-dd"
    let time = timeFormatter.string(from: date) as String
    return time
}

func month()->String{
    let date = Date()
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "yyyy-MM"
    let time = timeFormatter.string(from: date) as String
    return time
}






func toJSONString2(_ dict:NSDictionary!)->NSString{
    var data: Data?
    do {
        data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions())
    } catch _ {
        data = nil
    }
    let strJson = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
    return strJson!
}


extension UIColor {
    //16进制原生值
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}


func RGBA (r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat)->UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}




func createImageWithColor(color:UIColor, size rect:CGRect =  CGRect(x:0, y:0, width:1, height:1) ) ->UIImage {
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    context!.setFillColor(color.cgColor)
    context?.fill(rect)
    //context!.fillCGContextFillRect(context!,rect)
    let theImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return theImage!
}


