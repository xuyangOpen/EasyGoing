//
//  TimeLineAddEventController.swift
//  EasyGoing
//
//  Created by King on 16/9/28.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import SnapKit
import JCAlertView

//数据操作时的回调块  参数1是错误提示，如果为""则表示没有错误；参数2是保存成功之后的类
typealias dataManagerClosure = (String?,AnyObject?) -> Void

class TimeLineAddEventController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,TimeLineCellDelete {

    var eventTableView = TimeLineEventTableView()
    
    //数据源
    var dataSource = Utils.eventDataSource{
        didSet{
            //每次改变数据源时，都更新本地保存的数据源
            Utils.eventDataSource = self.dataSource
        }
    }
    //父目录
    var parentEvent = [TimeLineEvent]()
    //子目录 -> ["objectId":[TimeLineEvent]]  通过父目录的objectId找到所有子目录的数组
    var childEvent = NSMutableDictionary()
    //分组展开或者关闭的属性数组  0表示关闭  1表示展开
    var openOrCloseArray = [String]()
    
    //保存头视图中标题label的数组（方便后面修改头视图标题时，直接通过数组获取标题视图）
    var headerTitleArray = [UILabel]()
    
    //弹出视图
    var jcAlert:JCAlertView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "消费项目列表"
        self.view.backgroundColor = UIColor.whiteColor()
        self.configNavigation()
        self.configTableView()
        
        if dataSource == nil {
            //查询数据
            let query = AVQuery.init(className: "TimeLineEvent")
            //降序排列，把最新的显示在最前面
            query.orderByDescending("updatedAt")
            //查询userId为空的数据
            query.whereKey("userId", equalTo: "")
            query.findObjectsInBackgroundWithBlock({ (objs, error) in
                if error == nil{
                    if objs.count > 0{//print("数据长度== \(objs.count)")
                        self.dataSource = [TimeLineEvent]()
                        let avObj = objs as! [AVObject]
                        for obj in avObj{
                            self.dataSource?.append(TimeLineEvent.initEventWithAVObject(obj))
                        }
                        //配置数据源:将父目录和子目录分开
                        self.configDataSource(false)
                        //配置表视图
                        self.eventTableView.reloadData()
                        
                    }else{
                        Utils.showHUDWithMessage("没有查询到数据", time: 1, block: {})
                    }
                }else{
                    Utils.showHUDWithMessage(error.localizedDescription, time: 2, block: {})
                }
            })
        }else{
            //配置表视图
            self.configDataSource(false)
            self.eventTableView.reloadData()
        }
        
    }
    
    //MARK:配置右边导航栏
    func configNavigation(){
        let rightBar = UIBarButtonItem.init(barButtonSystemItem: .Add, target: self, action: #selector(clickRightBarButton))
        self.navigationItem.rightBarButtonItem = rightBar
    }
    //弹出添加项目的方法
    func clickRightBarButton(){
        let titleString = "添加消费项目"
        
        //计算弹出视图的高度 = 顶部高度10 + 标题高度 + 输入框顶部高度20 + 输入框高度40 + 按钮顶部高度20 + 按钮高度45 + 距离底部的高度15
        let titleHeight = Utils.heightForText(titleString, size: CGSizeMake(300, CGFloat.max), font: UIFont.boldSystemFontOfSize(17))
        let viewHeight = 10 + titleHeight + 20 + 40 + 20 + 45 + 15
        //弹出视图
        let alertView = UIView.init(frame: CGRectMake(0, 0, 320, viewHeight))
        alertView.backgroundColor = Utils.bgColor
        
        //标题
        let titleLable = UILabel()
        titleLable.font = UIFont.boldSystemFontOfSize(17)
        titleLable.numberOfLines = 0
        titleLable.textAlignment = .Center
        titleLable.text = titleString
        
        alertView.addSubview(titleLable)
        titleLable.snp_makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        //输入框
        let textField = UITextField.init(frame: CGRectMake(0, 0, 300, 40))
        textField.placeholder = "请输入项目名称"
        textField.backgroundColor = UIColor.whiteColor()
        alertView.addSubview(textField)
        textField.snp_makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLable.snp_bottom).offset(30)
            make.width.equalTo(300)
            make.height.equalTo(40)
        }
        
        //取消按钮
        let cancelButton = UIButton()
        cancelButton.setTitle("取消", forState: .Normal)
        cancelButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        cancelButton.backgroundColor = UIColor.whiteColor()
        cancelButton.bk_addEventHandler({ (btn) in
            self.jcAlert?.dismissWithCompletion({})
            }, forControlEvents: .TouchUpInside)
        alertView.addSubview(cancelButton)
        cancelButton.snp_makeConstraints { (make) in
            make.top.equalTo(textField.snp_bottom).offset(15)
            make.left.equalTo(10)
            make.width.equalTo(140)
            make.height.equalTo(45)
        }
        
        //保存按钮
        let closeButton = UIButton()
        closeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        closeButton.setTitle("保存", forState: .Normal)
        closeButton.backgroundColor = Utils.allTintColor
        alertView.addSubview(closeButton)
        closeButton.snp_makeConstraints { (make) in
            make.top.equalTo(textField.snp_bottom).offset(15)
            make.right.equalTo(-10)
            make.width.equalTo(140)
            make.height.equalTo(45)
        }
        closeButton.bk_addEventHandler({ (button) in
            self.jcAlert?.dismissWithCompletion({})
            //添加处理
            let check = Utils.isNullString(textField.text!)
            if !check.0{
                let string = check.1 as NSString
                if string.length<=15{
                    let avObject = AVObject.init(className: "TimeLineEvent")
                    avObject.setObject("", forKey: "userId")
                    avObject.setObject(check.1, forKey: "eventName")
                    avObject.saveInBackgroundWithBlock({ (flag, error) in
                        if error == nil{
                            //保存成功后，获取当前对象
                            let query = AVQuery.init(className: "TimeLineEvent")
                            query.getObjectInBackgroundWithId(avObject.objectForKey("objectId") as! String, block: { (newObject, queryError) in
                                if queryError == nil{
                                    //查询到数据之后，添加到数据源中第一个位置
                                    self.dataSource?.insert(TimeLineEvent.initEventWithAVObject(newObject), atIndex: 0)
                                    
                                    //配置数据源
                                    self.configDataSource(false)
                                    //在控制开关的数组中同时也需要添加一条记录
                                    self.openOrCloseArray.insert("0", atIndex: 0)
                                    //插入一个新的section
                                    self.eventTableView.insertSections(NSIndexSet.init(index: 0), withRowAnimation: .Fade)
                                    
                                    self.performSelector(#selector(self.reloadingData), withObject: nil, afterDelay: 0.2)
                                }else{
                                   Utils.showHUDWithMessage(queryError.localizedDescription, time: 1, block: {})
                                }
                            })
                        }else{
                            Utils.showHUDWithMessage(error.localizedDescription, time: 1, block: {})
                        }
                    })
                    
                }else{
                    Utils.showHUDWithMessage("不能超过15个字哦", time: 1, block: {})
                }
            }
        }, forControlEvents: .TouchUpInside)
        //弹出视图
        self.jcAlert = JCAlertView.init(customView: alertView, dismissWhenTouchedBackground: true)
        self.jcAlert?.show()
    }
    
    func reloadingData(){
        self.eventTableView.reloadData()
    }
    //MARK:配置表视图
    func configTableView(){
        eventTableView.frame = CGRectMake(0, 0, Utils.screenWidth, Utils.screenHeight)
        eventTableView.autoresizingMask = .FlexibleHeight
        eventTableView.delegate = self
        eventTableView.dataSource = self
        eventTableView.separatorStyle = .None       //去掉分隔线
        eventTableView.backgroundColor = Utils.bgColor
        //注册子目录的cell
        eventTableView.registerClass(TimeLineEventCell.self, forCellReuseIdentifier: "eventOperationCell")
        
        self.view.addSubview(eventTableView)
    }
    
    //MARK:配置数据源，参数表示是否需要为数据源重新按时间排序
    //修改状态时，isOrder为true，表示不需要排序，其他时候，均为false，表示需要排序
    func configDataSource(isOrder:Bool){
        self.parentEvent.removeAll()
        self.childEvent.removeAllObjects()
        //数据源有数据的情况下
        if self.dataSource?.count>0 {
            //得到父目录
            for model in self.dataSource! {
                if model.parentId == "" {
                    //添加一个父目录
                    self.parentEvent.append(model)
                    //数组属性默认为关闭
                    self.openOrCloseArray.append("0")
                }
            }
            //得到子目录，通过父目录的objectId，查找所有的子目录
            for parentModel in self.parentEvent {
                var childArray = [TimeLineEvent]()
                for allModel in self.dataSource! {
                    if allModel.parentId == parentModel.objectId {
                        //设置父目录名称
                        allModel.parentName = parentModel.eventName
                        childArray.append(allModel)
                    }
                }
                if !isOrder {
                    childArray.sortInPlace({ (obj1, obj2) -> Bool in
                        return obj1.updatedAt > obj2.updatedAt
                    })
                }
                //设置子目录的字典
                self.childEvent.setValue(childArray, forKey: parentModel.objectId)
            }
        }
    }
    
    //MARK:UITableview的代理方法
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.parentEvent.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.openOrCloseArray[section] == "0" {
            return 0
        }else{
            return (self.childEvent[self.parentEvent[section].objectId]?.count)!
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let eventCell:TimeLineEventCell = tableView.dequeueReusableCellWithIdentifier("eventOperationCell") as! TimeLineEventCell
        //获取model
        let childArray = self.childEvent[self.parentEvent[indexPath.section].objectId] as! [TimeLineEvent]
        let eventModel = childArray[indexPath.row]
        //设置cell的内容
        eventCell.setContentOfCell(eventModel.eventName, image: "menuIcon", numberOfBtn: 2, beginOffset: 50,bgColor:Utils.bgColor,event:eventModel,indexPath:indexPath)
        //cell打开菜单时的回调
        eventCell.openCellClosure = {
            (tableCell) in
            self.eventTableView.openingCell = tableCell
        }
        //代理
        eventCell.delegate = self
        return eventCell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
   
        let header = UIView.init(frame: CGRectMake(0, 0, Utils.screenWidth, 44))
        let headerView = UIScrollView.init(frame: CGRectMake(0, 0, Utils.screenWidth, 44))
        //屏幕宽度 + 按钮宽度70  总共三个按钮
        headerView.contentSize = CGSizeMake(Utils.screenWidth + 70*3, 44)
        headerView.bounces = false
        headerView.showsHorizontalScrollIndicator = false
        headerView.contentOffset = CGPointMake(0, 0)
        headerView.pagingEnabled = true
        headerView.delegate = self
        header.addSubview(headerView)
        //按钮
        let deleteButton = UIButton()
        deleteButton.tag = section
        deleteButton.setTitle("删除", forState: .Normal)
        deleteButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        deleteButton.backgroundColor = UIColor.redColor()
        headerView.addSubview(deleteButton)
        deleteButton.bk_addEventHandler({ (obj) in
            headerView.setContentOffset(CGPointMake(0, 0), animated: true)
            self.eventTableView.parentView = nil
            print("head中的删除按钮")
            //删除操作
         //   self.deleteGroup(self.parentEvent[section])
            }, forControlEvents: .TouchUpInside)
        
        deleteButton.snp_makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalTo(header)
            make.width.equalTo(70)
            make.height.equalTo(44)
        }
        let updateButton = UIButton()
        updateButton.tag = section
        updateButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        updateButton.setTitle("修改", forState: .Normal)
        updateButton.backgroundColor = UIColor.lightGrayColor()
        headerView.addSubview(updateButton)
        updateButton.snp_makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalTo(deleteButton.snp_left)
            make.width.equalTo(70)
            make.height.equalTo(44)
        }
        updateButton.bk_addEventHandler({ (obj) in
            headerView.setContentOffset(CGPointMake(0, 0), animated: true)
            self.eventTableView.parentView = nil
            //打开操作视图 参数2表示修改操作
            self.operationPopPresent(2, data: self.parentEvent[section],indexPath: NSIndexPath(),headerIndex: section)
            }, forControlEvents: .TouchUpInside)
        let addButton = UIButton()
        addButton.tag = section
        addButton.setTitle("添加", forState: .Normal)
        addButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        addButton.backgroundColor = UIColor.orangeColor()
        headerView.addSubview(addButton)
        addButton.snp_makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalTo(updateButton.snp_left)
            make.width.equalTo(70)
            make.height.equalTo(44)
        }
        addButton.bk_addEventHandler({ (obj) in
            headerView.setContentOffset(CGPointMake(0, 0), animated: true)
            self.eventTableView.parentView = nil
            //打开操作视图 参数1表示添加操作
            self.operationPopPresent(1, data: self.parentEvent[section],indexPath: NSIndexPath.init(forRow: 0, inSection: section),headerIndex: -1)
            }, forControlEvents: .TouchUpInside)
        //主菜单视图
        let mainView = UIView()
        mainView.backgroundColor = UIColor.whiteColor()
        headerView.addSubview(mainView)
        mainView.snp_makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.size.equalToSuperview()
        }
        //展开或关闭的属性图
        let openOrCloseImage = UIImageView()
        //改变展开或者关闭的图片
        openOrCloseImage.image = UIImage.init(named: (self.openOrCloseArray[section] == "0") ? "plus" : "minus")
        mainView.addSubview(openOrCloseImage)
        openOrCloseImage.snp_makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        //父目录名称
        let titleLabel = UILabel()
        titleLabel.text = self.parentEvent[section].eventName
        titleLabel.font = UIFont.boldSystemFontOfSize(17)
        mainView.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(openOrCloseImage.snp_right).offset(10)
            make.centerY.equalToSuperview()
        }
        //将头视图的标题视图存入数组中
        self.headerTitleArray.append(titleLabel)
        headerView.bk_whenTapped({
            if self.eventTableView.parentView != nil{
                self.eventTableView.parentView?.setContentOffset(CGPointMake(0, 0), animated: true)
                self.eventTableView.parentView = nil
            }else{
                //计算当前分组的数据量
                var indexPaths = [NSIndexPath]()
                for i in 0..<(self.childEvent[self.parentEvent[section].objectId]?.count)!{
                    let indexPath = NSIndexPath.init(forRow: i, inSection: section)
                    indexPaths.append(indexPath)
                }
                //改变展开或者关闭的图片
                openOrCloseImage.image = UIImage.init(named: (self.openOrCloseArray[section] == "0") ? "minus" : "plus")
                if self.openOrCloseArray[section] == "0"{//展开分组
                    self.openOrCloseArray[section] = "1"
                    tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                }else{//关闭分组
                    self.openOrCloseArray[section] = "0"
                    tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                }
            }
        })
        
        return header
    }
    //MARK:当父目录菜单打开时，记录父目录菜单
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.x > 0 {
            self.eventTableView.parentView = scrollView
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.openOrCloseArray[indexPath.section] == "0" {
            return 0
        }else{
            return 44
        }
    }
    
    //MARK:数据操作弹出的视图
    //操作视图  参数1表示操作类型（1：添加 2：修改）  参数2：（添加类型时，参数2表示父类，修改类型时，参数2表示本身） 参数3表示待修改的indexPath 
    //参数4表示头视图数组中，当前更新的下标，如果是头视图更新的话，则参数4>=0 ，cell更新时，参数4<0
    func operationPopPresent(type:Int,data:TimeLineEvent,indexPath:NSIndexPath,headerIndex:Int){
        
        let titleString = (type == 1) ? "添加'" + data.eventName + "'的子项目" : "修改'" + data.eventName + "'的项目名称"
       
        //计算弹出视图的高度 = 顶部高度10 + 标题高度 + 输入框顶部高度20 + 输入框高度40 + 按钮顶部高度20 + 按钮高度45 + 距离底部的高度15
        let titleHeight = Utils.heightForText(titleString, size: CGSizeMake(300, CGFloat.max), font: UIFont.boldSystemFontOfSize(17))
        let viewHeight = 10 + titleHeight + 20 + 40 + 20 + 45 + 15
        //弹出视图
        let alertView = UIView.init(frame: CGRectMake(0, 0, 320, viewHeight))
        alertView.backgroundColor = Utils.bgColor
        
        //标题
        let titleLable = UILabel()
        titleLable.font = UIFont.boldSystemFontOfSize(17)
        titleLable.numberOfLines = 0
        titleLable.textAlignment = .Center
        titleLable.text = titleString
        
        alertView.addSubview(titleLable)
        titleLable.snp_makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
            
        //输入框
        let textField = UITextField.init(frame: CGRectMake(0, 0, 300, 40))
        if type == 2 {
            textField.text = data.eventName
        }
        textField.placeholder = "请输入项目名称"
        textField.backgroundColor = UIColor.whiteColor()
        
        alertView.addSubview(textField)
        textField.snp_makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLable.snp_bottom).offset(30)
            make.width.equalTo(300)
            make.height.equalTo(40)
        }
        
        //取消按钮
        let cancelButton = UIButton()
        cancelButton.setTitle("取消", forState: .Normal)
        cancelButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        cancelButton.backgroundColor = UIColor.whiteColor()
        cancelButton.bk_addEventHandler({ (btn) in
            self.jcAlert?.dismissWithCompletion({})
            }, forControlEvents: .TouchUpInside)
        alertView.addSubview(cancelButton)
        cancelButton.snp_makeConstraints { (make) in
            make.top.equalTo(textField.snp_bottom).offset(15)
            make.left.equalTo(10)
            make.width.equalTo(140)
            make.height.equalTo(45)
        }
        
        //保存按钮
        let closeButton = UIButton()
        closeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        if type == 1 {
            closeButton.setTitle("保存", forState: .Normal)
        }else if type == 2{
            closeButton.setTitle("确定", forState: .Normal)
        }
        closeButton.backgroundColor = Utils.allTintColor
        
        alertView.addSubview(closeButton)
        closeButton.snp_makeConstraints { (make) in
            make.top.equalTo(textField.snp_bottom).offset(15)
            make.right.equalTo(-10)
            make.width.equalTo(140)
            make.height.equalTo(45)
        }
        
        closeButton.bk_addEventHandler({ (button) in
            //检查数据
            let check = Utils.isNullString(textField.text!)
            //关闭添加视图
            self.jcAlert?.dismissWithCompletion({})
            
            if !check.0 {
                Utils.sharedInstance.showLoadingView("数据保存中")
                if type == 1 {
                    //添加数据
                    self.dataManager(1, data: data, eventName: check.1, complete: {
                        (errorString,eventObject) in
                        //取消加载视图
                        Utils.sharedInstance.hud.hideAnimated(true)
                        if errorString != nil{
                            Utils.showHUDWithMessage(errorString!, time: 2, block: {})
                        }else{
                            //更新数据源
                            self.dataSource?.append(eventObject as! TimeLineEvent)
                            self.configDataSource(false)
                            //如果分组是展开的，则更新一条数据
                            if self.openOrCloseArray[indexPath.section] == "1"{
                                self.eventTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                            }
                            Utils.showHUDWithMessage("保存成功", time: 1, block: {})
                        }
                    })
                }else if type == 2{
                    //修改数据
                    self.dataManager(2, data: data, eventName: check.1, complete: { (errorString,eventObject) in
                        //取消加载视图
                        Utils.sharedInstance.hud.hideAnimated(true)
                        if errorString != nil{
                            Utils.showHUDWithMessage(errorString!, time: 2, block: {})
                        }else{
                            //更新数据源
                            let newEvent = eventObject as! TimeLineEvent
                            for i in 0..<self.dataSource!.count{
                                //替换数据源中的旧数据
                                if self.dataSource![i].objectId == newEvent.objectId{
                                    self.dataSource![i] = newEvent
                                    break
                                }
                            }
                            self.configDataSource(true)
                            if headerIndex >= 0{
                                //更新头视图的标题
                                self.headerTitleArray[headerIndex].text = newEvent.eventName
                            }else{
                                //更新cell
                                self.eventTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Middle)
                            }
                            Utils.showHUDWithMessage("保存成功", time: 1, block: {})
                        }
                    })
                }
                
            }
        }, forControlEvents: .TouchUpInside)
        
        self.jcAlert = JCAlertView.init(customView: alertView, dismissWhenTouchedBackground: true)
        self.jcAlert?.show()
    }
    
    //MARK:数据操作  （添加、删除、修改）
    //参数说明：1、操作类型（1表示添加，2表示修改，3表示删除） 2、添加时，表示父目录，修改和删除时，表示本身  3、添加时的项目名称，修改和删除时可用""表示
    func dataManager(type:Int,data:TimeLineEvent,eventName:String,complete:dataManagerClosure){
        switch type {
        case 1:
            //添加一条消费项目
            let object = AVObject.init(className: "TimeLineEvent")
            object.setObject(eventName, forKey: "eventName")
            object.setObject("", forKey: "userId")
            object.setObject(AVObject.init(className: "TimeLineEvent", objectId: data.objectId), forKey: "parentId")
            //保存数据并回调
            object.saveInBackgroundWithBlock({ (flag, error) in
                if error == nil{
                    //保存成功后，获取当前保存的数据
                    let query = AVQuery.init(className: "TimeLineEvent")
                    query.getObjectInBackgroundWithId(object.objectForKey("objectId") as! String, block: { (savingObject, queryError) in
                        if queryError == nil{
                            complete(nil,TimeLineEvent.initEventWithAVObject(savingObject))
                        }else{
                            complete(queryError.localizedDescription,nil)
                        }
                    })
                }else{
                    complete(error.localizedDescription,nil)
                }
            })
            break
        case 2:
            //修改数据并回调
            let object = AVObject.init(className: "TimeLineEvent", objectId: data.objectId)
            object.setObject(eventName, forKey: "eventName")
            object.saveInBackgroundWithBlock({ (flag, error) in
                if error == nil{
                    //保存成功后，获取当前数据
                    let query = AVQuery.init(className: "TimeLineEvent")
                    query.getObjectInBackgroundWithId(data.objectId, block: { (avObject, queryError) in
                        if queryError == nil{
                            complete(nil,TimeLineEvent.initEventWithAVObject(avObject))
                        }else{
                            complete(queryError.localizedDescription,nil)
                        }
                    })
                }else{
                    complete(error.localizedDescription,nil)
                }
            })
            
        default:
            break
        }
    }
    
    //MARK:cell操作菜单的代理方法
    //删除cell的代理方法
    func deleteCellAction(event:TimeLineEvent,cell:TimeLineEventCell,clickBtn:UIButton) {
        //删除提示
        let msg = "确认删除 " + event.eventName + " 消费项目吗？"
        let msgHeight = Utils.heightForText(msg, size: CGSizeMake(300, CGFloat.max), font: UIFont.boldSystemFontOfSize(17))
        
        //视图总高度 = 标题顶部15 + 标题高度20 + 提示信息顶部15 + 提示信息高度 + 按钮顶部15 + 按钮高度45 + 顶部空白15
        let alertViewHeight:CGFloat = 15 + 20 + 15 + msgHeight + 15 + 45 + 15
        //删除视图
        let alertView = UIView.init(frame: CGRectMake(0, 0, 320, alertViewHeight))
        alertView.backgroundColor = Utils.bgColor
        //标题
        let titleView = UILabel()
        titleView.text = "删除提示"
        titleView.textAlignment = .Center
        titleView.font = UIFont.boldSystemFontOfSize(17)
        titleView.textColor = UIColor.blackColor()
        alertView.addSubview(titleView)
        titleView.snp_makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
        }
        //提示信息
        let msgLable = UILabel()
        msgLable.textColor = UIColor.blackColor()
        msgLable.text = msg
        alertView.addSubview(msgLable)
        msgLable.numberOfLines = 0
        msgLable.snp_makeConstraints { (make) in
            make.top.equalTo(titleView.snp_bottom).offset(15)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        //取消按钮
        let cancelButton = UIButton()
        cancelButton.setTitle("取消", forState: .Normal)
        cancelButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        cancelButton.backgroundColor = UIColor.whiteColor()
        cancelButton.bk_addEventHandler({ (btn) in
            //关闭弹窗
            self.jcAlert?.dismissWithCompletion({})
            }, forControlEvents: .TouchUpInside)
        alertView.addSubview(cancelButton)
        cancelButton.snp_makeConstraints { (make) in
            make.top.equalTo(msgLable.snp_bottom).offset(15)
            make.left.equalTo(10)
            make.width.equalTo(140)
            make.height.equalTo(45)
        }
        
        //确定按钮
        let closeButton = UIButton()
        closeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        closeButton.setTitle("确定", forState: .Normal)
        closeButton.backgroundColor = Utils.allTintColor
        alertView.addSubview(closeButton)
        closeButton.snp_makeConstraints { (make) in
            make.top.equalTo(msgLable.snp_bottom).offset(15)
            make.right.equalTo(-10)
            make.width.equalTo(140)
            make.height.equalTo(45)
        }
        closeButton.bk_addEventHandler({ (button) in
            //关闭弹窗
            self.jcAlert?.dismissWithCompletion(nil)
            //通过cell，动态的获取indexPath
            let indexPath = self.eventTableView.indexPathForCell(cell)
            //加载指示器
            Utils.sharedInstance.showLoadingView("数据删除中")
            let query = AVObject.init(className: "TimeLineEvent", objectId: event.objectId)
            query.deleteInBackgroundWithBlock { (flag, error) in
                Utils.sharedInstance.hud.hideAnimated(true)
                if error == nil{
                    //删除数据源中的数据
                    for i in 0..<(self.dataSource?.count)!{
                        if self.dataSource![i].objectId == event.objectId{
                            self.dataSource?.removeAtIndex(i)
                            break
                        }
                    }
                    //true表示不排序
                    self.configDataSource(true)
                    Utils.showHUDWithMessage("删除成功", time: 1, block: {
                        self.eventTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                    })
                }else{
                    Utils.showHUDWithMessage(error.localizedDescription, time: 2, block: {})
                }
            }
        }, forControlEvents: .TouchUpInside)
        //防止按钮连续点击
        clickBtn.enabled = true
        //弹出视图
        self.jcAlert = JCAlertView.init(customView: alertView, dismissWhenTouchedBackground: true)
        self.jcAlert?.show()
    }
    
    //修改cell的代理方法
    func updateCellAction(event:TimeLineEvent,cell:TimeLineEventCell,clickBtn:UIButton) {
        //通过cell，动态的获取indexPath
        let indexPath = self.eventTableView.indexPathForCell(cell)
        print("当前点击的indexPath = \(indexPath)")
        //调用修改方法
        self.operationPopPresent(2, data: event, indexPath: indexPath!, headerIndex: -1)
        //防止按钮连续点击
        clickBtn.enabled = true
    }
    
    //MARK:header删除一个分组
    func deleteGroup(event:TimeLineEvent){
        //弹出视图
        //删除提示
        let msg = "确认删除 " + event.eventName + " 消费项目及所有子项目吗？"
        let msgHeight = Utils.heightForText(msg, size: CGSizeMake(300, CGFloat.max), font: UIFont.boldSystemFontOfSize(17))
        
        //视图总高度 = 标题顶部15 + 标题高度20 + 提示信息顶部15 + 提示信息高度 + 按钮顶部15 + 按钮高度45 + 顶部空白15
        let alertViewHeight:CGFloat = 15 + 20 + 15 + msgHeight + 15 + 45 + 15
        //删除视图
        let alertView = UIView.init(frame: CGRectMake(0, 0, 320, alertViewHeight))
        alertView.backgroundColor = Utils.bgColor
        //标题
        let titleView = UILabel()
        titleView.text = "删除提示"
        titleView.textAlignment = .Center
        titleView.font = UIFont.boldSystemFontOfSize(17)
        titleView.textColor = UIColor.blackColor()
        alertView.addSubview(titleView)
        titleView.snp_makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
        }
        //提示信息
        let msgLable = UILabel()
        msgLable.textColor = UIColor.blackColor()
        msgLable.text = msg
        alertView.addSubview(msgLable)
        msgLable.numberOfLines = 0
        msgLable.snp_makeConstraints { (make) in
            make.top.equalTo(titleView.snp_bottom).offset(15)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        //取消按钮
        let cancelButton = UIButton()
        cancelButton.setTitle("取消", forState: .Normal)
        cancelButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        cancelButton.backgroundColor = UIColor.whiteColor()
        cancelButton.bk_addEventHandler({ (btn) in
            //关闭弹窗
            self.jcAlert?.dismissWithCompletion({})
            }, forControlEvents: .TouchUpInside)
        alertView.addSubview(cancelButton)
        cancelButton.snp_makeConstraints { (make) in
            make.top.equalTo(msgLable.snp_bottom).offset(15)
            make.left.equalTo(10)
            make.width.equalTo(140)
            make.height.equalTo(45)
        }
        
        //确定按钮
        let closeButton = UIButton()
        closeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        closeButton.setTitle("确定", forState: .Normal)
        closeButton.backgroundColor = Utils.allTintColor
        alertView.addSubview(closeButton)
        closeButton.snp_makeConstraints { (make) in
            make.top.equalTo(msgLable.snp_bottom).offset(15)
            make.right.equalTo(-10)
            make.width.equalTo(140)
            make.height.equalTo(45)
        }
        closeButton.bk_addEventHandler({ (button) in
            //确定按钮处理事件
            self.jcAlert?.dismissWithCompletion({})
            //加载指示器
            Utils.sharedInstance.showLoadingView("数据删除中")
            //获取子项目前，先配置一下数据源
            self.configDataSource(false)
            //先删除所有子项目
            let childArray = self.childEvent[event.objectId]
            if childArray != nil && childArray?.count>0{
                let modelArray = childArray as! [TimeLineEvent]
                //由于SB云存储技术不提供批量删除，无奈之下的下策，循环删除
                //总数量
                let totalCount = 0
                for i in 0..<modelArray.count{
                    //拼凑删除的条件语句
                   var cql = "delete from TimeLineEvent where objectId='" + modelArray[i].objectId + "'"
                    AVQuery.doCloudQueryInBackgroundWithCQL(cql, callback: { (result, error) in
                        
                    })
                }
//                print("删除子项目的cql语句为  = \(cql)")
//                //开始删除子项目
//                AVQuery.doCloudQueryInBackgroundWithCQL(cql, callback: { (result, error) in
//                    if error == nil{
//                        //开始删除父目录
//                        self.deleteParentEvent(event)
//                    }else{
//                        print("删除子项目时，出现的错误  \(error.localizedDescription)")
//                        Utils.sharedInstance.hud.hideAnimated(true)
//                        Utils.showHUDWithMessage(error.localizedDescription, time: 2, block: {})
//                    }
//                })
            }else{
                //没有子项目，直接删除父目录
                self.deleteParentEvent(event)
            }
//            
//            let cql = "delete from TimeLineEvent where parentId='" + event.objectId + "'"
//            //删除当前项目下的所有子类
//            AVQuery.doCloudQueryInBackgroundWithCQL(cql, callback: { (result, error) in
//                if error == nil{
//                    //删除当前父目录
//                    let cql = "delete from TimeLineEvent where objectId='" + event.objectId + "'"
//                    AVQuery.doCloudQueryInBackgroundWithCQL(cql, callback: { (result, error) in
//                        //取消加载视图
//                        Utils.sharedInstance.hud.hideAnimated(true)
//                        if error == nil{
//                            Utils.showHUDWithMessage("删除成功", time: 1, block: {})
//                            //更新视图
//                            for i in 0..<(self.dataSource?.count)!{
//                                //删除数据源中的父目录
//                                if self.dataSource![i].objectId == event.objectId{
//                                    self.dataSource?.removeAtIndex(i)
//                                    break
//                                }
//                            }
//                            //记录分组下标
//                            var groupIndex = -1
//                            for i in 0..<self.parentEvent.count{
//                                //从父目录的数组中查找当前删除父目录是哪个下标
//                                if self.parentEvent[i].objectId == event.objectId{
//                                    //删除开关属性数组
//                                    groupIndex = i
//                                    self.openOrCloseArray.removeAtIndex(i)
//                                    break
//                                }
//                            }
//                            //配置数据源
//                            self.configDataSource(false)
//                            //删除分组
//                            if groupIndex > 0{
//                                self.eventTableView.deleteSections(NSIndexSet.init(index: groupIndex), withRowAnimation: .Fade)
//                            }
//                            
//                        }else{
//                            Utils.showHUDWithMessage(error.localizedDescription, time: 2, block: {})
//                        }
//                    })
//                }else{
//                    Utils.sharedInstance.hud.hideAnimated(true)
//                    Utils.showHUDWithMessage(error.localizedDescription, time: 2, block: {})
//                }
//            })
//            
            
        }, forControlEvents: .TouchUpInside)
        
        self.jcAlert = JCAlertView.init(customView: alertView, dismissWhenTouchedBackground: true)
        self.jcAlert?.show()
    }
    
    //删除父目录
    func deleteParentEvent(event:TimeLineEvent){
        //开始删除父目录
        let cql = "delete from TimeLineEvent where objectId='" + event.objectId + "'"
        AVQuery.doCloudQueryInBackgroundWithCQL(cql, callback: { (result, error) in
            if error == nil{
                //记录分组下标
                var groupIndex = -1
                for i in 0..<self.parentEvent.count{
                    //从父目录的数组中查找当前删除父目录是哪个下标
                    if self.parentEvent[i].objectId == event.objectId{
                        //删除开关属性数组
                        groupIndex = i
                        self.openOrCloseArray.removeAtIndex(i)
                        break
                    }
                }
                print("删除的分组下标  \(groupIndex)")
                //重新获取数据源
                let query = AVQuery.init(className: "TimeLineEvent")
                //降序排列，把最新的显示在最前面
                query.orderByDescending("updatedAt")
                //查询userId为空的数据
                query.whereKey("userId", equalTo: "")
                query.findObjectsInBackgroundWithBlock({ (objects, error) in
                Utils.sharedInstance.hud.hideAnimated(true)
                Utils.showHUDWithMessage("删除成功", time: 1, block: {})
                    if error == nil{
                        if objects.count > 0{//print("数据长度== \(objs.count)")
                            self.dataSource = [TimeLineEvent]()
                            let avObj = objects as! [AVObject]
                            for obj in avObj{
                                self.dataSource?.append(TimeLineEvent.initEventWithAVObject(obj))
                            }
                            //配置数据源:将父目录和子目录分开
                            self.configDataSource(false)
                            //删除分组
                            if groupIndex >= 0{
                                self.eventTableView.deleteSections(NSIndexSet.init(index: groupIndex), withRowAnimation: .Fade)
                            }
                        }
                    }else{
                        Utils.sharedInstance.hud.hideAnimated(true)
                        Utils.showHUDWithMessage(error.localizedDescription, time: 2, block: {})
                    }
                })
                
            }else{
                Utils.sharedInstance.hud.hideAnimated(true)
                Utils.showHUDWithMessage(error.localizedDescription, time: 2, block: {})
            }
        })
    }
    
    //MARK:内存溢出方法
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
