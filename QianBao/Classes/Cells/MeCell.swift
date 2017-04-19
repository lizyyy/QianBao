//
//  MeCellView.swift
//  qian8new
//
//  Created by zhiyuan10 on 2016/11/22.
//  Copyright © 2016年 leeey. All rights reserved.
//
import UIKit
import Foundation
enum MeCellStyle {
    case total //顶部统计
    case bank //银行栏
    case footer //底部
}

class MeCellView : UITableViewCell {
    var view            = UIView()
    var current_deposit = UILabel()
    var fixed_deposit   = UILabel()
    var name            = UILabel()
    var card_no         = UILabel()
    var imageLayer      = CALayer()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier:reuseIdentifier)
    }
    
    convenience init(cellStyle: MeCellStyle,reuseIdentifier:String?){
        self.init(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        //最底层的背景
        view.layer.cornerRadius = 6
        view.frame              = CGRect(x: 10, y: 5, width:ScreenW - 20, height: 70)
        
        switch cellStyle {
        case .bank:
            imageLayer.frame        = CGRect(x: 3, y: 3, width:34, height:34)
            name.frame              = CGRect(x:60, y:15, width:(ScreenW-100)/2, height:15)
            card_no.frame           = CGRect(x:name.frame.origin.x, y:50, width:name.frame.size.width, height:11)
            fixed_deposit.frame     = CGRect(x:name.frame.origin.x + name.frame.size.width, y:40, width:name.frame.size.width - 10, height:16)
            current_deposit.frame   = CGRect(x:fixed_deposit.frame.origin.x, y:15, width:fixed_deposit.frame.size.width, height:fixed_deposit.frame.size.height)
            //加一个圆当背景
            let 😄 = UIView(frame:CGRect(x:5,y:5,width:40,height:40))
            😄.layer.cornerRadius = 😄.frame.size.width / 2;
            😄.backgroundColor = UIColor.white
            view.addSubview(😄)
            //放银行图片
            😄.layer.addSublayer(imageLayer)
            //名字
            name.font       = UIFont.systemFont(ofSize: 15)
            name.textColor  = UIColor.white
            //卡号
            card_no.font      = UIFont.systemFont(ofSize: 11)
            card_no.textColor = UIColor.white
            //活期和定期
            current_deposit.font        = UIFont.boldSystemFont(ofSize: 16)
            current_deposit.textAlignment = .right
            current_deposit.textColor   = UIColor.white
            fixed_deposit.font          = UIFont.boldSystemFont(ofSize: 16)
            fixed_deposit.textAlignment = .right
            fixed_deposit.textColor     = UIColor.white
            //addsubview
            view.addSubview(card_no)
            view.addSubview(fixed_deposit)
            view.addSubview(current_deposit)
        case .total:
            name.frame              = CGRect(x:20, y:15, width:(ScreenW-100)/2, height:18)
            fixed_deposit.frame     = CGRect(x:name.frame.origin.x + name.frame.size.width+10, y:40, width:name.frame.size.width - 10, height:16)
            current_deposit.frame   = CGRect(x:fixed_deposit.frame.origin.x, y:15, width:fixed_deposit.frame.size.width, height:fixed_deposit.frame.size.height)
            //名字
            name.font       = UIFont.systemFont(ofSize: 18)
            name.textColor  = UIColor(hex: 0x50A2EC)
            //活期和定期
            current_deposit.font        = UIFont.boldSystemFont(ofSize: 16)
            current_deposit.textColor   = UIColor(hex: 0x50A2EC)
            fixed_deposit.font          = UIFont.boldSystemFont(ofSize: 16)
            fixed_deposit.textColor     = UIColor(hex: 0x50A2EC)
            
            view.addSubview(name)
            view.addSubview(fixed_deposit)
            view.addSubview(current_deposit)
        case .footer:
            name.frame              = CGRect(x:20, y:26, width:(ScreenW-100)/2, height:18)
            //名字
            name.font       = UIFont.systemFont(ofSize: 18)
            name.textColor  = UIColor(hex: 0x50A2EC)
        }
        self.addSubview(view)
        view.addSubview(name)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
