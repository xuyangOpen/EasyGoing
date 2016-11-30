//
//  SelectPromptDistanceController.swift
//  EasyGoing
//
//  Created by King on 16/11/28.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import AVOSCloud

typealias promptDistanceClosure = (Int) -> Void

class SelectPromptDistanceController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let distanceTableView = UITableView()
    var dataSource = [Int]()
    let identifier = "promptDistanceCell"
    //当前提示距离
    var distance = 0
    //距离选择回调
    var chooseDistance:promptDistanceClosure?
    //当前选中的cell下标  -1表示未有选中的
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "提示距离"
        //设置TableView
        self.configTableView()
        
        //设置数据源，提示距离从100米 - 1000米
        for i in 1..<11 {
            self.dataSource.append(i*100)
        }
    }
    
    //MARK:设置TableView
    func configTableView(){
        self.distanceTableView.delegate = self
        self.distanceTableView.dataSource = self
        self.distanceTableView.frame = self.view.frame
        self.distanceTableView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.distanceTableView)
        
        self.distanceTableView.registerClass(PromptDistanceCell.self, forCellReuseIdentifier: identifier)
    }
    
    //MARK:UITableView的代理方法
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! PromptDistanceCell
        
        if self.dataSource[indexPath.row] == distance || self.selectedIndex == indexPath.row{
            cell.setData("\(self.dataSource[indexPath.row])米", isChoose: true)
            self.selectedIndex = indexPath.row
        }else{
            cell.setData("\(self.dataSource[indexPath.row])米", isChoose: false)
        }
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.chooseDistance != nil {
            //把之前选中的cell变成非选中的
            if self.selectedIndex > -1 && self.selectedIndex < self.dataSource.count {
                //如果cell在可视范围内
                if tableView.cellForRowAtIndexPath(NSIndexPath.init(forRow: self.selectedIndex, inSection: 0)) != nil {
                    let cell = tableView.cellForRowAtIndexPath(NSIndexPath.init(forRow: self.selectedIndex, inSection: 0)) as! PromptDistanceCell
                    cell.setData("\(self.dataSource[self.selectedIndex])米", isChoose: false)
                }
            }
            //把当前选中cell变成选中状态
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! PromptDistanceCell
            cell.setData("\(self.dataSource[indexPath.row])米", isChoose: true)
            self.selectedIndex = indexPath.row
            self.distance = self.dataSource[indexPath.row]
            //回调传值
            self.chooseDistance!(self.dataSource[indexPath.row])
            
            //保存设置的位置距离
            AVUser.currentUser()?.setObject(self.distance, forKey: "destinationDistance")
            AVUser.currentUser()?.saveInBackground()
        }
    }
    
    deinit{
        print("设置提示距离页面释放")
    }
    
}
