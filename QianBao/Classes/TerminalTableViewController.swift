//
//  TerminalTableViewController.swift
//  qian8
//
//  Created by leeey on 14/6/30.
//  Copyright (c) 2014年 leeey. All rights reserved.
//
import UIKit
class TerminalTableViewController: UITableViewController {
    var checkedIndexPath = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "设备列表"
        checkedIndexPath = UserDefaults.standard.integer(forKey: "DeviceID") - 1
        self.tableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_  tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.detailTextLabel?.text = "id:"+String(indexPath.row+1)
        cell.textLabel?.text = DBRecord.userAgent()[indexPath.row+1]
        cell.accessoryType = indexPath.row == checkedIndexPath ? .checkmark : .none
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for cell in tableView.visibleCells as [UITableViewCell] {
            cell.accessoryType = .none
        }
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        UserDefaults.standard.set(indexPath.row+1, forKey: "DeviceID")
    }
    
    override func tableView(_  tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
    }
    
    
}
