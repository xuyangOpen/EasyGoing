//
//  TimeLineController.swift
//  EasyGoing
//
//  Created by King on 16/8/29.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import AVOSCloud

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
    
    //日历视图
    var calendarController = UIViewController()
    var calendar = PDCalendarViewController()
    
    //统计视图
    var statisticalView:StatisticalView?
    //当前选中日期
    var dateString = ""
    
    //顶部头视图
    var titileView = TitleView.init(frame: CGRectMake(0, 0, 100, 40), title: String.init(format: "%d-%02d", PDCalendarAttribute.year(NSDate()),PDCalendarAttribute.month(NSDate())))
    //顶部头视图弹出层视图
    let chooseDatePopView = WBPopOverView.init(origin: CGPointMake(Utils.screenWidth/2.0, 64), width: Utils.scaleFloat(300), height: Utils.scaleFloat(200), direction: WBArrowDirection.Up2)
    let chooseDateController = ChooseDateController()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置导航栏
        setNavigation()
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
        
        query.findObjectsInBackgroundWithTarget(self, selector: #selector(callbackWithResult(_:error:)))
    }
    
    //MARK:查询结果的回调方法
    func callbackWithResult(objects: NSArray, error: NSError){
        if objects.count > 0 {
            self.dataSource.removeAll()
            let objs = objects as! [AVObject]
            for obj in objs{//将数据解析成类
                self.dataSource.append(TimeLineRecord.initRecordWithAVObject(obj))
            }
            self.timeLineTableView.reloadSections(NSIndexSet.init(index: 1), withRowAnimation: .Fade)
        }else{
            Utils.showHUDWithMessage("当天没有数据", time: 1, block: {})
            self.dataSource.removeAll()
            self.timeLineTableView.reloadSections(NSIndexSet.init(index: 1), withRowAnimation: .Fade)
        }
    }

    //MARK:tableview的代理方法
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {//section 0 是日历组
            return 0
        }else{//数据组
            return self.dataSource.count
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {//日历组视图
            //配置日历
            self.setCalendarWithDate(NSDate())
            
            return calendarController.view
        }else{//统计组视图
            //总金额
            var totalMoney:CGFloat = 0.0
            //项目数
            var projectNum = [String]()
            for i in 0..<self.dataSource.count {
                totalMoney += self.dataSource[i].recordCost
                if !projectNum.contains(self.dataSource[i].recordEvent) {
                    projectNum.append(self.dataSource[i].recordEvent)
                }
            }
            self.statisticalView = StatisticalView.init(frame: CGRectMake(0, 0, Utils.screenWidth, 44), projectCount: projectNum.count, money: totalMoney, timeStr: self.dateString)
            
            return statisticalView
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell.init(style: .Default, reuseIdentifier: "NoneCell")
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
        if indexPath.section == 0 {
            return 0
        }
        let height = self.cellForHeight.heightForCell(self.dataSource[indexPath.row])
        return height
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            let tempViewController = UIViewController()
            let tempCalender = PDCalendarViewController()
            tempCalender.transferShowDate = NSDate()
            tempCalender.calendarShow(tempViewController, animated: false, calendarOriginY: 0)
            tempCalender.selectedCompeletionClourse = { (year,month,day) in
                
            }
            return tempCalender.calendarView.size_height
        }else{
            return 44
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section > 0 {
            //将展开属性设置成跟之前相反
            self.dataSource[indexPath.row].isExpand = !self.dataSource[indexPath.row].isExpand
            //刷新当前展开或收起的cell
            self.timeLineTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    //删除操作
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            Utils.showJCAlert("删除提示", tips: "是否删除 '" + self.dataSource[indexPath.row].recordEvent + "' 项纪录", complete: {
                Utils.sharedInstance.showLoadingViewOnView("删除中", parentView: self.view)
                //调用model的删除方法
                TimeLineRecord.deleteModel(self.dataSource[indexPath.row]) { [weak self] (error) in
                    Utils.sharedInstance.hideLoadingView()
                    if error == nil{
                        self?.dataSource.removeAtIndex(indexPath.row)
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                        tableView.reloadSections(NSIndexSet.init(index: 1), withRowAnimation: .Automatic)
                    }else{//删除失败
                        Utils.showHUDWithMessage(error!.localizedDescription, time: 2, block: {})
                    }
                }
            })
        }
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删除"
    }
    
    //MARK:设置日历
    func setCalendarWithDate(date: NSDate){
        //设置头视图的frame
        calendar.transferShowDate = date
        calendar.calendarShow(calendarController, animated: true, calendarOriginY: 0)
        calendar.greenCircleDiameter = Utils.scaleFloat(35)
        calendar.selectedCompeletionClourse = { [weak self] (year,month,day) in
            let dateStr = String.init(format: "%d-%02d-%02d", year,month,day)
            if dateStr != self?.dateString {
                self?.dateString = dateStr
                //加载数据
                self?.reloadData(self!.dateString)
            }
        }
        //日历翻页时的回调
        calendar.monthChange = { [weak self] (date) in
            self?.titileView.titleLable.text = String.init(format: "%d-%02d", PDCalendarAttribute.year(date), PDCalendarAttribute.month(date))
            self?.titileView.setNeedsLayout()
        }
    }
    
    //MARK:设置导航栏
    func setNavigation(){
        //设置当前日期
        self.dateString = self.getCurrentTime()
        //设置返回按钮
        let item = UIBarButtonItem.init(title: NSLocalizedString("TimeLine.navigation.back", comment: "返回"), style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = item
        let rightBar = UIBarButtonItem.init(barButtonSystemItem: .Add, target: self, action: #selector(clickRightBarButton))
//        let rightBar = UIBarButtonItem.init(customView: rightButton)
        self.navigationItem.rightBarButtonItem = rightBar
        
        //设置顶部导航栏视图
        self.navigationItem.titleView = titileView
        titileView.tapClosure = { [weak self] () in
            //设置当前年份
            self?.chooseDateController.year = PDCalendarAttribute.year(NSDate())
            //设置当前月份
            self?.chooseDateController.month = PDCalendarAttribute.month(NSDate())
            //设置位置
            self?.chooseDateController.bounds = CGRectMake(0, 0, Utils.scaleFloat(300), Utils.scaleFloat(200))
            self?.chooseDateController.view.frame = CGRectMake(0, 0, Utils.scaleFloat(300), Utils.scaleFloat(200))
            self?.chooseDatePopView.backView.addSubview(self!.chooseDateController.view)
            //日期选择回调
            self?.chooseDateController.chooseDate = { (year,month) in
                //弹窗关闭
                self?.chooseDatePopView.dismiss()
                //日期选择
                let dateString = String.init(format: "%d-%02d-%02d", year,month,1)
                let fmt = NSDateFormatter()
                fmt.dateFormat = "yyyy-MM-dd"
                let date = fmt.dateFromString(dateString)
                if date != nil {
                    self?.calendar.jumpDate = date
                }
            }
            
            self?.chooseDatePopView.popView()
        }
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
            addVC.addTimeString = self.dateString
            //添加一个回调，如果添加了数据，则刷新当前选中日期的数据
            addVC.updateTimeLine = { [weak self] () in
                //初始化选中日期的数据
                self?.reloadData(self!.dateString)
            }
            self.navigationController?.pushViewController(addVC, animated: true)
            break
        case .AddEvent:
            //跳转到消费项目列表界面
            self.navigationController?.pushViewController(TimeLineAddEventController(), animated: true)
            break
        case .DataStatistics:
            //跳转到数据统计界面
            self.navigationController?.pushViewController(DataStatisticViewController(), animated: true)
        default:break
        }
       
    }
    
    deinit{
        print("TimeLine释放")
    }
    
}
