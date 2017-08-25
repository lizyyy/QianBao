//
//  AddPayViewController.swift
//  qian8
//
//  Created by leeey on 14/7/26.
//  Copyright (c) 2014年 leeey. All rights reserved.
//

import Foundation
import UIKit
class SelectViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,HooDatePickerDelegate{
    var savebutton  = UIButton(frame: CGRect(x: (ScreenW-50)/2 - 30, y: 265, width: 50, height: 47))
    var pickerView  = UIPickerView(frame: CGRect(x: 0, y: ScreenH-200, width: ScreenW, height: 200))
    var timebtn     = UIButton(type: UIButtonType.system)
    var button      = UIButton(type: UIButtonType.system)
    var selpage:frompage!
    var userKV      = Dictionary<Int,userItem>() 
    var ctgKV = Dictionary<Int,Any>()
    var selUser = 0
    var selCtg  = 0
    var selDate = NSDate()
    var pickerDate = NSDate()
    var datepicker:HooDatePicker?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "筛选"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.plain, target: self, action:#selector(AddPayViewController.cancel))
        timebtn.frame = CGRect( x: 0, y: 150, width: ScreenW, height: 40 )
        button.frame = CGRect( x: 0, y: 80, width: ScreenW, height: 44 )
        //pickerview 定义
        userKV = DBRecord().userKV()
        switch selpage {
            case .income:
                ctgKV = DBRecord().incomeKV()
                break;
            case .pay:
                ctgKV = DBRecord().expensesKV()
            case .transf:
                ctgKV = DBRecord.changeType()
            default:break;
        }
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView.selectRow(selUser, inComponent: 0, animated: false)
        pickerView.selectRow(selCtg, inComponent: 1, animated: false)
        
        datepicker = HooDatePicker(superView: self.view)
        datepicker?.setTintColor(UIColor.lightGray)
        datepicker?.setHighlight(UIColor.black)
        datepicker?.delegate = self
        datepicker?.datePickerMode = .yearAndMonth
        
        datepicker?.setDate(self.selDate as Date!, animated: true)
        datepicker?.show()
        payView()
    }
    
    // MARK: - payView
    func payView() {
        //选择分类层
        button.backgroundColor =  UIColor.white
        button.setTitleColor(UIColor.gray, for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        switch selpage {
        case .income:
            button.setTitle("\(userKV[selUser]!.user) - \((ctgKV[selCtg]! as! incomeItem).name)", for: UIControlState())
            break;
        case .pay:
            button.setTitle("\(userKV[selUser]!.user) - \((ctgKV[selCtg]! as! expenseItem).name)", for: UIControlState())
        case .transf:
            button.setTitle("\(String(describing: DBRecord.changeTypeAll()[selCtg]!))", for: UIControlState())
        default:break;
        }
        button.addTarget(self, action: #selector(self.selCtgAction), for: UIControlEvents.touchUpInside)
        //保存
        savebutton.backgroundColor = UIColor.clear
        savebutton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        savebutton.setTitle("筛选",for:UIControlState());
        savebutton.setTitleColor(UIColor(hex:0x1499d7,alpha:1), for: UIControlState())
        savebutton.setTitleColor(UIColor(hex:0x1499d7,alpha:1), for: UIControlState.highlighted)
        savebutton.addTarget(self, action: #selector(self.done), for: UIControlEvents.touchUpInside)
        //时间
        timebtn.backgroundColor =  UIColor.white
        timebtn.setTitleColor(UIColor.gray, for: UIControlState())
        timebtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        timebtn.setTitle(toMonth(date: self.selDate), for: UIControlState())
        timebtn.addTarget(self, action: #selector(self.selTime), for: UIControlEvents.touchUpInside)
        //添加
        self.view.addSubview(savebutton)
        self.view.addSubview(button)
        self.view.addSubview(timebtn)
    }
    
    func 收起所有输入面板(){
        pickerView.removeFromSuperview()
        datepicker?.dismiss()
    }
    
    func selCtgAction(){
        收起所有输入面板()
        self.view.addSubview(pickerView)
    }
    
    func selTime(){
        收起所有输入面板()
        datepicker?.show()
    }
    
    func datePicker(_ datePicker: HooDatePicker!, dateDidChange date: Date!) {
        timebtn.setTitle(toMonth(date: date as NSDate), for: UIControlState())
        pickerDate = date! as NSDate
    }

    
    // MARK: - UIPickerDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(component == 0){
            return selpage == .transf ? 1 : userKV.count
        }else if(component == 1) {
            return selpage == .transf ? DBRecord.changeTypeAll().count : ctgKV.count
        }
        return 0
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
            myView.text = selpage == .transf ? "" : userKV[row]!.user
            
        }else if(component == 1) {
            myView.frame = CGRect(x: 10, y: 0.0, width: 60, height: 40)
            switch selpage {
            case .income:
                myView.text = (ctgKV[row]! as! incomeItem).name
                break;
            case .pay:
                myView.text = (ctgKV[row]! as! expenseItem).name
            case .transf:
                myView.text =  DBRecord.changeTypeAll()[row]!
            default:break;
            }
        }
        return myView;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(pickerView.selectedRow(inComponent: 0))
        print(pickerView.selectedRow(inComponent: 1))
        let user =  userKV[pickerView.selectedRow(inComponent: 0)]!.user
        var ctg = ""
        switch selpage {
        case .income:
            ctg = (ctgKV[pickerView.selectedRow(inComponent: 1)]! as! incomeItem).name
            button.setTitle("\(user)-\(ctg)", for: UIControlState())
            break;
        case .pay:
            ctg = (ctgKV[pickerView.selectedRow(inComponent: 1)]! as! expenseItem).name
            button.setTitle("\(user)-\(ctg)", for: UIControlState())
        case .transf:
            ctg =  DBRecord.changeTypeAll()[pickerView.selectedRow(inComponent: 1)]!
            button.setTitle("\(ctg)", for: UIControlState())
        default:break;
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func done(){
        //获取所有数据：
        let userid:Int  = userKV[pickerView.selectedRow(inComponent: 0)]!.id
        var ctgid:Int   = 0
        let date:NSDate = self.pickerDate
        switch selpage {
        case .income:
            ctgid = (ctgKV[pickerView.selectedRow(inComponent: 1)]! as! incomeItem).id
            break;
        case .pay:
            ctgid = (ctgKV[pickerView.selectedRow(inComponent: 1)]! as! expenseItem).id
        case .transf:
            ctgid =  pickerView.selectedRow(inComponent: 1)
        default:break;
        }
        HUD.alert(self.view,text: "查询中..")
        收起所有输入面板()
        DispatchQueue.main.async {
            self.close()
            DispatchQueue.main.async(execute: {
                HUD.close(self.view) 
            })
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "newsel"), object: nil, userInfo: ["userid":userid,"ctgid":ctgid,"date":date])
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
