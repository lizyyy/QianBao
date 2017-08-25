//
//  MyViewController.swift
//  qian8new
//
//  Created by zhiyuan on 2016/10/18.
//  Copyright © 2016年 leeey. All rights reserved.
//

import UIKit
class MyViewController : UITableViewController {
    var data = Dictionary<Int,[bankItem]>() //按照用户分组的数据集
    let bankUser = DBRecord().getBankUser() //用户组
    let bankBgColor:[String:Int] = [ "RMB":0xFD7D75,"BOC":0xDE4354,"CMB":0xDD4254,"COMM":0x3E6BAF,"ALIPAY":0x50A2EC]
    var sumBank = Dictionary<Int, (current:Double,fixed:Double)>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //按照用户分组的数据
        let dataBank = DBRecord().getBank()
        self.bankUser.forEach({ (user) in
            //初始化
            data[user.user_id] = [bankItem]()
            sumBank[user.user_id] = (current:0,fixed:0)
            dataBank.forEach({bank in
                if( bank.user_id == user.user_id ) {
                    data[bank.user_id]?.append(bank)
                    sumBank[bank.user_id]?.current += Double(bank.current_deposit)!
                    sumBank[bank.user_id]?.fixed += Double(bank.fixed_deposit)!
                }
            })
        })
        self.tableView.reloadData()
    }
    
    func inittitle()->MyViewController{
        self.title = "Me"
        return self
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 25
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data[self.bankUser[section].user_id]!.count + 2
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.data.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        switch indexPath.row {
        case 0:  //第一行总资产
            let mycell = MeCellView( cellStyle:MeCellStyle.total, reuseIdentifier:MeCellView.identifier)
            mycell.accessoryType = .disclosureIndicator
            mycell.name.text = "总资产"
            mycell.current_deposit.text = "活期：" + (sumBank[self.bankUser[indexPath.section].user_id]?.current.format(".2"))!
            mycell.fixed_deposit.text = "定期：" + (sumBank[self.bankUser[indexPath.section].user_id]?.fixed.format(".2"))!
            mycell.view.backgroundColor = UIColor(hex: 0xF5F5F5)
            cell = mycell
        case data[self.bankUser[indexPath.section].user_id]!.count + 1 : //最后一行，借贷负债
            let mycell = MeCellView( cellStyle:MeCellStyle.footer, reuseIdentifier:MeCellView.identifier)
            mycell.accessoryType = .disclosureIndicator
            mycell.view.backgroundColor = UIColor(hex: 0xF5F5F5)
            mycell.name.text = "借贷（自动记账）"
            cell = mycell
            break;
        default:
            let mycell = MeCellView( cellStyle:MeCellStyle.bank, reuseIdentifier:MeCellView.identifier)
            let item = self.data[self.bankUser[indexPath.section].user_id]![indexPath.row - 1]
            mycell.imageLayer.contents = UIImage(named: item.bank_name)?.cgImage
            mycell.name.text = item.name
            mycell.card_no.text = item.card_no
            mycell.current_deposit.text = item.current_deposit
            mycell.fixed_deposit.text = item.fixed_deposit
            mycell.view.backgroundColor = UIColor(hex:bankBgColor[item.bank_name]!,alpha:1)
            cell = mycell
        }
        cell.selectionStyle = .none
        return cell
    }
}
