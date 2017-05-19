//
//  AddPayViewController.swift
//  qian8
//
//  Created by leeey on 14/7/26.
//  Copyright (c) 2014年 leeey. All rights reserved.
//

import Foundation
import UIKit
class SelectViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
    var savebutton  = UIButton(frame: CGRect(x: (ScreenW-50)/2 - 30, y: 265, width: 50, height: 47))
    var cancelbutton = UIButton(frame: CGRect(x: (ScreenW-50)/2 + 35, y: 265, width: 50, height: 47))
    var pickerView  = UIPickerView(frame: CGRect(x: 0, y: ScreenH-220, width: ScreenW, height: 252))
    var timebtn     = UIButton(type: UIButtonType.system)
    var button      = UIButton(type: UIButtonType.system)
    
    var userKV      = Dictionary<Int,userItem>()
    var expensesKV  = Dictionary<Int,expenseItem>()
    var selUser = 1
    var selCtg  = 0
    var selDate = NSDate()
    dynamic var newadd : NSNumber!; //监听属性，发生变化时刷新列表页
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "筛选"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.plain, target: self, action:#selector(AddPayViewController.cancel))
        timebtn.frame = CGRect( x: 0, y: 150, width: ScreenW, height: 40 )
        button.frame = CGRect( x: 0, y: 80, width: ScreenW, height: 44 )
        //pickerview 定义
        userKV = DBRecord().userKV()
        expensesKV = DBRecord().expensesKV()
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView.selectRow(UserDefaults.standard.integer(forKey: "DeviceID"), inComponent: 0, animated: false)
        pickerView.selectRow(1, inComponent: 1, animated: false)
        payView()
    }
    
    // MARK: - payView
    func payView() {
        //选择分类层
        button.backgroundColor =  UIColor.white
        button.setTitleColor(UIColor.gray, for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("\(userKV[selUser]!.user) - \(expensesKV[selCtg]!.name)", for: UIControlState())
        button.addTarget(self, action: #selector(self.selCtgAction), for: UIControlEvents.touchUpInside)
        //保存
        savebutton.backgroundColor = UIColor.clear
        savebutton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        savebutton.setTitle("筛选",for:UIControlState());
        savebutton.setTitleColor(UIColor(hex:0x1499d7,alpha:1), for: UIControlState())
        savebutton.setTitleColor(UIColor(hex:0x1499d7,alpha:1), for: UIControlState.highlighted)
        savebutton.addTarget(self, action: #selector(self.done), for: UIControlEvents.touchUpInside)
        //取消
        cancelbutton.backgroundColor = UIColor.clear
        cancelbutton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        cancelbutton.setTitle("全部",for:UIControlState());
        cancelbutton.setTitleColor(UIColor(hex:0x1499d7,alpha:1), for: UIControlState())
        cancelbutton.setTitleColor(UIColor(hex:0x1499d7,alpha:1), for: UIControlState.highlighted)
        cancelbutton.addTarget(self, action: #selector(self.cancel), for: UIControlEvents.touchUpInside)
        //时间
        timebtn.backgroundColor =  UIColor.white
        timebtn.setTitleColor(UIColor.gray, for: UIControlState())
        timebtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        timebtn.setTitle(toMonth(date: self.selDate), for: UIControlState())
        timebtn.addTarget(self, action: #selector(self.selTime), for: UIControlEvents.touchUpInside)
        //添加
        self.view.addSubview(cancelbutton)
        self.view.addSubview(savebutton)
        self.view.addSubview(button)
        self.view.addSubview(timebtn)
    }
    
    func 收起所有输入面板(){
        pickerView.removeFromSuperview()
    }
    
    func selCtgAction(){
        收起所有输入面板()
        self.view.addSubview(pickerView)
    }
    
    func selTime(){
        收起所有输入面板()
    }
    
    func datePickerDateChanged(_ sender:UIDatePicker){
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        timebtn.setTitle(fmt.string(from: sender.date), for: UIControlState())
    }
    
    // MARK: - UIPickerDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(component == 0){
            return userKV.count
        }else if(component == 1) {
            return expensesKV.count
        }
        return 0;
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if(component == 0){
            return 40;
        }else if(component == 1) {
            return 60;
        }
        return 0;
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let myView = UILabel()
        myView.font = UIFont.systemFont(ofSize: 18)
        myView.backgroundColor = UIColor.clear
        if(component == 0){
            myView.frame = CGRect(x: 10, y: 0, width: 40, height: 40)
            myView.text =  userKV[row+1]!.user
        }else if(component == 1) {
            myView.frame = CGRect(x: 10, y: 0.0, width: 60, height: 40)
            myView.text =  expensesKV[row+1]!.name
        }
        return myView;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let user =  userKV[pickerView.selectedRow(inComponent: 0)]!.user
        let ctg = expensesKV[pickerView.selectedRow(inComponent: 1)]!.name
        button.setTitle("\(user)-\(ctg)", for: UIControlState())
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func done(){
        //获取所有数据：
        let userid:Int  = userKV[pickerView.selectedRow(inComponent: 0)]!.id
        let ctgid:Int   = expensesKV[pickerView.selectedRow(inComponent: 1)]!.id
        let date:String = self.timebtn.title(for: UIControlState())!
        print(userid,ctgid,date)
        HUD.alert(self.view,text: "录入中..")
        收起所有输入面板()
        DispatchQueue.main.async {
            self.close()
            DispatchQueue.main.async(execute: {
                HUD.close(self.view) 
            })
        }
        newadd = 1 //刷新列表页
    }
    
    func cancel(){
        收起所有输入面板()
        self.dismiss(animated: true, completion: nil)
    }
    
    func close(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func closekeyboard(){
        收起所有输入面板()
    }
}
