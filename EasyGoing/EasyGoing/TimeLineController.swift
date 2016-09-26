//
//  TimeLineController.swift
//  EasyGoing
//
//  Created by King on 16/8/29.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class TimeLineController: UIViewController,UITableViewDelegate,UITableViewDataSource,menuSelectDelegate {
    
    let timeLineTableView = UITableView()
    //弹出层视图（height = cell默认高度44 * cell的个数5个）
    let popView = WBPopOverView.init(origin: CGPointMake(Utils.screenWidth-25, 64), width: 170, height: 88, direction: WBArrowDirection.Up3)
    //弹出层表视图
    let popViewController:PopShowViewController = PopShowViewController()
    //数据源
    var dataSource = [TimeLineRecord]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置导航栏
        setNavigation()
        self.timeLineTableView.frame = self.view.bounds
        self.timeLineTableView.delegate = self
        self.timeLineTableView.dataSource = self
        self.view.addSubview(self.timeLineTableView)
        
        self.timeLineTableView.registerClass(TimeLineCalendarCell.self, forCellReuseIdentifier: "calendarCell")
        
        //查询数据
        let query = AVQuery.init(className: "TimeLineRecord")
        //查询当前日期的数据
        query.whereKey("recordTime", equalTo: self.getCurrentTime())
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil{print(objects.count)
                if objects.count > 0 {
                    let objs = objects as! [AVObject]
                    for obj in objs{
                        let model = TimeLineRecord()
                        model.recordEvent = obj.objectForKey("recordEvent") as! String
                        model.recordCost = CGFloat(obj.objectForKey("recordCost").floatValue)
                        model.recordTime = obj.objectForKey("recordTime") as! String
                        model.recordMark = obj.objectForKey("recordMark") as! String
                        self.dataSource.append(model)
                    }
                }
            }else{
                print(error.localizedDescription)
                Utils.showHUDWithMessage(error.localizedDescription, time: 2, block: {})
            }
            
        }

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("calendarCell") as! TimeLineCalendarCell
            cell.calendarCallBack = {//日历点击后的回调，返回选中时间(Int)
                (day,month,year) in
                self.title = String.init(format: "%d-%02d-%02d", year,month,day)
            }
            cell.setCalendarView()
            cell.selectionStyle = .None
            return cell
        }else{
            let cell = UITableViewCell.init(style: .Default, reuseIdentifier: "cell")
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    
    //MARK:设置导航栏
    func setNavigation(){
        //设置标题
        self.title = self.getCurrentTime()
        //设置返回按钮
        let item = UIBarButtonItem.init(title: NSLocalizedString("TimeLine.navigation.back", comment: "返回"), style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = item
        //设置右边的按钮
        let rightBar = UIBarButtonItem.init(barButtonSystemItem: .Add, target: self, action: #selector(clickRightBarButton))
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
            self.navigationController?.pushViewController(addVC, animated: true)
        case .DataStatistics:
            print("数据统计")
        default:break
        }
       
    }
}
