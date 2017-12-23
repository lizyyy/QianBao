//
//  DateCell.swift
//  QianBao
//
//  Created by zhiyuan10 on 2017/12/17.
//  Copyright © 2017年 zhiyuan. All rights reserved.
//

class DateCell: UICollectionViewCell {
    
    let width = UIScreen.main.bounds.size.width//获取屏幕宽
    var imgView : UIImageView?//cell上的图片
    var titleLabel:UILabel?//cell上title
    var priceLabel:UILabel?//cell上价格
    var readLabel:UILabel?//cell上的阅读量
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.init(style: UICollectionView.sty, reuseIdentifier: reuseIdentifier)
        //初始化各种控件
        imgView = UIImageView(frame: CGRect(x:0, y:-10, width:(width-30)/2, height:200))
        self .addSubview(imgView!)
        titleLabel = UILabel(frame: CGRect(x:5, y:imgView!.frame.maxY-12, width:(width-40)/2, height:50))
        titleLabel?.numberOfLines = 0
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        titleLabel?.textColor = UIColor.lightGray
        self .addSubview(titleLabel!)
        
        priceLabel = UILabel(frame: CGRect(x:5, y:titleLabel!.frame.maxY, width:(width-40)/2/2, height:20))
        priceLabel?.numberOfLines = 0
        priceLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        priceLabel?.textColor = UIColor.lightGray
        self .addSubview(priceLabel!)
        
        readLabel = UILabel(frame: CGRect(x:(width-30)/2/2, y:titleLabel!.frame.maxY, width:(width-40)/2/2, height:20))
        readLabel?.numberOfLines = 0
        readLabel?.textAlignment = NSTextAlignment.right
        readLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        readLabel?.textColor = UIColor.lightGray
        self .addSubview(readLabel!)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

