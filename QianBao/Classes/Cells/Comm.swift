//
//  HomeCell.swift
//  NaturePark
//
//  Created by lzy on 15/8/6.
//  Copyright (c) 2015年 ituxing. All rights reserved.
//

import Foundation
enum CommCellStyle {
 
    case hotView
}

class CommCell :UITableViewCell {
 
    var navCollectionView :UICollectionView!
    var collectionView :UICollectionView! 
    convenience init(cellStyle: CommCellStyle,reuseIdentifier:String?){
        self.init(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        switch cellStyle {
  
        case .hotView:
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.itemSize = CGSize(width:ScreenW, height:150)
            flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            collectionView = UICollectionView(frame:  CGRect(x: 0, y: 0, width: ScreenW, height: 150), collectionViewLayout: flowLayout)
            collectionView.backgroundColor = UIColor.white
            collectionView.isPagingEnabled = true
            collectionView.setContentOffset(CGPoint(x:ScreenW,y:0), animated: false) //默认翻到中间一页
            collectionView.showsHorizontalScrollIndicator = false  //不显示水平滚动条
            collectionView.register(CollectCell.self, forCellWithReuseIdentifier: "navCollectCellId")
            self.addSubview(collectionView!)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier:reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

