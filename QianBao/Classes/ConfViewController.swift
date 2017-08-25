//
//  ConfViewController.swift
//  qian8new
//
//  Created by zhiyuan on 2016/10/18.
//  Copyright © 2016年 leeey. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD

class ConfViewController : UITableViewController{
    var progress:Float = 0
    fileprivate let itemDataSouce: [ [(name:String,iconImage:UIImage?)]] = [
        [("导入",nil),("-导出",nil)],
        [("设备ID",nil),("接口地址",nil)]]
        //[("-建议",nil),("-关于",nil)]]
    
    
    let tableName = ["qian8_bank","qian8_bank_list","qian8_income_category",
                     "qian8_income_list","qian8_expense_category","qian8_expense_list","qian8_user"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.rowHeight = 44
        self.tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.grouped)
    }
    
    func inittitle()->ConfViewController{
        self.title = "Config"
        return self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 15
        } else {
            return 20
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    var hud: MBProgressHUD!
    var timer:Timer!
    var rsycnCountString = ""
    var progressId = ""
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                //连接前
                self.hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
                self.hud.label.text = "连接服务"
                let queue = DispatchQueue(label: "background", qos: .default, attributes: .concurrent)
                Alamofire.request(apiUrl + "get.php?id=0&user=4").responseJSON(queue: queue) { response in
                    let value = response.result.value
                    let json = JSON(value!)
                    self.rsycnCountString = json["ct"].stringValue
                    DispatchQueue.main.async { //主线程更新
                        self.hud.mode = MBProgressHUDMode.determinateHorizontalBar
                        self.hud.label.text = "导入数据"
                        self.hud.detailsLabel.text = "0/\(self.rsycnCountString)"
                        self.hud.progress = 0
                        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target:self,selector:#selector(self.showprogress), userInfo:nil,repeats:true)
                    }
                    //继续异步处理
                    json["data"].forEach{item in
                        self.progress = Float( ( Int(item.0)! + 1) * 100/json["ct"].int! )/100
                        self.progressId = String(item.0)
                        self.importDB(item: item.1) //写入数据库
                    }
                }
            default:break
            }
        case 1:
            switch indexPath.row {
            case 0:
                let terminal = TerminalTableViewController()
                self.navigationController?.pushViewController(terminal,animated:true)
                break
                
            case 1:
                print("1")
                let alertController = UIAlertController(title: "输入接口地址：", message: "", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "确认", style: .default, handler: {(action) in
                    UserDefaults.standard.setValue(alertController.textFields?[0].text, forKey: "apiUrl")
                }))
                alertController.addTextField(configurationHandler: {(text:UITextField) in text.text = UserDefaults.standard.string(forKey: "apiUrl")})
                //DispatchQueue.main.async { //奇怪，这里竟然要在主线程弹出。官方文档并没有说呀
                self.present(alertController, animated: false, completion: nil)
                //}
                CFRunLoopWakeUp(CFRunLoopGetCurrent()); //这个也能解决双击才能弹出的问题
            default:break
            }
        default:break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func importDB(item:JSON){
        let tableid = item["table_id"].intValue
        let table = self.tableName[tableid-1]
        let actionid = item["action_id"].intValue
        var sql = ""
        switch actionid{
        case 1://新增
            var dataArray = item["data"].string?.components(separatedBy: "|")
            let sn = item["master_id"].intValue == 0 ? item["id"].string : item["master_id"].string
            if (tableid == 1 ) {
                let sqlString = NSArray(array: dataArray!).componentsJoined(by:"','")
                //dataArray.bridgeToObjectiveC().componentsJoinedByString("','")
                sql = "insert into `\(table)` values ('\(sqlString)')"
            }else{
                dataArray?.remove(at: 0)
                dataArray?.removeLast()
                dataArray?.append(sn!)
                let sqlString = NSArray(array: dataArray!).componentsJoined(by: "','")
                sql = "insert into '\(table)' values (NULL,'\(sqlString)')"
            }
        case 2://修改
            let json = JSON(data: item["data"].string!.data(using: .utf8, allowLossyConversion: false)!)
            var updateArr = Array<String>()
            json.forEach{info in
                updateArr.append(tableid == 1 ? "`\(info.0)`=\(info.1)" :  "`\(info.0)`='\(info.1)'")
            }
            let updateString = NSArray(array:updateArr).componentsJoined(by: ",")
            if (tableid == 1 ) { //银行分类例外
                sql = "update `\(table)` set \(updateString) where id='"+item["master_id"].string!+"'"
            }else{
                sql = "update `\(table)` set \(updateString) where sn='"+item["master_id"].string!+"'"
            }
        case 3://删除
            sql = "delete from `\(table)` where sn='"+item["master_id"].string!+"'"
            break
        default: break
        }
        if(!DBRecord().execute(sql: sql)){
            print("importDB error")
        }
        UserDefaults.standard.set(item["id"].intValue,  forKey: "maxid")
    }
    
    func showprogress(){
        if(Int(self.progress) < 1){
            self.hud.progress = self.progress
            self.hud.detailsLabel.text = "\(self.progressId)/\(self.rsycnCountString)"
        }else{
            self.hud.customView = UIImageView(image: UIImage(named:"Checkmark"))
            self.hud.mode = MBProgressHUDMode.customView
            
            self.hud.label.text = "导入完成";
            self.hud.detailsLabel.text = "共计：\(self.rsycnCountString)条"
            self.hud.hide(animated: true, afterDelay: 1)
            self.timer.invalidate()
        }
    }
    
    //MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemDataSouce[section].count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.itemDataSouce.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let item = self.itemDataSouce[indexPath.section][indexPath.row]
        cell.textLabel?.text = item.name
        if (indexPath.row == 0 && indexPath.section == 1){
             
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.text = DBRecord.userAgent()[ UserDefaults.standard.integer(forKey: "DeviceID")]
       
        }
        return cell
    }
}
