//
//  IncomeViewController.swift
//  qian8new
//
//  Created by zhiyuan on 2016/10/13.
//  Copyright © 2016年 leeey. All rights reserved.
//
import UIKit
class IncomeViewController:UITableViewController,RsyncDelegate,UITabBarControllerDelegate,UISearchResultsUpdating{
    var dataList = [incomeListItem]()
    var searchList = [incomeListItem]()
    let navView = NavView()
    var taptime = CGFloat()
    var hud: MBProgressHUD!
    var selDate = NSDate()
    var selUser = 0
    var selCtg  = 0
    var userKV    = Dictionary<Int,userItem>()
    var incomeKV    = Dictionary<Int,incomeItem>()
    let db = DBRecord()
    var initData = false
    var 是否自动刷新 : Bool = false
    var searchController: UISearchController?
    
    func inittitle()->IncomeViewController{ return self}
    // MARK: - 显示顺序
    override func viewWillAppear(_ animated: Bool) {
        是否自动刷新 = false
        self.tabBarController?.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        userKV    = DBRecord().userKV()
        incomeKV     = DBRecord().incomeKV()
        initData = true
        self.view.backgroundColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add,target: self,action:#selector(IncomeViewController.添加页))
        //生成一个navView
        if( userKV.count > 0 ) {//必须有数据再添加
            let view = navView.view(title:"\(toMonth(date:selDate)) → \(userKV[selUser]!.user) → \(incomeKV[selCtg]!.name)")
            navView.btnLeft.addTarget(self, action: #selector(self.previousM), for: .touchUpInside)
            navView.btnMid.addTarget(self, action: #selector(self.midAction), for: .touchUpInside)
            navView.btnRight.addTarget(self, action: #selector(self.nextM), for: .touchUpInside)
            self.navigationController?.navigationBar.addSubview(view)
            self.reload()
        }
        //搜索框
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchBar.sizeToFit()
        //下拉刷新
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(IncomeViewController.刷新和同步), for: UIControlEvents.valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "同步数据...")
        self.refreshControl = refreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(initData){
            reload()
            initData = false
            //搜索框
            self.tableView.tableHeaderView = searchController?.searchBar
        }
        self.tableView.contentOffset = CGPoint(x:0, y:-8) //搞不懂为啥，加上这句，搜索框才默认不显示..
        是否自动刷新 = true  //这样就可以第二次点击tab的时候才会触发刷新
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        searchController?.isActive  = false
    }
    
    
    // MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 1 && 是否自动刷新{
            self.tableView.setContentOffset(CGPoint(x:0, y:-146), animated: false)
            刷新和同步()
            是否自动刷新 = true
        }
    }

    // MARK: - UISearchResultsUpdating  搜索内容变化
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            searchList = db.getIncomeSearchList(text: searchText)
        }
        tableView.reloadData()
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
        navView.btnMid.setTitle(toMonth(date:selDate) + " → \(userKV[selUser]!.user) → \(incomeKV[selCtg]!.name)", for: UIControlState())
    }
    
    func nextM(sender: UIButton!){
        //@todo 超出的月份不让翻页
        selDate = selDate.plusMonths(m: 1)
        self.reload()
        navView.btnMid.setTitle(toMonth(date:selDate) + " → \(userKV[selUser]!.user) → \(incomeKV[selCtg]!.name)", for: UIControlState())
    }
    
    func midAction(sender: UIButton!){
        let selectview = SelectViewController()
        selectview.selCtg = self.selCtg
        selectview.selUser = self.selUser
        selectview.selDate = self.selDate
        selectview.selpage = frompage.income
        self.navigationController?.present( UINavigationController(rootViewController: selectview), animated: true, completion:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IncomeViewController.newsel(_:)), name: NSNotification.Name(rawValue: "newsel"), object: nil)
    }
    
    func reload(){
        dataList = db.getIncomeList(toMonth(date:selDate),userid: selUser,ctgid: selCtg)
        DispatchQueue.main.async {
            self.navView.lableSum.text = "总计：" + self.db.incomeSum.format(".2") + " 元"
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
        更新锁 = false
    }
    
    //筛选条件更新
    func newsel(_ notification: Notification){
        selUser = notification.userInfo!["userid"]! as! Int
        selCtg =  notification.userInfo!["ctgid"]! as! Int
        selDate = notification.userInfo!["date"] as! NSDate
        //print(toMonth(date:selDate) + " -> \(userKV[selUser]!.user) -> \(incomeKV[selCtg]!.name)")
        navView.btnMid.setTitle(toMonth(date:selDate) + " → \(userKV[selUser]!.user) → \(incomeKV[selCtg]!.name)", for: UIControlState())
        self.reload()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "newadd"){ //监听添加页面的newadd属性，当发生变化时，刷新页面
            self.reload()
        }
    }
    
    func 添加页(){
        let addincomeview = AddIncomeViewController()
        //监听添加页面的newadd属性，当发生变化时，刷新页面
        addincomeview.addObserver(self, forKeyPath: "newadd", options: NSKeyValueObservingOptions.new, context: nil);
        let addIncome = UINavigationController(rootViewController: addincomeview)
        self.navigationController?.present(addIncome, animated: true, completion:nil)
    }
    
    // MARK: - RsyncDelegate
    var noticeview = UIView()
    func rsyncFinish(a:Int,b:Int,c:Int){
        renew  = true
        self.reload()
        //        if(a > 0 || b > 0 || c > 0){
        //            noticeview = NavView().shownotice(msg: "新增：\(a)     修改：\(b)     删除：\(c)")
        //            self.navigationController?.view.addSubview(noticeview)
        //            UIView.beginAnimations(nil, context: nil)
        //            UIView.setAnimationDidStop(Selector(("removeNotie")))
        //            UIView.setAnimationDelay(1.5)
        //            UIView.setAnimationDuration(1.0)
        //            noticeview.alpha = 0
        //            UIView.commitAnimations()
        //        }
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
        if searchController!.isActive && searchController?.searchBar.text != "" {
            return searchList.count
        }else{
            return dataList.count
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ListCellView(cellStyle:ListCellStyle.Income, reuseIdentifier:ListCellView.identifier)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        var item  = incomeListItem()
        if searchController!.isActive && searchController?.searchBar.text != "" {
            item = searchList[indexPath.row]
            cell.time.text     = item.time
        }else{
            item = dataList[indexPath.row]
            cell.time.text     = item.week
        }
        if (Int(item.day)!)%2 == 1 {cell.backgroundColor =  UIColor(hex:0xf9f9f9,alpha:0.9)}  //隔天显颜色
        //公用
        cell.money.text    = "￥" + item.money
        cell.note.text     = item.demo
        cell.bankFrom.text = item.bank_name
        cell.user.text     = item.user_name
        cell.type.text     = item.cate_name
        cell.icon.contents = UIImage(named:"i\(item.cate_id)")?.cgImage
        var backColor = UIColor()
        switch item.user_id {
            case 2: backColor =  UIColor(hex:0x64aef7,alpha:1) //lzy
            case 3: backColor = UIColor(hex:0xe74941,alpha:1) //jyy
            case 4: backColor = UIColor(hex:0xfdbf3e,alpha:1) //l&j
            default:backColor = UIColor.gray; break;//all
        }
        cell.user.textColor = backColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var recordlist = incomeListItem()
        if searchController!.isActive && searchController?.searchBar.text != "" {
            recordlist = self.searchList[indexPath.row]
        }else{
            recordlist = self.dataList[indexPath.row]
        }
        let selid       = recordlist.id
        let agentid     = String(UserDefaults.standard.integer(forKey: "DeviceID"))
        let money       = recordlist.money
        let bankid      = recordlist.bank_id
        //删除一条记录
        let deleteClosure = { (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            //获取此条的基本信息
            let delsn   = recordlist.sn
            //先修改银行余额
            let sqlbank = "update qian8_bank set `current_deposit` = `current_deposit`-\(money) where id='\(bankid)'"
            if (DBRecord().execute(sql: sqlbank) ){
                //同步日志
                let upData = toJSONString2( ["current_deposit":"`current_deposit`-\(money)"] )
                let sqlbankSync = "insert into qian8_sync_list (master_id,action_id,table_id,user_id,rsync_status,rsync_rs,data,local_id) values ('\(bankid)','2','1','\(agentid)','0','0','\(upData)','\(bankid)')"
                if ( DBRecord().execute(sql:sqlbankSync) ) {
                    //同步删除日志
                    let sn = delsn == 0 ? "0" : String(delsn)
                    let sqldelSync = "insert into qian8_sync_list (master_id,action_id,table_id,user_id,rsync_status,rsync_rs,data,local_id) values ('\(sn)','3','4','\(agentid)','0','0','[]','\(selid)')"
                    if ( DBRecord().execute(sql:sqldelSync) ) {
                        //最后再删除记录
                        let sqlDel = "delete from `qian8_income_list` where id='\(selid)'"
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
            if(self.db.execute(sql:"insert into `qian8_income_list` (`cate_id`,`user_id`,`time`,`money`,`demo`,`bank_id`,`sn`) values ('\(ctgid)','\(userid)','\(date)','\(money)','\(desc)','\(bankid)','0')")){
                lastid = self.db.lastid()
            }
            //保存同步记录
            if (!DBRecord().execute(sql:"insert into `qian8_sync_list` (`master_id`,`action_id`,`table_id`,`user_id`,`rsync_status`,`rsync_rs`,`data`,`local_id`) values ('0','1','4','\(agentid)','0','0','|\(date)|\(userid)|\(money)|\(desc)|\(ctgid)|\(bankid)|0','\(lastid)')")){
                print("copy error")
            }
            //银行扣款
            if (!DBRecord().execute(sql:"update `qian8_bank` set `current_deposit` = `current_deposit`+'\(money)' where `id`='\(bankid)'")){
                print("copy error")
            }
            //保存扣款记录
            let update = ["current_deposit":"`current_deposit`+\(money)"]
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
        if searchController!.isActive && searchController?.searchBar.text != "" {
            return [moreAction]
        }else{
            return [deleteAction, moreAction]
        }
    }
}

