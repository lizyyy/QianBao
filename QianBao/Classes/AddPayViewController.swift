//
//  AddPayViewController.swift
//  qian8
//
//  Created by leeey on 14/7/26.
//  Copyright (c) 2014年 leeey. All rights reserved.
//
import Foundation
import UIKit
class AddPayViewController: UIViewController,ZYKeyboardDelegate,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource{
    var moneyTitle  = UILabel()
    var moneyText   = UITextField()
    var moneyLine   = UIView()
    var typeTitle   = UILabel()
    var typeBtn     = UIButton()
    var typeLine    = UIView()
    var timeTitle   = UILabel()
    var timeBtn     = UIButton()
    var timeLine    = UIView()
    var descTitle   = UILabel()
    var descText    = UITextField()
    var descLine    = UIView()
    var saveBtn     = UIButton()
    var cancelBtn   = UIButton()
    var zykeyboard  = ZYKeyboard(frame: CGRect(x: 0,y: 0,width: 0,height: 252))
    var pickerView  = UIPickerView(frame: CGRect(x: 0, y: ScreenH-220, width: ScreenW, height: 252))
    var datePicker  = UIDatePicker(frame: CGRect(x: 0, y: ScreenH-220, width: ScreenW, height: 252))
    var userKV      = Dictionary<Int,userItem>()
    var expensesKV  = Dictionary<Int,expenseItem>()
    var bankKV      = [bankItem]()
    let db = DBRecord()
    dynamic var newadd : NSNumber!; //监听属性，发生变化时刷新列表页
    
    func initView(){
        //标题
        moneyTitle  = UILabel(frame: CGRect(x: 25, y: 64+30, width: 100, height: 12))
        typeTitle   = UILabel(frame: CGRect(x: 25, y: moneyTitle.frame.origin.y + 80, width: 80, height: 12))
        timeTitle   = UILabel(frame: CGRect(x: 25, y: typeTitle.frame.origin.y + 80, width: 80, height: 12))
        descTitle   = UILabel(frame: CGRect(x: 25, y: timeTitle.frame.origin.y + 80, width: 80, height: 12))
        moneyTitle.text = "消费金额"
        typeTitle.text  = "消费分类"
        timeTitle.text  = "消费时间"
        descTitle.text  = "消费备注"
        moneyTitle.textColor = UIColor.lightGray
        typeTitle.textColor = UIColor.lightGray
        timeTitle.textColor = UIColor.lightGray
        descTitle.textColor = UIColor.lightGray
        moneyTitle.font = UIFont.systemFont(ofSize: 12)
        typeTitle.font = UIFont.systemFont(ofSize: 12)
        timeTitle.font = UIFont.systemFont(ofSize: 12)
        descTitle.font = UIFont.systemFont(ofSize: 12)
        //内容
        moneyText   = UITextField(frame: CGRect(x: 20, y: moneyTitle.frame.origin.y + 15, width: ScreenW-40, height: 40))
        typeBtn     = UIButton(frame:CGRect( x: 20, y: typeTitle.frame.origin.y + 15, width: ScreenW, height: 40 ))
        timeBtn     = UIButton(frame:CGRect(x: 20, y: timeTitle.frame.origin.y + 15, width: ScreenW, height: 40 ))
        descText    = UITextField(frame: CGRect(x: 20, y: descTitle.frame.origin.y + 20, width: ScreenW, height: 40))
        saveBtn  = UIButton(frame: CGRect(x: (ScreenW-50)/2 - 70, y: descText.frame.origin.y + 65, width: 120, height: 40))
        cancelBtn  = UIButton(frame: CGRect(x: (ScreenW-50)/2 + 70, y: descText.frame.origin.y + 65, width: 50, height: 40))
        //横线
        moneyLine   = UIView(frame: CGRect(x: 20, y: moneyText.frame.origin.y + moneyText.frame.height + 5, width: ScreenW-20, height: 1))
        typeLine    = UIView(frame: CGRect(x: 20, y: typeBtn.frame.origin.y + typeBtn.frame.height + 5, width: ScreenW-20, height: 1))
        timeLine    = UIView(frame: CGRect(x: 20, y: timeBtn.frame.origin.y + timeBtn.frame.height + 5, width: ScreenW-20, height: 1))
        descLine    = UIView(frame: CGRect(x: 20, y: descText.frame.origin.y + descText.frame.height + 5, width: ScreenW-20, height: 1))
        moneyLine.backgroundColor = UIColor(hex:0xD1D5Db,alpha:1)
        typeLine.backgroundColor = UIColor(hex:0xD1D5Db,alpha:1)
        timeLine.backgroundColor = UIColor(hex:0xD1D5Db,alpha:1)
        descLine.backgroundColor = UIColor(hex:0xD1D5Db,alpha:1)
        //保存
        saveBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        saveBtn.setTitle("添加支出",for:UIControlState());
        saveBtn.addTarget(self, action: #selector(AddPayViewController.done), for: UIControlEvents.touchUpInside)
        saveBtn.primaryStyle()
        //取消
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        cancelBtn.setTitle("取消",for:UIControlState());
        cancelBtn.addTarget(self, action: #selector(AddPayViewController.cancel), for: UIControlEvents.touchUpInside)
        cancelBtn.defaultMyStyle()
        //备注
        descText.delegate = self
        descText.tag = 2
        descText.backgroundColor = UIColor.white
        descText.attributedPlaceholder = NSAttributedString(string: "消费备注", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        descText.font = UIFont.systemFont(ofSize: 18)
        descText.textColor = UIColor.black
        descText.textAlignment = .center
        //时间
        timeBtn.backgroundColor =  UIColor.white
        timeBtn.setTitleColor(UIColor.black, for: UIControlState())
        timeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        timeBtn.setTitle(today(), for: UIControlState())
        timeBtn.addTarget(self, action: #selector(AddPayViewController.selTime), for: UIControlEvents.touchUpInside)
        //金额
        moneyText.attributedPlaceholder = NSAttributedString(
            string: "￥0.00",
            attributes: [NSForegroundColorAttributeName: UIColor(hex:0x1499d7,alpha:1)])
        moneyText.textColor = UIColor(hex:0x1499d7,alpha:1)
        moneyText.font = UIFont.boldSystemFont(ofSize: 40)
        moneyText.textAlignment = NSTextAlignment.right
        moneyText.delegate = self
        moneyText.tag = 1
        //金额键盘
        moneyText.inputView = zykeyboard
        zykeyboard.delegate = self
        zykeyboard.txtResult = moneyText
        moneyText.becomeFirstResponder()
        //选择分类层
        typeBtn.backgroundColor =  UIColor.white
        typeBtn.setTitleColor(UIColor.black, for: UIControlState())
        typeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        if(UserDefaults.standard.integer(forKey: "DeviceID")  == 1 ){
            typeBtn.setTitle("lzy-食品-LZY【现金】", for: UIControlState())
        }else{
            typeBtn.setTitle("jyy-食品-JYY【现金】", for: UIControlState())
        }
        typeBtn.addTarget(self, action: #selector(AddPayViewController.selCtg), for: UIControlEvents.touchUpInside)
        self.view.addSubview(moneyTitle)
        self.view.addSubview(moneyText)
        self.view.addSubview(moneyLine)
        self.view.addSubview(typeTitle)
        self.view.addSubview(typeBtn)
        self.view.addSubview(typeLine)
        self.view.addSubview(timeTitle)
        self.view.addSubview(timeBtn)
        self.view.addSubview(timeLine)
        self.view.addSubview(descTitle)
        self.view.addSubview(descText)
        self.view.addSubview(descLine)
        self.view.addSubview(saveBtn)
        self.view.addSubview(cancelBtn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "添加支出"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action:#selector(AddPayViewController.cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.plain, target: self, action:#selector(AddPayViewController.done))
        datePicker.locale =  Locale(identifier: "zh_CN")
        datePicker.timeZone = TimeZone.current
        //pickerview 定义
        userKV = DBRecord().userKV()
        userKV.removeValue(forKey: 0)
        expensesKV = DBRecord().expensesKV()
        expensesKV.removeValue(forKey: 0)
        bankKV = DBRecord().getBank()
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView.selectRow(UserDefaults.standard.integer(forKey: "DeviceID"), inComponent: 0, animated: false)
        pickerView.selectRow(1, inComponent: 1, animated: false)
        if(UserDefaults.standard.integer(forKey: "DeviceID") == 1)
        {
            pickerView.selectRow(0, inComponent: 2, animated: false)
        }else{
            pickerView.selectRow(10, inComponent: 2, animated: false)
        }
        initView() //初始化界面
    }
    
    // MARK: - payView
    func 收起所有输入面板(){
        moneyText.resignFirstResponder()
        descText.resignFirstResponder()
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
        timeBtn.setTitle(fmt.string(from: sender.date), for: UIControlState())
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField.tag == 1){ //打开金额键盘
            descText.resignFirstResponder()
        }
        if(textField.tag == 2){ //打开备注键盘
            moneyText.resignFirstResponder()
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
            return userKV.count
        }else if(component == 1) {
            return expensesKV.count
        }
        else if(component == 2) {
            return bankKV.count
        }
        return 0;
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if(component == 0){
            return 40;
        }else if(component == 1) {
            return 60;
        }
        else if(component == 2) {
            return 180;
        }
        return 0;
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let myView = UILabel()
        myView.font = UIFont.systemFont(ofSize: 18)
        myView.backgroundColor = UIColor.clear
        if(component == 0){
            myView.frame = CGRect(x: 10, y: 0, width: 40, height: 40)
            myView.text =  userKV[row+1]?.user
        }else if(component == 1) {
            myView.frame = CGRect(x: 10, y: 0.0, width: 60, height: 40)
            myView.text =  expensesKV[row+1]?.name
        }else if(component == 2) {
            myView.frame = CGRect(x: 0, y: 0.0, width: 190, height: 40)
            myView.text =  bankKV[row].name
        }
        return myView;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let user =  userKV[pickerView.selectedRow(inComponent: 0)+1]!.user
        let ctg = expensesKV[pickerView.selectedRow(inComponent: 1)+1]!.name
        let bank = bankKV[pickerView.selectedRow(inComponent: 2)].name
        typeBtn.setTitle("\(user)-\(ctg)-\(bank)", for: UIControlState())
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func done(){
        if(!checkForm()){return}
        //获取所有数据：
        let userid:Int  = userKV[pickerView.selectedRow(inComponent: 0)+1]!.id
        let ctgid:Int   = expensesKV[pickerView.selectedRow(inComponent: 1)+1]!.id
        let bankid:Int  = bankKV[pickerView.selectedRow(inComponent: 2)].id
        let date:String = self.timeBtn.title(for: UIControlState())!
        let desc:String = self.descText.text!
        let money:String =  self.moneyText.text!.replacingOccurrences(of: "￥", with: "")
        let uid:String = String(UserDefaults.standard.integer(forKey: "DeviceID"))
        //保存记录
        if(!db.execute(sql:"insert into `qian8_expense_list` (`cate_id`,`user_id`,`time`,`price`,`demo`,`bank_id`,`sn`) values ('\(ctgid)','\(userid)','\(date)','\(money)','\(desc)','\(bankid)','0')")){
            print("add error")
        }
        let lastid = db.lastid()
        //保存同步记录
        if(!DBRecord().execute(sql:"insert into `qian8_sync_list` (`master_id`,`action_id`,`table_id`,`user_id`,`rsync_status`,`rsync_rs`,`data`,`local_id`) values ('0','1','6','\(uid)','0','0','|\(ctgid)|\(userid)|\(date)|\(money)|\(desc)|\(bankid)|0','\(lastid)')")){
            print("add error")
        }
        //银行扣款
        if(!DBRecord().execute(sql:"update `qian8_bank` set `current_deposit` = `current_deposit`-'\(money)' where `id`='\(bankid)'")){
            print("add error")
        }
        //保存扣款记录
        let update = ["current_deposit":"`current_deposit`-\(money)"]
        if(!DBRecord().execute(sql:"insert into `qian8_sync_list` (`master_id`,`action_id`,`table_id`,`user_id`,`rsync_status`,`rsync_rs`,`data`,`local_id`) values ('\(bankid)','2','1','\(uid)','0','0','\(toJSONString2(update as NSDictionary))','\(bankid)')")){
            print("add error")
        }
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
    
    // MARK: - checkForm
    func checkForm() -> Bool{
        let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
        var alertController = UIAlertController(title: "",message: "", preferredStyle: .alert)
        if self.moneyText.text! == "" {
            alertController = UIAlertController(title: "",message: "金额不能为空", preferredStyle: .alert)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        let money:String =  self.moneyText.text!.replacingOccurrences(of: "￥", with: "")
        let desc:String = self.descText.text!
        if Float(money) == nil {
            alertController = UIAlertController(title: "",message: "金额不正确", preferredStyle: .alert)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        if  desc == "" {
            alertController = UIAlertController(title: "",message: "备注不能为空", preferredStyle: .alert)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "newadd", context: nil);
    }
}
