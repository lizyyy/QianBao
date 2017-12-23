//
//  Rsync.swift
//  qian8
//
//  Created by leeey on 14/7/6.
//  Copyright (c) 2014年 leeey. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

protocol RsyncDelegate {
    func rsyncFinish(a:Int,b:Int,c:Int)
}

class Rsync {
    var finish:Bool
    var rsyncTypeid:Int
    var insertCt:Int
    var insertCount:Int
    var 更新数_新增:Int
    var 更新数_修改:Int
    var 更新数_删除:Int
    init() {
        finish = false
        rsyncTypeid = 1
        insertCt = 0
        insertCount = 0
        更新数_新增 = 0
        更新数_修改 = 0
        更新数_删除 = 0
    }
    
    var delegate : RsyncDelegate?
    // MARK: - 执行刷新同步
    func 同步(){
        self.getData()
    }
    
    func getFinish(){
        self.setData()
    }
    
    // MARK: - 传输数据
    func setData(){
        if ( finish ){ rsyncTypeid += 1 }
        if ( rsyncTypeid >= 4) {
            self.delegate?.rsyncFinish(a: self.更新数_新增,b: self.更新数_修改,c:self.更新数_删除)
            return
        }
        _ = self.sendData(actionid: String(rsyncTypeid))
        insertCount = 0
        finish = false
    }
    
    func sendData(actionid : String)->Int {
        let sendData = DBRecord().getRsyncList(actionid: actionid)
        insertCt = sendData.count
        if (insertCt == 0) {
            finish = true
            self.setData()
            return 0
        }
        for item in sendData {
            //组合传递的json  @notice:以后定义词典的时候带上类型，否则编译的时候速度会非常的慢
            let setDateDict:[String:String] =
                              ["id":"",
                               "master_id":String(item.master_id),
                               "action_id":String(item.action_id),
                               "table_id": String(item.table_id),
                               "user_id":String(item.user_id),
                               "rsync_status":String(item.rsync_status),
                               "rsync_rs":String(item.rsync_rs),
                               "data":item.data,
                               "local_id":String(item.local_id)]
            let parameters: Parameters = [
                "data": toJSONString2(setDateDict as NSDictionary),
                "user": String(describing: UserDefaults.standard.string(forKey: "DeviceID")),
                "action_id":String(item.action_id),
                "table_id":String(item.table_id),
                "local_id":String(item.local_id),
                "id":String(item.id)]
            Alamofire.request(apiUrl + "set2.php", method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON{ response in  //同步
                let value = response.result.value
                let tablename = self.tableName(tableid:item.table_id)
                let json = JSON(value!)
                let lastid = String(describing: json["lastid"])
                if ( ( item.table_id == 2 || item.table_id == 4 || item.table_id == 6 ) && item.action_id == 1  ){
                    let sql = "update `\(tablename)` set `sn`='\(lastid)' where `id` ='\(String(item.local_id))' "
                    let sql2 = "update `qian8_sync_list` set `master_id` = '\(lastid)'  where `local_id`='\(String(item.local_id))'"
                    if (DBRecord().execute(sql:sql) && DBRecord().execute(sql:sql2) ) {
                        print("更新同步记录表")
                    }
                }
                let sqlupdate = "update `qian8_sync_list` set `rsync_status`='1' where `id`='\(String(item.id))'"
                if(DBRecord().execute(sql:sqlupdate)) {
                    self.insertCount += 1;
                    if(self.insertCount == self.insertCt){
                        self.finish = true
                        self.setData()
                        return
                    }
                }
            }
       }
       return sendData.count
    }
    
    func getData(){
        var progressid = 1
        let url = apiUrl + "get.php" + "?id=" + String(describing: UserDefaults.standard.string(forKey: "maxid")!) + "&user=" + String(describing: UserDefaults.standard.string(forKey: "DeviceID")!)
        let queue = DispatchQueue(label: "backgroundget", qos: .default, attributes: .concurrent)
        var sql = ""
        Alamofire.request(url).responseJSON(queue: queue) { response in
            if (response.result.value == nil) {return}
            let json = JSON(response.result.value!)
            if (json["ct"] == "0") {
                self.getFinish()
                return //无数据
            }
            json["data"].forEach{ item in
                let obj = item.1
                print("更新到：" + String(describing: obj["id"]) + ",第：\(String(progressid))")
                let tableid =  obj["table_id"].intValue
                let table = self.tableName( tableid: tableid )
                let actionid = obj["action_id"].intValue
                switch actionid{
                case 1://新增
                    var dataArray = obj["data"].string?.components(separatedBy: "|")  
                    let sn = obj["master_id"].intValue == 0 ? obj["id"].string : obj["master_id"].string
                    if (tableid == 1 ) { //银行除外
                        let sqlString = NSArray(array: dataArray!).componentsJoined(by:"','")
                        sql = "insert into `\(table)` values ('\(sqlString)')"
                    }else{
                        dataArray?.remove(at: 0)
                        dataArray?.removeLast()
                        dataArray?.append(sn!)
                        let sqlString = NSArray(array: dataArray!).componentsJoined(by: "','")
                        sql = "insert into '\(table)' values (NULL,'\(sqlString)')"
                    }
                    self.更新数_新增 += 1
                case 2://修改
                    let json = JSON(data: obj["data"].string!.data(using: .utf8, allowLossyConversion: false)!)
                    var updateArr = Array<String>()
                    json.forEach{info in
                        updateArr.append(tableid == 1 ? "`\(info.0)`=\(info.1)" :  "`\(info.0)`='\(info.1)'")
                    }
                    let updateString = NSArray(array:updateArr).componentsJoined(by: ",")
                    if (tableid == 1 ) { //银行分类例外
                        sql = "update `\(table)` set \(updateString) where id='"+obj["master_id"].string!+"'"
                    }else{
                        sql = "update `\(table)` set \(updateString) where sn='"+obj["master_id"].string!+"'"
                    }
                    self.更新数_新增 += 1
                case 3://删除
                    sql = "delete from `\(table)` where sn='"+obj["master_id"].string!+"'"
                    self.更新数_新增 += 1
                default:break
                }
                if(!DBRecord().execute(sql: sql)){
                    print("importDB error")
                }
                UserDefaults.standard.set(obj["id"].intValue,  forKey: "maxid")
                progressid += 1;
            }
            self.getFinish()
        }
    }
    
    func tableName(tableid:Int) -> String{
        let table = ["qian8_bank","qian8_bank_list","qian8_income_category",
                     "qian8_income_list","qian8_expense_category","qian8_expense_list","qian8_user"]
        return table[tableid-1]
    }
}
