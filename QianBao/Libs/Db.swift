//
//  Db.swift
//  qian8new
//
//  Created by zhiyuan on 2016/10/19.
//  Copyright © 2016年 leeey. All rights reserved.
//

import Foundation
import FMDB

protocol Foo {
    var time:String{get}
}

class DBRecord {
    let db = DBUserManager.sharedInstance.openUserDB()!
    func execute(sql:String){
        self.db.executeStatements(sql)
    }
    
    func lastid()-> Int {
        return Int(db.lastInsertRowId());
    }
    
    class func userAgent()->Dictionary<Int,String>{
        return [1:"lzy's iphone",2:"jyy's iphone",3:"macbook",4:"初始化设备数据"]
    }
    
    //MARK: 获取用户
    func getBankUser()-> [bankItem]{
        do{
            let data = try self.db.executeQuery("select * from qian8_bank group by user_id", values: nil)
            return bankSet(data)
        }catch{ return []}
    }
    
    //MARK: 获取银行账户列表
    func getBank() -> [bankItem] {
        do{
            let data = try self.db.executeQuery("select * from qian8_bank", values: nil)
            return bankSet(data)
        }catch{ return []}
    }
    
    //MARK: 获取支出数据
    func getExpensesList() ->[expenseListItem] {
        do{
            let data = try self.db.executeQuery("select l.*,c.name as cate_name,u.user as user_name,b.name as bank_name from qian8_expense_category c,qian8_expense_list l,qian8_bank b,qian8_user u where l.cate_id = c.id and l.user_id = u.id and l.bank_id = b.id and l.time like '2016%' order by l.time desc", values: nil)
            return expenseListSet(data)
        }catch{ return []}
    }
    
    func getExpenses() ->[expenseItem] {
        do{
            let data = try self.db.executeQuery("select * from qian8_expense_category", values: nil)
            return expenseSet(data)
        }catch{ return []}
    }
    
    //MARK: 获取收入数据
    func getIncomeList() ->[incomeListItem] {
        do{
            let data = try self.db.executeQuery("select * from qian8_income_list where time like '2016-11%'", values: nil)
            return incomeListSet(data)
        }catch{ return []}
    }
    
    func getIncome() ->[incomeItem] {
        do{
            let data = try self.db.executeQuery("select * from qian8_income_category", values: nil)
            return incomeSet(data)
        }catch{ return []}
    }
    
    //MARK: 获取转账数据
    func getBankList() ->[bankListItem] {
        do{
            let data = try self.db.executeQuery("select * from qian8_bank_list where time like '2016-11%'", values: nil)
            return bankListSet(data)
        }catch{ return []}
    }
    
    
    //这里用any的方式实现
    func groupAny(data:[Any])->Dictionary<String,[Any]>{
        var groupList =  Dictionary<String,[Any]>()
        data.forEach({obj in
            if (obj is Foo) {
                let key = ((obj as! Foo).time as NSString).substring(to: 7)
                if (groupList[key] == nil) {
                    groupList[key] =  []
                }else{
                    groupList[key]?.append(obj)
                }
            }
        })
        return groupList
    }
    
    //泛型方式实现
    func group<T:Foo>(data:[T])->Dictionary<String,[T]>{
        var groupList =  Dictionary<String,[T]>()
        data.forEach({obj in
            let key = (obj.time as NSString).substring(to: 7)
            groupList[key] == nil ? groupList[key] =  [] : groupList[key]?.append(obj)
        })
        return groupList
    }
    
    //MARK:- 设置数据集
    func bankSet(_ data:FMResultSet) ->[bankItem] {
        var rs = [bankItem]()
        while (data.next() != false){
            var item = bankItem()
            item.id = Int(data.int(forColumn: "id"))
            item.name = data.string(forColumn:"name")!
            item.user_id = Int(data.int(forColumn:"user_id"))
            item.card_no = data.string(forColumn:"card_no")
            item.bank_name = data.string(forColumn:"bank_name")
            item.current_deposit = data.double(forColumn: "current_deposit").format(".2")
            item.fixed_deposit =  data.double(forColumn: "fixed_deposit").format(".2")
            rs.append(item)
        }
        return rs
    }
    
    func bankListSet(_ data:FMResultSet) ->[bankListItem] {
        var rs = [bankListItem]()
        while (data.next() != false){
            var item = bankListItem()
            item.id = Int(data.int(forColumn: "id"))
            item.from_bank_id = Int(data.int(forColumn:"from_bank_id"))
            item.to_bank_id = Int(data.int(forColumn:"to_bank_id"))
            item.time = data.string(forColumn:"time")
            item.money = data.double(forColumn: "money").format(".2")
            item.type = Int(data.int(forColumn:"type"))
            item.demo = data.string(forColumn:"demo")
            item.sn = Int(data.int(forColumn:"sn"))
            rs.append(item)
        }
        return rs
    }
    
    func expenseSet(_ data:FMResultSet) ->[expenseItem] {
        var rs = [expenseItem]()
        while (data.next() != false){
            var item = expenseItem()
            item.id = Int(data.int(forColumn: "id"))
            item.name = data.string(forColumn: "name")
            item.description = data.string(forColumn: "description")
            rs.append(item)
        }
        return rs
    }
    
    func expenseListSet(_ data:FMResultSet) ->[expenseListItem] {
        var rs = [expenseListItem]()
        while (data.next() != false){
            var item = expenseListItem()
            item.id = Int(data.int(forColumn: "id"))
            item.time = data.string(forColumn: "time")
            item.user_id = Int(data.int(forColumn: "user_id"))
            item.cate_id = Int(data.int(forColumn: "cate_id"))
            item.demo = data.string(forColumn: "demo")
            item.sn = Int(data.int(forColumn: "sn"))
            item.bank_id = Int(data.int(forColumn: "bank_id"))
            item.price = data.double(forColumn: "price").format(".2")
            item.week = toWeek(date: toDate(item.time) as NSDate)
            item.user_name = data.string(forColumn: "user_name")
            item.cate_name = data.string(forColumn: "cate_name")
            item.bank_name = data.string(forColumn: "bank_name")
            rs.append(item)
        }
        return rs
    }
    
    func incomeSet(_ data:FMResultSet) ->[incomeItem] {
        var rs = [incomeItem]()
        while (data.next() != false){
            var item = incomeItem()
            item.id = Int(data.int(forColumn: "id"))
            item.name = data.string(forColumn: "name")
            item.description = data.string(forColumn: "description")
            rs.append(item)
        }
        return rs
    }
    
    func incomeListSet(_ data:FMResultSet) ->[incomeListItem] {
        var rs = [incomeListItem]()
        while (data.next() != false){
            var item = incomeListItem()
            item.id = Int(data.int(forColumn: "id"))
            item.time = data.string(forColumn: "time")
            item.user_id = Int(data.int(forColumn: "user_id"))
            item.cate_id = Int(data.int(forColumn: "cate_id"))
            item.demo = data.string(forColumn: "demo")
            item.sn = Int(data.int(forColumn: "sn"))
            item.bank_id = Int(data.int(forColumn: "bank_id"))
            item.money = data.double(forColumn: "money").format(".2")
            rs.append(item)
        }
        return rs
    }
}

struct bankItem { //银行账户信息
    var id  = 0
    var name = ""
    var user_id = 0
    var card_no = ""
    var bank_name = ""
    var current_deposit = ""
    var fixed_deposit = ""
}

struct bankListItem { //转账记录
    var id  = 0
    var from_bank_id = 0
    var to_bank_id = 0
    var time = ""
    var money = ""
    var type = 0
    var demo = ""
    var sn = 0
}

struct expenseItem { //支出分类
    var id  = 0
    var name = ""
    var description = ""
}

struct expenseListItem:Foo {
    //支出记录
    var id  = 0
    var time = ""
    var user_id = 0
    var cate_id = 0
    var user_name = ""
    var cate_name = ""
    var demo = ""
    var sn = 0
    var bank_id = 0
    var bank_name = ""
    var price = ""
    var week = ""
}

struct incomeItem { //收入分类
    var id  = 0
    var name = ""
    var description = ""
}


struct incomeListItem {//收入记录
    var id  = 0
    var time = ""
    var user_id = 0
    var cate_id = 0
    var demo = ""
    var sn = 0
    var bank_id = 0
    var money = ""
}

//MARK:- DBManager类
class DBUserManager: NSObject {
    var database: FMDatabase?
    var dbName = ""
    var docDbName = ""
    let fm = FileManager.default
    static let sharedInstance = DBUserManager()
    fileprivate override init() {} // 这就阻止其他对象使用这个类的默认的'()'初始化方法
    func openUserDB() -> FMDatabase? {
        let db = "data3.0.5.zip"
        let docPath = URL( fileURLWithPath: (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] )).appendingPathComponent(db).path
        //print(docPath)
        database = FMDatabase(path:docPath)
        if (fm.fileExists(atPath: docPath)) { //数据库存在
            if database!.open() {
                return database!
            }else{
                print("无法打开数据库")
                database = nil
            }
        }else{ //初始化数据库，建表
            database!.open()
            let tableSql = "                                                                                                                                                                CREATE TABLE qian8_bank (id integer PRIMARY KEY NOT NULL,name varchar(20) NOT NULL,user_id integer(11) NOT NULL,card_no varchar(30) NOT NULL,bank_name varchar(30) NOT NULL,current_deposit varchar(15) NOT NULL DEFAULT(null),fixed_deposit varchar(15) NOT NULL DEFAULT(null));                       CREATE TABLE qian8_bank_list (id integer PRIMARY KEY AUTOINCREMENT NOT NULL,from_bank_id integer NOT NULL,to_bank_id integer NOT NULL,time date NOT NULL,money double(15,2) NOT NULL,type integer NOT NULL,demo varchar(30) NOT NULL,sn integer NOT NULL);                                                                              CREATE TABLE qian8_expense_category (id integer PRIMARY KEY AUTOINCREMENT NOT NULL,name varchar(10) NOT NULL,description varchar(30) NOT NULL);                 CREATE TABLE qian8_expense_list (id integer PRIMARY KEY AUTOINCREMENT NOT NULL,cate_id integer NOT NULL,user_id integer NOT NULL,time date NOT NULL,price double(15,2) NOT NULL,demo text NOT NULL,bank_id integer NOT NULL,sn varchar(15) NOT NULL DEFAULT(0));                                      CREATE TABLE qian8_income_category (id integer PRIMARY KEY  AUTOINCREMENT NOT NULL,name varchar(10) NOT NULL,description varchar(30) NOT NULL);      CREATE TABLE qian8_income_list (id integer PRIMARY KEY AUTOINCREMENT NOT NULL,time date NOT NULL,user_id varchar(3) NOT NULL,money double(15,2) NOT NULL,demo text NOT NULL,cate_id integer NOT NULL,bank_id integer NOT NULL,sn varchar(15) NOT NULL DEFAULT(0));                                             CREATE TABLE qian8_sync_list (id integer PRIMARY KEY AUTOINCREMENT NOT NULL,master_id integer NOT NULL,action_id integer(1) NOT NULL,table_id integer(1) NOT NULL,user_id integer(1) NOT NULL,rsync_status integer(1) NOT NULL,rsync_rs integer(1) NOT NULL,data varchar(300) NOT NULL,local_id integer(1) NOT NULL);                                                                                                                                                             CREATE TABLE qian8_user (id integer PRIMARY KEY AUTOINCREMENT NOT NULL,user varchar(20) NOT NULL,pass varchar(40) NOT NULL,level integer NOT NULL,f_id integer NOT NULL,role varchar NOT NULL,time date NOT NULL);"
            database?.executeStatements(tableSql)
            return database!
        }
        return database
    }
    
    func closeDB() {
        if let db = database {
            db.close()
            database = nil
        }
    }
    
    deinit {
        closeDB()
    }
}
