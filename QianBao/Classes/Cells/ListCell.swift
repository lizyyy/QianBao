//
//  ListCell.swift
//  qian8new
//
//  Created by zhiyuan10 on 2016/12/12.
//  Copyright © 2016年 leeey. All rights reserved.
//

import UIKit
import Foundation
enum ListCellStyle {
    case Expense //支出
    case Income //收入
    case Transf //转账
}

class ListCellView : UITableViewCell {
    //公用
    var money    = UILabel(frame:CGRect(x:80, y:10, width:120, height:20))
    var time     = UILabel(frame:CGRect(x:ScreenW - 67, y:40, width:65, height:14))
    var note     = UILabel(frame:CGRect(x:ScreenW/2+20, y:10, width:150, height:20))
    var bankFrom = UILabel(frame:CGRect(x:60, y:40, width:150, height:12))
    var user     = UILabel(frame:CGRect(x:ScreenW - 90, y:40, width:20, height:14))
    var type     = UILabel(frame:CGRect(x:8, y:5, width:38, height:38))
    //支出
    var icon = CALayer()
    //转账
    var bankTo = UILabel(frame:CGRect(x:60, y:40, width:150, height:12))
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier:reuseIdentifier)
    }
    
    convenience init(cellStyle: ListCellStyle,reuseIdentifier:String?){
        self.init(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        //金额
        money.font     = UIFont.systemFont(ofSize: 18)
        money.textColor = UIColor(hex:0xfdc1f51,alpha:1)
        //时间
        time.font  = UIFont.systemFont(ofSize: 10)
        time.textColor = UIColor.gray
        //备注
        note.font      = UIFont.systemFont(ofSize: 14)
        note.textColor = UIColor.darkGray
        //银行
        bankFrom.font      = UIFont.systemFont(ofSize: 10)
        bankFrom.textColor = UIColor.gray
        //类型
        type.font       = UIFont.systemFont(ofSize: 14)
        //用户名
        user.font = UIFont.systemFont(ofSize:11)
        user.textColor = UIColor.gray
        
        switch cellStyle {
        case .Expense:
            icon.frame =  CGRect(x:8, y:8, width:38, height:38)
            money.textColor = UIColor(hex:0x1499d7,alpha:1)
            type.isHidden = true
            self.layer.addSublayer(icon);
        case .Income:
            money.textColor = UIColor(hex:0xfdc1f51,alpha:1)
        case .Transf:
            money.textColor  = UIColor(hex:0x816b46,alpha:1)
            bankTo.font      = UIFont.systemFont(ofSize: 10)
            bankTo.textColor = UIColor.gray
            user.isHidden    = true
            self.addSubview(bankTo)
        }
        self.addSubview(type)
        self.addSubview(note)
        self.addSubview(time)
        self.addSubview(money)
        self.addSubview(bankFrom)
        self.addSubview(user)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
