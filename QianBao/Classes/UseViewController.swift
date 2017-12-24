//
//  UseViewController.swift
//  qian8new
//
//  Created by zhiyuan on 2017/11/26.
//  Copyright © 2016年 leeey. All rights reserved.
//
import UIKit
import PNChart
class UseViewController:UIViewController,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UITabBarControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,PNChartDelegate,RsyncDelegate{
    let db = DBRecord()
    var _scrollview     = UIScrollView()
    var taptime = CGFloat()
    var selDate = NSDate()
    var selUser = 0
    var selCtg  = 0
    //定义一个吸顶的工具栏
    let toolBarView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenW, height: 50)) //表头
    var topToolBarView = UIView(frame: CGRect(x: 0, y: LL_StatusBarAndNavigationBarHeight, width: ScreenW, height: 50)) //固定
    //横向滑动的统计图
    var collectionView: UICollectionView!
    let collectViewItem = CommCell(cellStyle: CommCellStyle.hotView, reuseIdentifier: "hotview")
    //列表
    let _tableView      = UITableView(frame: CGRect(x:0, y:0, width:ScreenW, height:ScreenH), style: UITableViewStyle.plain)
    var searchController: UISearchController?
    //数据
    var dataList = [expenseListItem]()
    var searchList = [expenseListItem]()
    var userKV    = Dictionary<Int,userItem>()
    var expensesKV    = Dictionary<Int,expenseItem>()
    let rs = DBRecord().getExpensesSum()
    //刷新效果
    var hud: MBProgressHUD!
    var initData = false
    var 是否自动刷新 : Bool = false
    func inittitle()->UseViewController{ return self }
    
// MARK: - 显示顺序
    override func viewWillAppear(_ animated: Bool) {
        是否自动刷新 = false
        self.tabBarController?.delegate = self
        self.searchController?.searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(initData){
            reload()
            initData = false
        }
        是否自动刷新 = true  //这样就可以第二次点击tab的时候才会触发刷新
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //数据
        userKV      = DBRecord().userKV()
        expensesKV  = DBRecord().expensesKV()
        initData = true
        //定义navigation
        navigationItem.title = "支出"
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.prefersLargeTitles = true //大标题
        navigationItem.hidesSearchBarWhenScrolling = true //滑动时隐藏searchBar
        searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add,target: self,action:#selector(PayViewController.添加页))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search,target: self,action:#selector(PayViewController.添加页))
        //下拉刷新
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PayViewController.刷新和同步), for: UIControlEvents.valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "同步数据...")
        self._tableView.refreshControl = refreshControl
        //定义一个吸顶的工具栏
        setToolbarView(toolBarView)
        setToolbarView(topToolBarView)
        _tableView.tableHeaderView = toolBarView //给table头
        toolBarView.backgroundColor = UIColor.white
        topToolBarView.backgroundColor = UIColor.white
        topToolBarView.frame = CGRect(x: 0, y: LL_StatusBarAndNavigationBarHeight, width: ScreenW, height: 50)
        topToolBarView.isHidden = true
        //collectview
        collectViewItem.collectionView.delegate = self
        collectViewItem.collectionView.dataSource = self
        //tableview
        _tableView.dataSource = self
        _tableView.delegate = self
        _scrollview.delegate = self
        self.view.addSubview(_tableView)
        self.view.addSubview(topToolBarView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        searchController?.isActive  = false
    }
    
// MARK: - 吸顶工具的view
    func setToolbarView(_ view:UIView){
        let timeBtn = UIButton().buttonTitle(title: "2017-09-11", image: "xiala", selectImage: "xiala", backGroundColor: UIColor.white, Frame: CGRect(x: 10, y: 10, width: 140, height: 20))
        timeBtn.layoutButtonWithEdgeInsetsStyle(style: .imageRight, imageTitleSpace: 3)
        timeBtn.setTitleColor(UIColor.black, for: .normal)
        timeBtn.titleLabel?.font = FONT(15)
        timeBtn.addTarget(self, action: #selector(self.add), for: .allTouchEvents)
        view.addSubview(timeBtn)
        
        let filterBtn = UIButton().buttonTitle(title: "筛选", image: "xiala", selectImage: "xiala", backGroundColor: UIColor.white, Frame: CGRect(x: 200, y: 10, width: 100, height: 20))
        filterBtn.layoutButtonWithEdgeInsetsStyle(style: .imageRight, imageTitleSpace: 3)
        filterBtn.setTitleColor(UIColor.black, for: .normal)
        filterBtn.titleLabel?.font = FONT(15)
        filterBtn.addTarget(self, action: #selector(self.add), for: .allTouchEvents)
        view.addSubview(filterBtn)
    }

    func add(){
        print("111111")
    }
    
// MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if(offsetY >= -LL_StatusBarAndNavigationBarHeight){
            topToolBarView.isHidden = false
        }else{
            topToolBarView.isHidden = true
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if(scrollView.isKind(of: UICollectionView.self)){ //如果滑动的是CollectionView
            if(velocity.x<0){
                print("上个月")
            }
            if(velocity.x>0){
                print("下个月")
            }
        }
    }
    
// MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 0 && 是否自动刷新{
            // self.tableView.setContentOffset(CGPoint(x:0, y:-146), animated: false)
            刷新和同步()
            是否自动刷新 = true
        }
    }
    
    
// MARK:- PNChartDelegate
    func userClickedOnBar(at barIndex: Int) {
        print(rs.0[barIndex])
        print(rs.1[barIndex])
    }
    
// MARK: - UISearchResultsUpdating  搜索内容变化
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            searchList = db.getExpensesSearchList(text: searchText)
        }
        _tableView.reloadData()
    }
    
// MARK: - RsyncDelegate
    func rsyncFinish(a:Int,b:Int,c:Int){
        renew  = true
        self.reload()
    }
    
// MARK: - 一些方法
    func 刷新和同步(){
        if 更新锁 == false {
            更新锁 = true
            self._tableView.refreshControl?.beginRefreshing()
            let rsync  = Rsync()
            rsync.delegate = self
            rsync.同步()
        }
    }
    
    func reload(){
        dataList = db.getExpensesList(toMonth(date:selDate),userid: selUser,ctgid: selCtg)
        DispatchQueue.main.async {
            self._tableView.refreshControl?.endRefreshing()
            self._tableView.reloadData()
        }
        更新锁 = false
    }

    //监听添加页面的newadd属性，当发生变化时，刷新页面
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "newadd"){
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
    
    //双击打开添加页
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let curr = Date().timeIntervalSince1970
        if (CGFloat(curr) - CGFloat(taptime) < 0.9) {
            添加页()
            taptime = 0
        }else{ taptime = CGFloat(curr) }
        return false
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController!.isActive && searchController?.searchBar.text != "" {
            return searchList.count
        }else{
            if section == 0 {
                return 1
            }else{
                return dataList.count
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return  150
        }else{
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {  //曲线
            var cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell = self.collectViewItem
            
            return cell
        }else{
            let cell = ListCellView(cellStyle:ListCellStyle.Expense, reuseIdentifier:ListCellView.identifier)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            var item  = expenseListItem()
            if searchController!.isActive && searchController?.searchBar.text != "" {
                item = searchList[indexPath.row]
                cell.time.text     = item.time
            }else{
                item = dataList[indexPath.row]
                cell.time.text     = item.week
            }
            if (Int(item.day)!)%2 == 1 {cell.backgroundColor =  UIColor(hex:0xf9f9f9,alpha:0.9)}  //隔天显颜色
            //公用
            cell.money.text    = "￥" + item.price
            cell.note.text     = item.demo
            cell.bankFrom.text = item.bank_name
            cell.user.text     = item.user_name
            cell.type.text     = item.cate_name
            cell.icon.contents = UIImage(named:"p\(item.cate_id)")?.cgImage
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
    }
    
// MARK:-  UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "navCollectCellId", for: indexPath as IndexPath) as? CollectCell
        if (cell == nil) {
            cell = CollectCell()
        }
        cell?.barChart.yValues = rs.1
        cell?.barChart.stroke()
        cell?.barChart.delegate = self
        return cell!
    }
   
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var recordlist = expenseListItem()
        if searchController!.isActive && searchController?.searchBar.text != "" {
            recordlist = self.searchList[indexPath.row]
        }else{
            recordlist = self.dataList[indexPath.row]
        }
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
                            self._tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                            self._tableView.reloadData()
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
            if(self.db.execute(sql:"insert into `qian8_expense_list` (`cate_id`,`user_id`,`time`,`price`,`demo`,`bank_id`,`sn`) values ('\(ctgid)','\(userid)','\(date)','\(money)','\(desc)','\(bankid)','0')")){
                lastid = self.db.lastid()
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
        if (indexPath.section == 1 ){
            if searchController!.isActive && searchController?.searchBar.text != "" {
                return [moreAction]
            }else{
                return [deleteAction, moreAction]
            }
        }else{ return []}
    }
}
