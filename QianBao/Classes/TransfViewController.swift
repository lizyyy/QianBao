//
//  TransfViewController.swift
//  qian8new
//
//  Created by zhiyuan on 2016/10/13.
//  Copyright © 2016年 leeey. All rights reserved.
//
import UIKit
class TransfViewController:UITableViewController,RsyncDelegate{
    var dataList = [bankListItem]()
    let navView = NavView()
    var taptime = CGFloat()
    var hud: MBProgressHUD!
    var selDate = NSDate()
    var selCtg  = 0
    var userKV    = Dictionary<Int,userItem>()
    var transfKV    = Dictionary<Int,bankItem>()
    let db = DBRecord()
    func inittitle()->TransfViewController{ return self }
    override func viewDidLoad() {
        super.viewDidLoad()
        userKV    = DBRecord().userKV()
        transfKV     = DBRecord().bankKV()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add,target: self,action:#selector(self.添加页))
        //生成一个navView
        if( userKV.count > 0 ) {//必须有数据再添加
            let view = navView.view(title:"\(toMonth(date:selDate)) → \(DBRecord.changeTypeAll()[selCtg]!)")
            navView.btnLeft.addTarget(self, action: #selector(self.previousM), for: .touchUpInside)
            navView.btnMid.addTarget(self, action: #selector(self.midAction), for: .touchUpInside)
            navView.btnRight.addTarget(self, action: #selector(self.nextM), for: .touchUpInside)
            self.navigationController?.navigationBar.addSubview(view)
            self.reload()
        }
        //下拉刷新
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.刷新和同步), for: UIControlEvents.valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "同步数据...")
        self.refreshControl = refreshControl
    }
    
    // MARK: - 一些方法
    func 刷新和同步(){
        if 更新锁 == false {
            更新锁 = true
            self.refreshControl?.beginRefreshing()
            let rsync  = Rsync()
            rsync.delegate = self
            rsync.同步()
        }
    }
    
    func previousM(sender: UIButton!) {
        selDate = selDate.minusMonths(m: 1)
        self.reload()
        navView.btnMid.setTitle(toMonth(date:selDate) + " → \(DBRecord.changeTypeAll()[selCtg]!)", for: UIControlState())
    }
    
    func nextM(sender: UIButton!){
        //@todo 超出的月份不让翻页
        selDate = selDate.plusMonths(m: 1)
        self.reload()
        navView.btnMid.setTitle(toMonth(date:selDate) + " → \(DBRecord.changeType()[selCtg]!)", for: UIControlState())
    }
    
    func midAction(sender: UIButton!){
        let selectview = SelectViewController()
        selectview.selCtg = self.selCtg
        selectview.selDate = self.selDate
        selectview.selpage = frompage.transf
        self.navigationController?.present( UINavigationController(rootViewController: selectview), animated: true, completion:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.newsel(_:)), name: NSNotification.Name(rawValue: "newsel"), object: nil)
    }
    
    func reload(){
        dataList = db.getBankList(toMonth(date:selDate),ctgid:selCtg)
        DispatchQueue.main.async {
            self.navView.lableSum.text = "共：" + String(self.dataList.count) + " 笔"
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
        更新锁 = false
    }
    
    //筛选条件更新
    func newsel(_ notification: Notification){
        selDate = notification.userInfo!["date"] as! NSDate
        selCtg =  notification.userInfo!["ctgid", default:0] as! Int //@ios11
        navView.btnMid.setTitle(toMonth(date:selDate) + " → \(DBRecord.changeTypeAll()[selCtg]!)", for: UIControlState())
        self.reload()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "newadd"){ //监听添加页面的newadd属性，当发生变化时，刷新页面
            self.reload()
        }
    }
    
    func 添加页(){
        let addview = AddTransfViewController()
        //监听添加页面的newadd属性，当发生变化时，刷新页面
        addview.addObserver(self, forKeyPath: "newadd", options: NSKeyValueObservingOptions.new, context: nil);
        self.navigationController?.present(UINavigationController(rootViewController: addview), animated: true, completion:nil)
    }
    
    // MARK: - RsyncDelegate
    var noticeview = UIView()
    func rsyncFinish(a:Int,b:Int,c:Int){
        renew  = true
        self.reload()
    }
    
    func removeNotice(){
        noticeview.removeFromSuperview()
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //双击打开添加页
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let curr = Date().timeIntervalSince1970
        if (CGFloat(curr) - CGFloat(taptime) < 0.9) {
            添加页()
            taptime = 0
        }else{ taptime = CGFloat(curr) }
        return false
    }
    
    //MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ListCellView(cellStyle:ListCellStyle.Transf, reuseIdentifier:ListCellView.identifier)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let item = dataList[indexPath.row]
        if (Int(item.day)!)%2 == 1 {cell.backgroundColor =  UIColor(hex:0xf9f9f9,alpha:0.9)}  //隔天显颜色
        //公用
        cell.money.text    = "￥" +  item.money
        cell.time.text     = item.week
        cell.note.text     = item.demo
        cell.bankFrom.text = item.bank_name
        cell.bankTo.text   = item.bankto_name 
        cell.type.text     = "→" + item.type_name + "→"
        var backColor = UIColor()
        switch item.type {
        case 1: backColor =  UIColor(hex:0xdd5e31,alpha:1) //定期
        case 2: backColor = UIColor(hex:0x1666af,alpha:1) //活期
        case 3: backColor = UIColor(hex:0x239925,alpha:1) //转
        default:backColor = UIColor.gray; break
        }
        cell.type.textColor = backColor
        return cell
    }
  
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let recordlist  = self.dataList[indexPath.row]
        let money  = recordlist.money
        let delid = recordlist.id
        let frombankid = recordlist.from_bank_id
        let tobankid = recordlist.to_bank_id
        let ctgid = recordlist.type 
        let sn = recordlist.sn == 0 ? "0" : String(recordlist.sn)
        let uid = String(UserDefaults.standard.integer(forKey: "DeviceID"))
        var sqlBank1 = String()
        //var msg = String()
        var updateData = Dictionary<String,String>()
        if (editingStyle == UITableViewCellEditingStyle.delete){
            if( frombankid == tobankid ){ //银行互转
                switch (ctgid) {
                case 1:
                    sqlBank1 = "update qian8_bank set `current_deposit`=`current_deposit`+\(money),`fixed_deposit`=`fixed_deposit`-\(money) where `id`=\(frombankid)"
                    updateData = ["current_deposit":"`current_deposit`+\(money)","fixed_deposit":"`fixed_deposit`-\(money)"]
                case 2:
                    sqlBank1 = "update qian8_bank set `current_deposit`=`current_deposit`-\(money),`fixed_deposit`=`fixed_deposit`+\(money) where `id`=\(frombankid)"
                    updateData = ["current_deposit":"`current_deposit`-\(money)","fixed_deposit":"`fixed_deposit`+\(money)"]
                default:
                    break
                }
                let sqlRsync1 = "insert into qian8_sync_list (master_id,action_id,table_id,user_id,rsync_status,rsync_rs,data,local_id) values  ('\(frombankid)','2','1','\(uid)','0','0','\(toJSONString2(updateData as NSDictionary))','\(frombankid)')"
                if(!db.execute(sql:sqlBank1) || !db.execute(sql:sqlRsync1)){print("del error")}
            }else{ //银行间转账
                let sqlBank2  = "update `qian8_bank` set `current_deposit` =`current_deposit`+\(money) where  `id`='\(frombankid)'"
                let updateData2 = ["current_deposit":"`current_deposit`+\(money)"]
                let sqlRsync2 = "insert into qian8_sync_list (master_id,action_id,table_id,user_id,rsync_status,rsync_rs,data,local_id) values  ('\(frombankid)','2','1','\(uid)','0','0','\(toJSONString2(updateData2 as NSDictionary))','\(frombankid)')"
                let sqlBank3 = "update `qian8_bank` set `current_deposit` =`current_deposit`-\(money) where `id`='\(tobankid)'"
                let updateData3 = ["current_deposit":"`current_deposit`-\(money)"]
                let sqlRsync3 = "insert into qian8_sync_list (master_id,action_id,table_id,user_id,rsync_status,rsync_rs,data,local_id) values  ('\(tobankid)','2','1','\(uid)','0','0','\(toJSONString2(updateData3 as NSDictionary))','\(tobankid)')"
                if(!db.execute(sql:sqlBank2) || !db.execute(sql:sqlRsync2) || !db.execute(sql:sqlBank3) || !db.execute(sql:sqlRsync3) ){print("add error")}
            }
            //记录转账记录
            let syncDel = "insert into qian8_sync_list (master_id,action_id,table_id,user_id,rsync_status,rsync_rs,data,local_id) values ('\(sn)','3','2','\(uid)','0','0','[]','\(delid)')"
            if (!db.execute(sql:syncDel) ) {print("insert qian8_sync_list error")}
            //保存同步
            let sqlDel = "delete from `qian8_bank_list` where id='\(delid)'"
            if (!db.execute(sql:sqlDel) ) {print("del qian8_bank_list error")}
            dataList.remove(at: indexPath.row) 
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            self.tableView.reloadData()
        }
    }
}
