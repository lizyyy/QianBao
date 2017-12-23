//
//  Button.swift
//  NaturePark
//
//  Created by leeey on 15/5/26.
//  Copyright (c) 2015年 ituxing. All rights reserved.
//

import Foundation
extension UIButton{
 
    
    //详情页导航按钮-未选中
    func withImg(image:UIImage ,withTitle title:String,forState state:UIControlState = UIControlState.normal){
        
        self.setTitle(title, for: state)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        self.setTitleColor(UIColor.gray, for: state)
        self.backgroundColor = UIColor.white
        self.titleLabel?.textAlignment = NSTextAlignment.center
        self.setImage(image, for: state)
        self.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
    }

    
}

