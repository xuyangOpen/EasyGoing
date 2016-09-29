//
//  TimeLineController.swift
//  EasyGoing
//
//  Created by King on 16/8/29.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import SDAutoLayout

class TimeLineController: UIViewController,UITableViewDelegate,UITableViewDataSource,menuSelectDelegate {
    
    var timeLineTableView = UITableView()
    //弹出层视图（height = cell默认高度44 * cell的个数5个）
    let popView = WBPopOverView.init(origin: CGPointMake(Utils.screenWidth-25, 64), width: 170, height: 132, direction: WBArrowDirection.Up3)
    //弹出层表视图
    let popViewController:PopShowViewController = PopShowViewController()
    //MARK:数据源  （记得给数据源按消费项目排序）
    var dataSource = [TimeLineRecord]()
    //定义一个cell，用计算cell的高度
    var cellForHeight = TimeLineNormalCell()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置导航栏
        setNavigation()
        self.dataSource.append(TimeLineRecord())
        self.configTableView()
        //初始化当日的数据
        self.reloadData(self.getCurrentTime())
    }
    
    //MARK:配置tableview
    func configTableView(){
        self.timeLineTableView.frame = self.view.bounds
        self.timeLineTableView.delegate = self
        self.timeLineTableView.dataSource = self
        self.timeLineTableView.separatorStyle = .None
        self.view.addSubview(self.timeLineTableView)
        
        //注册日历cell
        self.timeLineTableView.registerClass(TimeLineCalendarCell.self, forCellReuseIdentifier: "calendarCell")
        //注册数据显示cell
        self.timeLineTableView.registerClass(TimeLineNormalCell.self, forCellReuseIdentifier: "timeLineDataCell")
    }
    
    //MARK:加载数据
    func reloadData(stringTime:String){
        //查询数据
        let query = AVQuery.init(className: "TimeLineRecord")
        //查询当前日期的数据
        query.whereKey("recordTime", equalTo: stringTime)
        //级联查询子目录
        query.includeKey("eventObject")
        //二级级联查询，查询子目录的父目录
        query.includeKey("eventObject.parentId")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil{//print("数据长度  \(objects.count)")
                if objects.count > 0 {
                    //先移除之前的，然后添加一个日历占位的
                    self.dataSource.removeAll()
                    self.dataSource.append(TimeLineRecord())
                    let objs = objects as! [AVObject]
                    for obj in objs{//将数据解析成类
                        let model = TimeLineRecord()
                     //   print(obj)
                        //子目录
                        let childEvent = obj.objectForKey("eventObject") as! AVObject
                        let child = childEvent.objectForKey("eventName") as! String
                        //父目录
                        let parentEvent = childEvent.objectForKey("parentId") as! AVObject
                        let parent = parentEvent.objectForKey("eventName") as! String
                        model.recordEvent = parent + " - " + child
                        model.recordCost = CGFloat(obj.objectForKey("recordCost").floatValue)
                        model.recordTime = obj.objectForKey("recordTime") as! String
                        model.recordMark = obj.objectForKey("recordMark") as! String
                        self.dataSource.append(model)
                    }
                    self.timeLineTableView.reloadData()
                }else{
                    Utils.showHUDWithMessage("当天没有数据", time: 1, block: {})
                    self.dataSource.removeAll()
                    self.dataSource.append(TimeLineRecord())
                    self.timeLineTableView.reloadData()
                }
            }else{
                print(error.localizedDescription)
                Utils.showHUDWithMessage(error.localizedDescription, time: 2, block: {})
            }
        }
    }
    
    //MARK:tableview的代理方法
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("calendarCell") as! TimeLineCalendarCell
            cell.calendarCallBack = {//日历点击后的回调，返回选中时间(Int)
                (day,month,year) in
                self.title = String.init(format: "%d-%02d-%02d", year,month,day)
                //加载数据
                self.reloadData(self.title!)
            }
            cell.setCalendarView()
            cell.selectionStyle = .None
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("timeLineDataCell") as! TimeLineNormalCell
            cell.setModel(self.dataSource[indexPath.row])
            cell.selectionStyle = .None
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 300
        }
        let height = self.cellForHeight.heightForCell(self.dataSource[indexPath.row])
        return height
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row > 0 {
            //将展开属性设置成跟之前相反
            self.dataSource[indexPath.row].isExpand = !self.dataSource[indexPath.row].isExpand
            //刷新当前展开或收起的cell
            self.timeLineTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    //MARK:设置导航栏
    func setNavigation(){
        //设置标题
        self.title = self.getCurrentTime()
        //设置返回按钮
        let item = UIBarButtonItem.init(title: NSLocalizedString("TimeLine.navigation.back", comment: "返回"), style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = item
        //设置右边的按钮
//        let rightButton = UIButton.init(type: .Custom)
//        rightButton.setImage(UIImage.init(named: "plus"), forState: .Normal)
//        rightButton.bounds = CGRectMake(0, 0, 30, 30)
//        rightButton.addTarget(self, action: #selector(clickRightBarButton), forControlEvents: .TouchUpInside)
        let rightBar = UIBarButtonItem.init(barButtonSystemItem: .Add, target: self, action: #selector(clickRightBarButton))
//        let rightBar = UIBarButtonItem.init(customView: rightButton)
        self.navigationItem.rightBarButtonItem = rightBar
        
    }
    
    //MARK:获取当前时间
    func getCurrentTime() -> String{
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.stringFromDate(NSDate())
    }
    
    //右侧按钮点击事件
    func clickRightBarButton(){
        popViewController.view.frame = CGRectMake(0, 0, 200, 200)
        //设置修改特效的代理
        popViewController.delegate = self
        popView.backView.addSubview(popViewController.tableView)
        popViewController.tableView.snp_makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(-1)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }
        self.popView.popView()
    }
    //MARK:选择按钮事件的跳转
    func selectPopMenu(type: timeLinePopMenu) {
        self.popView.dismiss()
        switch type {
        case .AddRecord:
            //跳转到添加消费项目界面
            let addVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("addRecord") as! AddRecordViewController
            addVC.addTimeString = self.title!
            //添加一个回调，如果添加了数据，则刷新当前选中日期的数据
            addVC.updateTimeLine = {
                () in
                //初始化选中日期的数据
                self.reloadData(self.title!)
            }
            self.navigationController?.pushViewController(addVC, animated: true)
        case .AddEvent:
            //跳转到消费项目列表界面
            self.navigationController?.pushViewController(TimeLineAddEventController(), animated: true)
            break
        case .DataStatistics:
            print("数据统计")
        default:break
        }
       
    }
}
