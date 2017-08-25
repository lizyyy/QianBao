//
//  AddPayViewController.swift
//  qian8
//
//  Created by leeey on 14/7/26.
//  Copyright (c) 2014年 leeey. All rights reserved.
//

import Foundation
import UIKit
class AddTransfViewController: UIViewController,ZYKeyboardDelegate,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource{
    var line        = UIView(frame: CGRect(x: 20, y: 110, width: ScreenW-40, height: 1))
    var money       = UITextField(frame: CGRect(x: 20, y: 174, width: ScreenW-40, height: 40))
    var view1       = UIView(frame: CGRect(x: 0, y: 200, width: 320, height: 49))
    var desctext    = UITextField(frame: CGRect(x: 25, y: 229, width: 239, height: 40))
    var savebutton  = UIButton(frame: CGRect(x: (ScreenW-50)/2 - 30, y: 265, width: 50, height: 47))
    var cancelbutton  = UIButton(frame: CGRect(x: (ScreenW-50)/2 + 35, y: 265, width: 50, height: 47))
    var zykeyboard  = ZYKeyboard(frame: CGRect(x: 0,y: 0,width: 0,height: 252))
    var pickerView  = UIPickerView(frame: CGRect(x: 0, y: ScreenH-220, width: ScreenW, height: 252))
    var datePicker  = UIDatePicker(frame: CGRect(x: 0, y: ScreenH-220, width: ScreenW, height: 252))
    var timebtn     = UIButton(type: UIButtonType.system)
    var button      = UIButton(type: UIButtonType.system)
    var userKV      = Dictionary<Int,userItem>()
    var typeKV      = Dictionary<Int,String>()
    var bankKV      = [bankItem]()
    let db = DBRecord()
    dynamic var newadd : NSNumber!; //监听属性，发生变化时刷新列表页
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "添加转账"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action:#selector(AddPayViewController.cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.plain, target: self, action:#selector(AddPayViewController.done))
        timebtn.frame = CGRect( x: 25, y: 120, width: 120, height: 40 )
        button.frame = CGRect( x: 0, y: 64, width: ScreenW, height: 44 )
        datePicker.locale =  Locale(identifier: "zh_CN")
        datePicker.timeZone = TimeZone.current
        //pickerview 定义
        userKV = DBRecord().userKV()
        typeKV = DBRecord.changeType()
        bankKV = DBRecord().getBank()
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView.selectRow(UserDefaults.standard.integer(forKey: "DeviceID"), inComponent: 0, animated: false)
        pickerView.selectRow(2, inComponent: 1, animated: false)
        if(UserDefaults.standard.integer(forKey: "DeviceID") == 1){
            pickerView.selectRow(3, inComponent: 0, animated: false)
            pickerView.selectRow(0, inComponent: 2, animated: false)
        }else{
            pickerView.selectRow(9, inComponent: 0, animated: false)
            pickerView.selectRow(10, inComponent: 2, animated: false)
        }
        payView()
    }
    
    // MARK: - payView
    func payView() {
        //金额
        money.attributedPlaceholder = NSAttributedString(
            string: "￥0.00",
            attributes: [NSForegroundColorAttributeName: UIColor(hex:0x1499d7,alpha:1)])
        money.textColor = UIColor(hex:0x1499d7,alpha:1)
        money.font = UIFont.boldSystemFont(ofSize: 40)
        money.textAlignment = NSTextAlignment.right
        money.delegate = self
        money.tag = 1
        //金额键盘
        money.inputView = zykeyboard
        zykeyboard.delegate = self
        zykeyboard.txtResult = money
        money.becomeFirstResponder()
        //选择分类层
        button.backgroundColor =  UIColor.white
        button.setTitleColor(UIColor.gray, for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        if(UserDefaults.standard.integer(forKey: "DeviceID")  == 1 ){
            button.setTitle("LZY【BJ招行】工资卡→转取钱→LZY【现金】", for: UIControlState())
        }else{
            button.setTitle("JYY【XF招行】信用卡→转取钱→JYY【现金】`", for: UIControlState())
        }
        button.addTarget(self, action: #selector(AddPayViewController.selCtg), for: UIControlEvents.touchUpInside)
        line.backgroundColor = UIColor(hex:0xD1D5Db,alpha:1)
        //保存
        savebutton.backgroundColor = UIColor.clear
        savebutton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        savebutton.setTitle("完成",for:UIControlState());
        savebutton.setTitleColor(UIColor(hex:0x1499d7,alpha:1), for: UIControlState())
        savebutton.setTitleColor(UIColor(hex:0x1499d7,alpha:1), for: UIControlState.highlighted)
        savebutton.addTarget(self, action: #selector(AddPayViewController.done), for: UIControlEvents.touchUpInside)
        //取消
        cancelbutton.backgroundColor = UIColor.clear
        cancelbutton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        cancelbutton.setTitle("取消",for:UIControlState());
        cancelbutton.setTitleColor(UIColor(hex:0x1499d7,alpha:1), for: UIControlState())
        cancelbutton.setTitleColor(UIColor(hex:0x1499d7,alpha:1), for: UIControlState.highlighted)
        cancelbutton.addTarget(self, action: #selector(AddPayViewController.cancel), for: UIControlEvents.touchUpInside)
        //备注
        desctext.delegate = self
        desctext.tag = 2
        desctext.backgroundColor = UIColor.white
        desctext.attributedPlaceholder = NSAttributedString(string: "转账备注", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        desctext.font = UIFont.systemFont(ofSize: 18)
        desctext.textColor = UIColor.black
        self.view.addSubview(desctext)
        //时间
        timebtn.backgroundColor =  UIColor.white
        timebtn.setTitleColor(UIColor.gray, for: UIControlState())
        timebtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        timebtn.setTitle(today(), for: UIControlState())
        timebtn.addTarget(self, action: #selector(AddPayViewController.selTime), for: UIControlEvents.touchUpInside)
        //添加
        self.view.addSubview(cancelbutton)
        self.view.addSubview(savebutton)
        self.view.addSubview(money)
        self.view.addSubview(button)
        self.view.addSubview(line)
        self.view.addSubview(timebtn)
    }
    
    func 收起所有输入面板(){
        money.resignFirstResponder()
        desctext.resignFirstResponder()
        datePicker.removeFromSuperview()
        pickerView.removeFromSuperview()
    }
    
    func selCtg(){
        收起所有输入面板()
        self.view.addSubview(pickerView)
    }
    
    func selTime(){
        收起所有输入面板()
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.date = datePicker.date
        datePicker.addTarget(nil, action: #selector(AddPayViewController.datePickerDateChanged(_:)), for: UIControlEvents.valueChanged)
        self.view.addSubview(datePicker)
    }
    
    func datePickerDateChanged(_ sender:UIDatePicker){
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        timebtn.setTitle(fmt.string(from: sender.date), for: UIControlState())
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField.tag == 1){ //打开金额键盘
            desctext.resignFirstResponder()
        }
        if(textField.tag == 2){ //打开备注键盘
            money.resignFirstResponder()
        }
        datePicker.removeFromSuperview()
        pickerView.removeFromSuperview()
    }
    
    // MARK: - UIPickerDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(component == 0){
            return bankKV.count
        }else if(component == 1) {
            return typeKV.count
        }
        else if(component == 2) {
            return bankKV.count
        }
        return 0;
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if(component == 0){
            return 130;
        }else if(component == 1) {
            return 40;
        }
        else if(component == 2) {
            return 130;
        }
        return 0;
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let myView = UILabel()
        myView.font = UIFont.systemFont(ofSize: 12)
        myView.backgroundColor = UIColor.clear
        if(component == 0){
            myView.text =  bankKV[row].name
            myView.textAlignment = NSTextAlignment.left
        }else if(component == 1) {
            myView.text =  typeKV[row+1]!
            myView.textAlignment = NSTextAlignment.center
        }else if(component == 2) {
            myView.text =  bankKV[row].name
            myView.textAlignment = NSTextAlignment.right
        }
        return myView;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let bankfrom =  bankKV[pickerView.selectedRow(inComponent: 0)].name
        let type = typeKV[pickerView.selectedRow(inComponent: 1)+1]!
        let bankto = bankKV[pickerView.selectedRow(inComponent: 2)].name
        button.setTitle("\(bankfrom)-\(type)-\(bankto)", for: UIControlState())
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func done(){
        if(!checkForm()){return}
        //获取所有数据：
        let fromebankid:Int  = bankKV[pickerView.selectedRow(inComponent: 0)].id
        let ctgid:Int   = pickerView.selectedRow(inComponent: 1)
        let tobankid:Int  = bankKV[pickerView.selectedRow(inComponent: 2)].id
        let date:String = self.timebtn.title(for: UIControlState())!
        let desc:String = self.desctext.text!
        let money:String = self.money.text!.replacingOccurrences(of: "￥", with: "")
        let uid:String = String(UserDefaults.standard.integer(forKey: "DeviceID"))
        //var msg = String()
        var updateData = Dictionary<String,String>()
        //处理银行扣款
        if( fromebankid == tobankid ){ //定活互转
            var sqlBank1 = String()
            switch (ctgid) {
            case 0:
                sqlBank1 = "update qian8_bank set `current_deposit`=`current_deposit`-\(money),`fixed_deposit`=`fixed_deposit`+\(money) where `id`=\(tobankid)"
                updateData = ["current_deposit":"`current_deposit`-\(money)","fixed_deposit":"`fixed_deposit`+\(money)"]
            case 1:
                sqlBank1 = "update qian8_bank set `current_deposit`=`current_deposit`+\(money),`fixed_deposit`=`fixed_deposit`-\(money) where `id`=\(tobankid)"
                updateData = ["current_deposit":"`current_deposit`+\(money)","fixed_deposit":"`fixed_deposit`-\(money)"]
            default:
                self.present(simpleAlert(msg: "同一银行卡只能定活互转") , animated: true, completion: nil)
                return
            }
            let sqlRsync1 = "insert into qian8_sync_list (master_id,action_id,table_id,user_id,rsync_status,rsync_rs,data,local_id) values  ('\(tobankid)','2','1','\(uid)','0','0','\(toJSONString2(updateData as NSDictionary))','\(tobankid)')"
            if(!db.execute(sql:sqlBank1) || !db.execute(sql:sqlRsync1)){print("add error")}
        }else{ //银行间转账
            if (ctgid != 2) {
                self.present(simpleAlert(msg: "不同银行卡间不能定活互转") , animated: true, completion: nil)
                return
            }
            let sqlBank2  = "update `qian8_bank` set `current_deposit` =`current_deposit`-\(money) where  `id`='\(fromebankid)'"
            let updateData2 = ["current_deposit":"`current_deposit`-\(money)"]
            let sqlRsync2 = "insert into qian8_sync_list (master_id,action_id,table_id,user_id,rsync_status,rsync_rs,data,local_id) values  ('\(fromebankid)','2','1','\(uid)','0','0','\(toJSONString2(updateData2 as NSDictionary))','\(fromebankid)')"
            let sqlBank3 = "update `qian8_bank` set `current_deposit` =`current_deposit`+\(money) where `id`='\(tobankid)'"
            let updateData3 = ["current_deposit":"`current_deposit`+\(money)"]
            let sqlRsync3 = "insert into qian8_sync_list (master_id,action_id,table_id,user_id,rsync_status,rsync_rs,data,local_id) values  ('\(tobankid)','2','1','\(uid)','0','0','\(toJSONString2(updateData3 as NSDictionary))','\(tobankid)')"
            if(!db.execute(sql:sqlBank2) || !db.execute(sql:sqlRsync2) || !db.execute(sql:sqlBank3) || !db.execute(sql:sqlRsync3) ){print("add error")}
        }
        //记录转账记录
        let sqlList = "insert into qian8_bank_list(from_bank_id,to_bank_id,time,money,type,demo,sn) values ('\(fromebankid)','\(tobankid)','\(date)','\(money)','\(ctgid+1)','\(desc)','0')"
        if (!db.execute(sql:sqlList) ) {print("add qian8_bank_list error")}
        let lastid = db.lastid()
        //保存同步
        let sqlRsyncList = "insert into qian8_sync_list (master_id,action_id,table_id,user_id,rsync_status,rsync_rs,data,local_id) values  ('0','1','2','\(uid)','0','0','|\(fromebankid)|\(tobankid)|\(date)|\(money)|\(ctgid+1)|\(desc)|0','\(lastid)')"
        if (!DBRecord().execute(sql:sqlRsyncList)) { print("add qian8_sync_list error") }
        收起所有输入面板()
        DispatchQueue.main.async {
            self.close()
            DispatchQueue.main.async(execute: { HUD.close(self.view)})
        }
        newadd = 1 //刷新列表页
    }
    
    func cancel(){
        收起所有输入面板()
        self.dismiss(animated: true, completion: nil)
    }
    
    func close(){ self.dismiss(animated: true, completion: nil) }
    
    func closekeyboard(){  收起所有输入面板() }
    
    // MARK: - checkForm
    func checkForm() -> Bool{
        guard self.money.text! != "" else{
            self.present(simpleAlert(msg: "金额不能为空") , animated: true, completion: nil)
            return false
        }
        let money:String =  self.money.text!.replacingOccurrences(of: "￥", with: "")
        if Float(money) == nil {
            self.present(simpleAlert(msg: "金额不正确") , animated: true, completion: nil)
            return false
        }
        guard self.desctext.text! != "" else {
            self.present(simpleAlert(msg: "备注不能为空") , animated: true, completion: nil)
            return false
        }
        return true
    }
    
    deinit {self.removeObserver(self, forKeyPath: "newadd", context: nil);}
}
