//
//  config.swift
//  QianBao
//
//  Created by zhiyuan10 on 2017/7/25.
//  Copyright © 2017年 zhiyuan. All rights reserved.
//

import Foundation
let BtnColor = UIColor(hex:0x1499d7,alpha:1)
//默认色板
let themeColor = RGBA(r: 10,g: 184,b: 146,a: 1)
let darkThemeColor = RGBA(r: 10,g: 200,b: 146,a: 1)
let lightlightColor = RGBA(r: 225, g: 225, b: 225, a: 1)
let user = ["","all","lzy","jyy"]

var ScreenW:CGFloat{
    return UIScreen.main.bounds.width
}

var ScreenH:CGFloat{
    return UIScreen.main.bounds.height
}


var 更新锁:Bool = false
var renew:Bool = false


let apiUrl = UserDefaults.standard.string(forKey: "apiUrl")!

enum frompage{ //来源页面
    case pay,income,transf
}
