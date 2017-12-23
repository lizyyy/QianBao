//
//  UseViewController.swift
//  qian8new
//
//  Created by zhiyuan on 2017/11/26.
//  Copyright © 2016年 leeey. All rights reserved.
//
import UIKit
import PNChart
class UseViewController:UIViewController,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,RsyncDelegate,UITabBarControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    var dataList = [expenseListItem]()
    var searchList = [expenseListItem]()
    let navView = NavView()
    var taptime = CGFloat()
    var hud: MBProgressHUD!
    var selDate = NSDate()
    var selUser = 0
    var selCtg  = 0
    var userKV    = Dictionary<Int,userItem>()
    var expensesKV    = Dictionary<Int,expenseItem>()
    let db = DBRecord()
    var initData = false
    var 是否自动刷新 : Bool = false
    var searchController: UISearchController?
    func inittitle()->UseViewController{ return self }
    var collectionView: UICollectionView!
    var _scrollview     = UIScrollView()
    let _tableView      = UITableView(frame: CGRect(x:0, y:0, width:ScreenW, height:ScreenH), style: UITableViewStyle.grouped)
    //定义一个吸顶的工具栏
    let toolBarView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenW, height: 50))
    var topToolBarView = UIView(frame: CGRect(x: 0, y: LL_StatusBarAndNavigationBarHeight, width: ScreenW, height: 50))
    // MARK: - 显示顺序
    override func viewWillAppear(_ animated: Bool) {
        是否自动刷新 = false
        self.tabBarController?.delegate = self
        self.searchController?.searchBar.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _tableView.dataSource = self
        _tableView.delegate = self
        self.view.addSubview(_tableView)
        
        self.navigationItem.title = "支出"
        self._scrollview.delegate = self
        navigationController?.navigationBar.barTintColor = UIColor.white
        searchController = UISearchController(searchResultsController: nil)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true //大标题
            navigationItem.hidesSearchBarWhenScrolling = true //滑动时隐藏searchBar
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        userKV      = DBRecord().userKV()
        expensesKV  = DBRecord().expensesKV()
        initData = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add,target: self,action:#selector(PayViewController.添加页))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search,target: self,action:#selector(PayViewController.添加页))
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
        self.view.addSubview(topToolBarView)
    }
    
    func setToolbarView(_ view:UIView){
        let timeBtn = UIButton(frame: CGRect(x: 10, y: 10, width: 100, height: 20))
        timeBtn.setTitle("2017-08", for:.normal)
        timeBtn.setTitleColor(UIColor.black, for: .normal)
        timeBtn.addTarget(self, action: #selector(self.add), for: .allTouchEvents)
        timeBtn.defaultMyStyle()
        view.addSubview(timeBtn)

    }
    
    func add(){
        print("111111")
    }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if(offsetY >= -88){
            topToolBarView.isHidden = false
        }else{
            topToolBarView.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(initData){
            reload()
            initData = false
        }
        //self.tableView.contentOffset = CGPoint(x:0, y:-8) //搞不懂为啥，加上这句，搜索框才默认不显示..
        是否自动刷新 = true  //这样就可以第二次点击tab的时候才会触发刷新
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        searchController?.isActive  = false
    }
    
    // MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 0 && 是否自动刷新{
            // self.tableView.setContentOffset(CGPoint(x:0, y:-146), animated: false)
            刷新和同步()
            是否自动刷新 = true
        }
    }
    // MARK: - UISearchResultsUpdating  搜索内容变化
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            searchList = db.getExpensesSearchList(text: searchText)
        }
        _tableView.reloadData()
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
    
    func previousM(sender: UIButton!) {
        selDate = selDate.minusMonths(m: 1)
        self.reload()
        navView.btnMid.setTitle(toMonth(date:selDate) + " → \(userKV[selUser]!.user) → \(expensesKV[selCtg]!.name)", for: UIControlState())
    }
    
    func nextM(sender: UIButton!){
        //@todo 超出的月份不让翻页
        selDate = selDate.plusMonths(m: 1)
        self.reload()
        navView.btnMid.setTitle(toMonth(date:selDate) + " → \(userKV[selUser]!.user) → \(expensesKV[selCtg]!.name)", for: UIControlState())
    }
    
    func midAction(sender: UIButton!){
        let selectview = SelectViewController()
        selectview.selCtg = self.selCtg
        selectview.selUser = self.selUser
        selectview.selDate = self.selDate
        selectview.selpage = frompage.pay
        self.navigationController?.present( UINavigationController(rootViewController: selectview), animated: true, completion:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(PayViewController.newsel(_:)), name: NSNotification.Name(rawValue: "newsel"), object: nil)
    }
    
    func reload(){
        dataList = db.getExpensesList(toMonth(date:selDate),userid: selUser,ctgid: selCtg)
        DispatchQueue.main.async {
            self.navView.lableSum.text = "总计：" + self.db.expenseSum.format(".2") + " 元"
            self._tableView.refreshControl?.endRefreshing()
            self._tableView.reloadData()
        }
        更新锁 = false
    }
    
    //筛选条件更新
    func newsel(_ notification: Notification){
        selUser = notification.userInfo!["userid"]! as! Int
        selCtg =  notification.userInfo!["ctgid"]! as! Int
        selDate = notification.userInfo!["date"] as! NSDate
        navView.btnMid.setTitle(toMonth(date:selDate) + " → \(userKV[selUser]!.user) → \(expensesKV[selCtg]!.name)", for: UIControlState())
        self.reload()
    }
    
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
                return 2
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
            return  indexPath.row == 0 ?  200 : 60
        }else{
            return 70
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1{
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
        }else{  //曲线
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            if(indexPath.row == 0 ){
                let xLabelsSource = ["1", "2", "3", "4", "5", "6","7", "8", "9", "10", "11", "12"]
                let lineChart = PNLineChart(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
                lineChart.setXLabels(xLabelsSource, withWidth: 400 / CGFloat(xLabelsSource.count) - 6)
                let data1Source = [4, 2.5, 5.5, 4.7, 2.5, 7.3,5.5, 4.7, 2.5, 7.3,5.5, 4.7]
                let data1 = PNLineChartData()
                data1.color = UIColor.red
                data1.itemCount = UInt(xLabelsSource.count)
                data1.getData = ({ index -> PNLineChartDataItem in
                    let yValue = CGFloat(data1Source[Int(index)])
                    return  PNLineChartDataItem(y: yValue)
                })
                lineChart.chartData = [data1]
                lineChart.showYGridLines = false
                lineChart.isShowCoordinateAxis = false
                lineChart.stroke()
                cell.addSubview(lineChart)
                
                let barChart = PNBarChart(frame: CGRect(x: 0, y: 100, width: 400, height: 100))
                barChart.showLabel = true
                barChart.yMaxValue = 30
                barChart.xLabels = ["衣", "食", "住", "行", "用", "娱"]
                barChart.yLabels = [4, 2.5,20, 8, 2.5, 7.3]
                barChart.stroke()
                cell.addSubview(barChart)
            }else{
                let collectionFlowLayout = GLIndexedCollectionViewFlowLayout()
                collectionFlowLayout.scrollDirection = .horizontal //水平滑动
                collectionView = GLIndexedCollectionView(frame: CGRect(x:0, y:0, width:self.view.frame.size.width,height:60), collectionViewLayout: collectionFlowLayout)
                collectionView.backgroundColor = UIColor.white
                collectionView.showsHorizontalScrollIndicator = false  //不显示水平滚动条
                collectionView.bounces = true //弹簧效果
                // 是否只允许同时滑动一个方向,默认为NO,如果设置为YES,用户在水平/竖直方向开始进行滑动,便禁止同时在竖直/水平方向滑动(注: 当用户在对角线方向开始进行滑动,则本次滑动可以同时在任何方向滑动)
                collectionView.isDirectionalLockEnabled = true
                collectionView.isMultipleTouchEnabled = false
                collectionView.delegate = self
                collectionView.dataSource = self
                //注册一个cell
                collectionView.register(DateCell.self, forCellWithReuseIdentifier:"DateCell")
                collectionView.isPagingEnabled = true
                cell.addSubview(collectionView)
            }
            return cell
        }
        
    }
    
    
    let collectionTopInset: CGFloat = 0
    let collectionBottomInset: CGFloat = 0
    let collectionLeftInset: CGFloat = 10
    let collectionRightInset: CGFloat = 10
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: collectionTopInset, left: collectionLeftInset, bottom: collectionBottomInset, right: collectionRightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        return CGSize(width: 40, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // MARK: <UICollectionView Delegate>
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        cell.backgroundColor = UIColor.red
        if indexPath.section == 0 {
            cell.titleLabel?.text = "1"
        }else{
            cell.titleLabel?.text = "22"
        }
        return cell
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


class GLIndexedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    fileprivate var paginatedScroll: Bool?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard proposedContentOffset.x > 0 else {
            return CGPoint(x: 0, y: 0)
        }
        guard paginatedScroll == true else {
            return CGPoint(x: proposedContentOffset.x, y: 0)
        }
        guard let collectionView: UICollectionView = collectionView else {
            return CGPoint(x: proposedContentOffset.x, y: 0)
        }
        let scannerFrame: CGRect = CGRect(x: proposedContentOffset.x,
                                          y: 0,
                                          width: collectionView.bounds.width,
                                          height: collectionView.bounds.height)
        guard let layoutAttributes: [UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: scannerFrame) else {
            return CGPoint(x: proposedContentOffset.x, y: 0)
        }
        let collectionViewInsets: CGFloat = 10.0
        let proposedXCoordWithInsets: CGFloat = proposedContentOffset.x + collectionViewInsets
        var offsetCorrection: CGFloat = .greatestFiniteMagnitude
        layoutAttributes.filter { layoutAttribute -> Bool in
            layoutAttribute.representedElementCategory == .cell
            }.forEach { cellLayoutAttribute in
                let discardableScrollingElementsFrame: CGFloat = collectionView.contentOffset.x + (collectionView.frame.size.width / 2)
                if (cellLayoutAttribute.center.x <= discardableScrollingElementsFrame && velocity.x > 0) || (cellLayoutAttribute.center.x >= discardableScrollingElementsFrame && velocity.x < 0) {
                    return
                }
                if abs(cellLayoutAttribute.frame.origin.x - proposedXCoordWithInsets) < abs(offsetCorrection) {
                    offsetCorrection = cellLayoutAttribute.frame.origin.x - proposedXCoordWithInsets
                }
        }
        return CGPoint(x: proposedContentOffset.x + offsetCorrection, y: 0)
    }
}

class GLIndexedCollectionView: UICollectionView {
    /// The inner-`indexPath` of the GLIndexedCollectionView.
    ///
    /// Use it to discriminate between all the possible GLIndexedCollectionViews
    /// inside `UICollectionView`'s `dataSource` and `delegate` methods.
    ///
    /// This should be set and updated only through GLCollectionTableViewCell's
    /// `setCollectionViewDataSourceDelegate` func to avoid strange behaviors.
    var indexPath: IndexPath!
}

