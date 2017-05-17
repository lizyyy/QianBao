//
//  PayViewController.swift
//  qian8new
//
//  Created by zhiyuan on 2016/10/13.
//  Copyright © 2016年 leeey. All rights reserved.
//

import UIKit

class PayViewController:UITableViewController {
    var dataList = [expenseListItem]()
    let navView = NavView()
    var selDate = NSDate()
    var taptime = CGFloat()
        var hud: MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add,target: self,action:#selector(PayViewController.添加页))
        //生成一个navView
        let view = navView.view(title:"\(toMonth(date:selDate)) -> all -> 全部")
        navView.btnLeft.addTarget(self, action: #selector(self.previousM), for: .touchUpInside)
        navView.btnMid.addTarget(self, action: #selector(self.midAction), for: .touchUpInside)
        navView.btnRight.addTarget(self, action: #selector(self.nextM), for: .touchUpInside)
        self.navigationController?.navigationBar.addSubview(view)
    
        self.reload()
    }

    // MARK: - 一些方法
    func previousM(sender: UIButton!) {
        selDate = selDate.minusMonths(m: 1)
        dataList = DBRecord().getExpensesList(toMonth(date:selDate))
        self.tableView.reloadData()
        navView.btnMid.setTitle(toMonth(date:selDate) + " -> all -> 全部", for: UIControlState())
    }
    
    func nextM(sender: UIButton!){
        //@todo 超出的月份不让翻页
        selDate = selDate.plusMonths(m: 1)
        dataList = DBRecord().getExpensesList(toMonth(date:selDate))
        self.tableView.reloadData()
        navView.btnMid.setTitle(toMonth(date:selDate) + " -> all -> 全部", for: UIControlState())
    }
    
    func midAction(sender: UIButton!){
    }
    
    func reload(){
        dataList = DBRecord().getExpensesList(toMonth(date:selDate))
        self.tableView.reloadData()
    }
 
    //
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "newadd"){ //监听添加页面的newadd属性，当发生变化时，刷新页面
            self.reload()
        }
    }
    
    func 添加页(){
        let addpayview = AddPayViewController()
        //监听添加页面的newadd属性，当发生变化时，刷新页面
        addpayview.addObserver(self, forKeyPath: "newadd", options: NSKeyValueObservingOptions.new, context: nil);
        let addPay = UINavigationController(rootViewController: addpayview)
        self.navigationController?.present(addPay, animated: true, completion:nil)
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
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ListCellView(cellStyle:ListCellStyle.Expense, reuseIdentifier:ListCellView.identifier)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let item = dataList[indexPath.row]
        //公用
        cell.money.text    = item.price
        cell.time.text     = item.week
        cell.note.text     = item.demo
        cell.bankFrom.text = item.bank_name
        cell.user.text     = item.user_name
        cell.type.text     = item.cate_name
        cell.icon.contents = UIImage(named:"p\(item.cate_id)")?.cgImage
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let recordlist  = self.dataList[indexPath.row]
        let selid       = recordlist.id
        let agentid     = String(UserDefaults.standard.integer(forKey: "DeviceID"))
        let money       = recordlist.price
        let bankid      = recordlist.bank_id
        //删除一条记录
        let deleteClosure = { (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            //获取此条的基本信息
            let delsn   = recordlist.sn
            //先修改银行余额
            let sqlbank = "update qian8_bank set `current_deposit` = `current_deposit`+\(money) where id='\(bankid)'"
            if (DBRecord().execute(sql: sqlbank) ){
                //同步日志
                let upData = toJSONString2( ["current_deposit":"`current_deposit`+\(money)"] )
                let sqlbankSync = "insert into qian8_sync_list (master_id,action_id,table_id,user_id,rsync_status,rsync_rs,data,local_id) values ('\(bankid)','2','1','\(agentid)','0','0','\(upData)','\(bankid)')"
                if ( DBRecord().execute(sql:sqlbankSync) ) {
                    //同步删除日志
                    let sn = delsn == 0 ? "0" : String(delsn)
                    let sqldelSync = "insert into qian8_sync_list (master_id,action_id,table_id,user_id,rsync_status,rsync_rs,data,local_id) values ('\(sn)','3','6','\(agentid)','0','0','[]','\(selid)')"
                    if ( DBRecord().execute(sql:sqldelSync) ) {
                        //最后再删除记录
                        let sqlDel = "delete from `qian8_expense_list` where id='\(selid)'"
                        if (  DBRecord().execute(sql:sqlDel)  ) {
                            self.dataList.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                            self.tableView.reloadData()
                        } else {print(sqlDel)}
                    } else {print(sqldelSync)}
                } else {print(sqlbankSync)}
            } else {print(sqlbank)}
        }
        //复制到今天
        let moreClosure = { (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in 
            let ctgid = recordlist.cate_id
            let userid = recordlist.user_id
            let date = today()
            let desc = recordlist.demo
            var lastid = 0
            //保存记录
            if(DBRecord().execute(sql:"insert into `qian8_expense_list` (`cate_id`,`user_id`,`time`,`price`,`demo`,`bank_id`,`sn`) values ('\(ctgid)','\(userid)','\(date)','\(money)','\(desc)','\(bankid)','0')")){
                lastid = DBRecord().lastid()
            }
            //保存同步记录
            if (!DBRecord().execute(sql:"insert into `qian8_sync_list` (`master_id`,`action_id`,`table_id`,`user_id`,`rsync_status`,`rsync_rs`,`data`,`local_id`) values ('0','1','6','\(agentid)','0','0','|\(ctgid)|\(userid)|\(date)|\(money)|\(desc)|\(bankid)|0','\(lastid)')")){
                print("copy error")
            }
            //银行扣款
            if (!DBRecord().execute(sql:"update `qian8_bank` set `current_deposit` = `current_deposit`-'\(money)' where `id`='\(bankid)'")){
                print("copy error")
            }
            //保存扣款记录
            let update = ["current_deposit":"`current_deposit`-\(money)"]
            if (!DBRecord().execute(sql:"insert into `qian8_sync_list` (`master_id`,`action_id`,`table_id`,`user_id`,`rsync_status`,`rsync_rs`,`data`,`local_id`) values ('\(bankid)','2','1','\(agentid)','0','0','\(toJSONString2(update as NSDictionary))','\(bankid)')")){
                print("copy error")
            }else{
                self.hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
                self.hud.customView = UIImageView(image: UIImage(named:"Checkmark"))
                self.hud.mode = MBProgressHUDMode.customView
                self.hud.label.text = "复制完成";
                self.hud.hide(animated: true, afterDelay: 1)
                self.reload()
            }
        }
        let deleteAction = UITableViewRowAction(style: .default, title: "删除", handler: deleteClosure)
        let moreAction = UITableViewRowAction(style:UITableViewRowActionStyle.normal, title: "复制到今天", handler: moreClosure)
        return [deleteAction, moreAction]
    }
    
    
    deinit {
        self.removeObserver(self, forKeyPath: "newadd", context: nil);
    }
    
    
}
