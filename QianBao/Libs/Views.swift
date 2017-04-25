//
//  Views.swift
//  QianBao
//
//  Created by zhiyuan10 on 2017/4/25.
//  Copyright © 2017年 zhiyuan. All rights reserved.
//
import UIKit
import Foundation

class NavView{
    var viewW:CGFloat
    var midW:CGFloat
    var view:UIView
    var btnLeft:UIButton
    var btnMid:UIButton
    var btnRight:UIButton
    
    init(){
        viewW = ScreenW-65*2
        midW = (viewW-185)/2
        view     = UIView(frame: CGRect(x: 65, y: 0, width: viewW, height: 44))
        btnLeft  = UIButton(frame: CGRect(x: 0 , y: 1, width: midW, height: 44))
        btnMid   = UIButton(frame: CGRect(x: midW , y: 1, width: 185, height: 44))
        btnRight = UIButton(frame: CGRect(x: midW + 185 , y: 1, width: midW, height: 44))
    }
    
    func view(title:String)->UIView { //导航条上的按钮
        btnLeft.setTitle("<",for:UIControlState())
        btnLeft.setTitleColor(UIColor(hex:0x1499d7,alpha:1), for: UIControlState())
        btnLeft.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        btnRight.setTitle(">",for:UIControlState())
        btnRight.setTitleColor(UIColor(hex:0x1499d7,alpha:1), for: UIControlState())
        btnRight.titleLabel?.font = UIFont.systemFont(ofSize: 20) 
        
        btnMid.setTitleColor(UIColor(hex:0x1499d7,alpha:1), for: UIControlState())
        btnMid.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btnMid.setTitle(title,for:UIControlState())
        view.addSubview(btnLeft)
        view.addSubview(btnMid)
        view.addSubview(btnRight)
        return view
    }
    
 
}
