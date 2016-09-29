//
//  PopShowViewController.swift
//  单元格测试
//
//  Created by King on 16/8/22.
//  Copyright © 2016年 wendan. All rights reserved.
//

import UIKit
import SnapKit

public enum timeLinePopMenu : Int {
    
    case None = 0                              //默认
    case AddRecord                             // 添加记录
    case AddEvent                              //添加消费项目
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
    //菜单图片数组
    var optionImageArray = [String]()
    //代理
    var delegate:menuSelectDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置代理
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = Utils.bgColor
        //菜单名
        optionArray.append("添加消费记录")
        optionArray.append("添加消费项目")
        optionArray.append("消费数据统计")
        //菜单图片
        optionImageArray.append("recordPlus")
        optionImageArray.append("eventPlus")
        optionImageArray.append("data")
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
        let cell:UITableViewCell = UITableViewCell.init(style: .Default, reuseIdentifier: "popCell")
        //图片
        let icon = UIImageView()
        icon.image = UIImage.init(named: self.optionImageArray[indexPath.row])
        cell.contentView.addSubview(icon)
        icon.snp_makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        //文字
        let contentLabel = UILabel()
        contentLabel.text = self.optionArray[indexPath.row]
        contentLabel.textColor = UIColor.blackColor()
        cell.contentView.addSubview(contentLabel)
        contentLabel.snp_makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(icon.snp_right).offset(10)
        }
        //去掉选中时的样式
        cell.selectionStyle = .None
        return cell
    }
 
    //选中之后的效果
    func tableView(tableView1: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            self.delegate?.selectPopMenu(.AddRecord)
        }else if indexPath.row == 1{
            self.delegate?.selectPopMenu(.AddEvent)
        }else if indexPath.row == 2{
            self.delegate?.selectPopMenu(.DataStatistics)
        }
    }

    
}
