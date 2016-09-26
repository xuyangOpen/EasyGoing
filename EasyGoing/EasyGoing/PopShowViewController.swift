//
//  PopShowViewController.swift
//  单元格测试
//
//  Created by King on 16/8/22.
//  Copyright © 2016年 wendan. All rights reserved.
//

import UIKit

public enum timeLinePopMenu : Int {
    
    case None = 0                              //默认
    case AddRecord                             // 添加记录
    case DataStatistics                        // 数据统计
    
}

protocol menuSelectDelegate {
    //改变特效
    func selectPopMenu(type:timeLinePopMenu)
}

class PopShowViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var tableView:UITableView = UITableView.init(frame: CGRectZero, style: .Plain)
    //菜单名称的数组
    var optionArray = [String]()
    
    //代理
    var delegate:menuSelectDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置代理
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = Utils.bgColor
        
        optionArray.append("添加记录")
        optionArray.append("数据统计")
        //去掉弹簧效果
        tableView.bounces = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 一共2个选项
        return optionArray.count
    }

    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        cell = UITableViewCell.init(style: .Default, reuseIdentifier: "popCell")
        cell?.textLabel?.text = self.optionArray[indexPath.row]
        //去掉选中时的样式
        cell?.selectionStyle = .None
        return cell!
    }
 
    //选中之后的效果
    func tableView(tableView1: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            self.delegate?.selectPopMenu(.AddRecord)
        }else if indexPath.row == 1{
            self.delegate?.selectPopMenu(.DataStatistics)
        }
    }

    
}
