//
//  DateCell.swift
//  QianBao
//
//  Created by zhiyuan10 on 2017/12/17.
//  Copyright © 2017年 zhiyuan. All rights reserved.
//
import PNChart
class CollectCell: UICollectionViewCell {    
        var iconImage : UIImageView?
        var title : UILabel?
        var barChart = PNBarChart(frame: CGRect(x: 0, y: 0, width: ScreenW, height: 150))
        // by Storyboard/xib
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // by code
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = UIColor.lightGray
            
            barChart.xLabels  = ["衣服", "食品", "住房", "交通", "用品", "医疗","娱乐","饰品","学习","通讯","往来","美容","汽车","旅游","运动","维修","投资","宠物","捐赠","家居",]
            barChart.showLabel = false //是否显示xy轴的文字
            barChart.isShowNumbers = false //在柱状图里面显示数字
            barChart.showLevelLine = false //true 时有一条线，并且显示了底部文字
            barChart.showChartBorder = false //横竖轴线
            barChart.isGradientShow = false
            barChart.strokeColors = [UIColor(hex: 0xE578AA),UIColor(hex: 0xFA675D),UIColor(hex: 0x6498CE),UIColor(hex: 0xA4A2E7),UIColor(hex: 0x5DC179),UIColor(hex: 0x8D9FDB),UIColor(hex: 0xFEB555),UIColor(hex: 0xBFCD53),UIColor(hex: 0x74D9AC),UIColor(hex: 0x789EEA),UIColor(hex: 0xFC8C62),UIColor(hex: 0xB79FE2),UIColor(hex: 0xA5C24A),UIColor(hex: 0x64C3BA),UIColor(hex: 0xF46E9C),UIColor(hex: 0xDCAE77),UIColor(hex: 0xFD7A7F),UIColor(hex: 0x64B2D9),UIColor(hex: 0xF0AF49),UIColor(hex: 0xE9BF72)]
            self.barChart.chartMarginLeft = 25;
            self.barChart.chartMarginTop = 25;
            self.barChart.chartMarginBottom = 50;
            self.addSubview(barChart)
            
            
            let a = UILabel(frame: CGRect(x: 30, y: 0, width: 150, height: 20))
            a.text = "收入：100元"
            a.textColor = UIColor.black
            a.font = FONT(14)
            self.addSubview(a)
            
            let b = UILabel(frame: CGRect(x: 200, y: 0, width: 150, height: 20))
            b.text = "支出：200元" //self.db.expenseSum.format(".2") 
            b.textColor = UIColor.black
            b.font = FONT(14)
            self.addSubview(b)
            
            
        }
}

