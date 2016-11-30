//
//  RecordDetailController.swift
//  EasyGoing
//
//  Created by King on 16/11/22.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

typealias closeClosure = () -> Void

enum RecordType {
    case EventType      //项目统计类型
    case YearType       //年统计类型
}

class RecordDetailController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var detailDataSource = [TimeLineRecord](){
        didSet{
            detailDataSource.sortInPlace {//按时间顺序倒序排，最新的排在最上面
                $0.0.createdAt > $0.1.createdAt
            }
        }
    }
    //消费项目
    var eventName = ""
    //消费时间
    var yearTime = ""
    //是否正在动画
    var isAnimation = false
    //详情类型 默认为消费项目类型
    var detailType = RecordType.EventType
    
    let detailTableView = UITableView.init(frame: CGRectZero, style: .Plain)
    //定义一个cell，用计算cell的高度
    var cellForHeight = TimeLineNormalCell()
    //动画时长
    let animationDuration = 0.5
    //关闭界面时的回调
    var closeDetailVC:closeClosure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
        self.configTableView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateWithDuration(animationDuration, animations: { 
            self.isAnimation = true
            self.detailTableView.frame = CGRectMake(0, Utils.scaleFloat(400), Utils.screenWidth, Utils.screenHeight - Utils.scaleFloat(400))
        }) { (flag) in
            self.isAnimation = false
        }
    }
    
    func configTableView(){
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.backgroundColor = UIColor.whiteColor()
        detailTableView.separatorStyle = .None
        detailTableView.frame = CGRectMake(0, Utils.screenHeight, Utils.screenWidth, Utils.screenHeight - Utils.scaleFloat(400))
        //注册数据显示cell
        self.detailTableView.registerClass(TimeLineNormalCell.self, forCellReuseIdentifier: "timeLineDataCell")
        self.view.addSubview(detailTableView)
    }
    
    //MARK:tableview的代理方法
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("timeLineDataCell") as! TimeLineNormalCell
        cell.setModel(self.detailDataSource[indexPath.row],isShowTime: true)
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var money:CGFloat = 0
        for record in self.detailDataSource {
            money += record.recordCost
        }
        if self.detailType == .EventType {
            let headerView = StatisticalView.init(frame: CGRectMake(0, 0, Utils.screenWidth, 44), projectCount: "消费项目：\(eventName)", money: money, timeStr: "总记录：\(self.detailDataSource.count)", isNeedLine: false)
            return headerView
        }else{
            let headerView = StatisticalView.init(frame: CGRectMake(0, 0, Utils.screenWidth, 44), projectCount: "总记录：\(self.detailDataSource.count)", money: money, timeStr: "\(yearTime)", isNeedLine: false)
            return headerView
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = self.cellForHeight.heightForCell(self.detailDataSource[indexPath.row])
        return height
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //将展开属性设置成跟之前相反
        self.detailDataSource[indexPath.row].isExpand = !self.detailDataSource[indexPath.row].isExpand
        //刷新当前展开或收起的cell
        self.detailTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    //MARK:关闭详情展示
    func dismissDetailVC(){
        self.isAnimation = true
        //开始回调方法
        if self.closeDetailVC != nil {
            self.closeDetailVC!()
        }
        //取消动画
        UIView.animateWithDuration(animationDuration, animations: {
            self.detailTableView.frame = CGRectMake(0, Utils.screenHeight, Utils.screenWidth, Utils.screenHeight - Utils.scaleFloat(400))
            self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        }, completion: { (flag) in
            self.view.removeFromSuperview()
            self.isAnimation = false
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let object = (touches as NSSet).anyObject() as! UITouch
        let point  = object.locationInView(self.view)
        if !CGRectContainsPoint(detailTableView.frame, point) {
            if !isAnimation {
                self.dismissDetailVC()
            }
            
        }
    }
}
