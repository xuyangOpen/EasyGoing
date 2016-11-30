//
//  DataStatisticViewController.swift
//  EasyGoing
//
//  Created by King on 16/10/9.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import AVOSCloud


enum PanelSelectorMode {
    case YearMode
    case MonthMode
}

enum DataType {
    case ProjectType
    case MoneyType
}

//MARK:数据统计控制器视图
class DataStatisticViewController: UIViewController,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,PieChartDelegate,BarChartDelegate {

    //分段控制器
    let segmentView = UISegmentedControl.init(items: ["项目","金额"])
    //滑动视图
    let containerView = UIScrollView()
    //-->饼视图呈现视图
    let pieView = UIView()
    let pieChart = PieChartViewController()
    //创建一个分类的空字典，key表示消费项目  value表示数量
    var pieCategoryDictionary = Dictionary<String, Int>()
    //创建一个计算金额的字典 ，key表示消费项目  value表示消费金额
    var pieCostDictionary = Dictionary<String, CGFloat>()
    
    //-->柱形图呈现视图
    let barView = UIView()
    let barChart = BarChartController()
    //创建一个计算金额的字典 ，key表示月份  value表示消费金额
    var barCostDictionary = Dictionary<Int, CGFloat>()
    //标题label
    var barTitleLabel = UILabel()
    
    //饼状图数据源
    var dataSource = [TimeLineRecord]()
    //柱状图数据源
    var barDataSource = [TimeLineRecord]()
    //消费项目详情页面
    let detailVC = RecordDetailController()
    //年消费统计详情页面
    let yearDetailVC = RecordDetailController()
    //=============================================================
    //消费金额统计年份
    var dataMoneyYear = PDCalendarAttribute.year(NSDate())
    //当前统计类型  默认是消费类型
    var dataType = DataType.ProjectType{
        didSet{
            if self.dataType == .ProjectType {//消费项目统计
                if self.selectorMode == .YearMode {
                    self.configYearSelector()
                }else{
                    self.configMonthSelector()
                }
                if self.monthButton.superview == nil {//添加月份选择按钮
                    self.panelView.addSubview(self.monthButton)
                }
                if self.selectedMonth == "0" {//全年
                    self.informationLable.text = "当前选择：\(self.selectedYear)年"
                }else{//年月
                    self.informationLable.text = "当前选择：\(self.selectedYear)年\(self.selectedMonth)月"
                }
            }else {//消费金额年统计
                if self.selectorMode == .MonthMode {//如果是月份选择器，则换成年份选择器
                    self.configYearSelector()
                }
                if self.monthButton.superview != nil{//移除月份选择按钮
                    self.monthButton.removeFromSuperview()
                }
                self.informationLable.text = "当前选择：\(self.dataMoneyYear)年"
            }
        }
    }
    
    //底部按钮
    let triggerButton = UIButton()
    //底部面板
    let panelView = UIView()
    let panelHeight = Utils.scaleFloat(150)//顶部面板的高度
    let panelColor = Utils.colorWith(242, G: 242, B: 242) //面板背景颜色
    //是否显示底部面板
    var isShowPanel = false{
        didSet{
            if isShowPanel {
                UIView.animateWithDuration(animationDuration, animations: { 
                    self.triggerButton.transform = CGAffineTransformRotate(self.triggerButton.transform, CGFloat(M_PI))
                })
            }else{
                UIView.animateWithDuration(animationDuration, animations: { 
                    self.triggerButton.transform = CGAffineTransformIdentity
                })
            }
        }
    }
    let animationDuration = 0.4     //动画时间
    //选择年份的UICollectionView
    var yearCollectionView:UICollectionView?
    let flowLayout = UICollectionViewFlowLayout()
    var yearOrMonthArray = [String]()          //年份或者月份数组
    var selectorMode = PanelSelectorMode.YearMode     //选择器模式  默认是年份选择器
    //消费项目
    var selectedYear = String(PDCalendarAttribute.year(NSDate()))   //当前选中的年份
    var selectedMonth = String(PDCalendarAttribute.month(NSDate()))   //当前选中的月份
    //年统计
    var year = String(PDCalendarAttribute.year(NSDate()))
    
    //面板的年份和月份按钮以及开关动画的switch
    let informationLable = UILabel()
    let yearButton = UIButton()
    let monthButton = UIButton()
    let switchLabel = UILabel()
    let animationSwitch = UISwitch()
    let animationKey = "tl_sta_ani"
    
    //MARK:ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置背景颜色
        self.view.backgroundColor = UIColor.init(red: 230/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1.0)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //标题栏
        self.setTitleView()
        self.configScrollView()
        //配置视图
        self.configMainView()
        //底部视图
        self.configbottomView()
        //获取网络数据
        self.getPieNetData(NSDate(), isByMonth: true)
        
        
    }

    //MARK:设置标题视图
    func setTitleView(){
        self.segmentView.selectedSegmentIndex = 0
        self.segmentView.frame = CGRectMake(0, 0, CGFloat(Utils.scale(150)), CGFloat(Utils.scale(30)))
        self.segmentView.addTarget(self, action: #selector(changeView(_:)), forControlEvents: .ValueChanged)
        self.navigationItem.titleView = self.segmentView
    }
    
    //MARK:请求饼状图网络数据，参数1：要查询的日期，参数2：true表示按月份查询，false表示按年份查询
    func getPieNetData(queryDate: NSDate, isByMonth: Bool){
        //网络加载数据
        Utils.sharedInstance.showLoadingViewOnView("数据加载中", parentView: self.view)
        //查询数据
        let query = AVQuery.init(className: "TimeLineRecord")
        //级联查询子目录
        query.includeKey("eventObject")
        //二级级联查询，查询子目录的父目录
        query.includeKey("eventObject.parentId")
        query.whereKey("userId", equalTo: AVUser.currentUser()!.objectId!)
        //查询该用户当前月份的数据，使用包含查询，查询年月相同的数据进行统计
        if isByMonth {//精确到月份
            query.whereKey("recordTime", containsString: String.init(format: "%d-%02d", PDCalendarAttribute.year(queryDate),PDCalendarAttribute.month(queryDate)))
            //每次请求数据时，改变饼状图中心的日期
            self.pieChart.centerDateString = String.init(format: "%d年%02d月", PDCalendarAttribute.year(queryDate),PDCalendarAttribute.month(queryDate))
        }else{//精确到年份
            query.whereKey("recordTime", containsString: String.init(format: "%d", PDCalendarAttribute.year(queryDate)))
            //每次请求数据时，改变饼状图中心的日期
            self.pieChart.centerDateString = String.init(format: "%d年", PDCalendarAttribute.year(queryDate))
        }
        
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            Utils.sharedInstance.hideLoadingView()
            if error == nil{
                self.dataSource.removeAll()
                if objects!.count > 0{
                    for obj in objects!{
                        self.dataSource.append(TimeLineRecord.initRecordWithAVObject(obj as! AVObject))//添加数据
                    }
                }
//                else{
//                    Utils.showHUDWithMessage("暂无数据", time: 2, block: {})
//                }
                //如果数据长度为0，则提示无数据
                if self.dataSource.count == 0{
                    self.pieChart.centerDateString = "\(self.pieChart.centerDateString)无数据"
                }
                //配置数据
                self.configPieChartData()
            }else{
                Utils.showHUDWithMessage(error!.localizedDescription, time: 2, block: {})
            }
        }
    }
    
    //MARK:获取柱状图网络数据
    func getBarNetData(queryDate: NSDate){
        //网络加载数据
        Utils.sharedInstance.showLoadingViewOnView("数据加载中", parentView: self.view)
        //查询数据
        let query = AVQuery.init(className: "TimeLineRecord")
        //级联查询子目录
        query.includeKey("eventObject")
        //二级级联查询，查询子目录的父目录
        query.includeKey("eventObject.parentId")
        query.whereKey("userId", equalTo: AVUser.currentUser()!.objectId!)
        query.whereKey("recordTime", containsString: String.init(format: "%d", PDCalendarAttribute.year(queryDate)))
        //设置显示标题
        self.barTitleLabel.text = "\(PDCalendarAttribute.year(queryDate))年"
        //开始查询
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            Utils.sharedInstance.hideLoadingView()
            if error == nil{
                self.barDataSource.removeAll()
                if objects!.count > 0{
                    for obj in objects!{
                        self.barDataSource.append(TimeLineRecord.initRecordWithAVObject(obj as! AVObject))//添加数据
                    }
                }
                //如果数据长度为0，则提示无数据
                if self.barDataSource.count == 0{
                    self.barTitleLabel.text = "\(self.barTitleLabel.text!)无数据"
                }
                //配置数据
                self.configBarChartData(PDCalendarAttribute.year(queryDate))
            }else{
                Utils.showHUDWithMessage(error!.localizedDescription, time: 2, block: {})
            }
        }
    }
    
    //MARK:设置滑动视图
    func configScrollView(){
        //配置滑动视图
        self.containerView.contentOffset = CGPointMake(0, 0)
        self.containerView.contentSize = CGSizeMake(Utils.screenWidth * 2, 0)
        self.containerView.showsHorizontalScrollIndicator = true
        self.containerView.bounces = false
        self.containerView.pagingEnabled = true
        self.containerView.scrollEnabled = false
        self.containerView.delegate = self
        self.containerView.tag = 1024
        self.containerView.backgroundColor = UIColor.init(red: 230/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1.0)
        self.containerView.autoresizingMask = .FlexibleHeight
        self.view.addSubview(self.containerView)
        self.containerView.frame = self.view.bounds
    }
    
    //MARK:配置视图
    func configMainView(){
        //饼视图设置
        self.pieView.frame = CGRectMake(0, 0, Utils.screenWidth, Utils.screenHeight)
        self.pieView.backgroundColor = UIColor.init(red: 230/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1.0)
        self.containerView.addSubview(self.pieView)
        
        //饼状图
        self.pieChart.categoryDictionary = self.pieCategoryDictionary
        self.pieChart.costDictionary = self.pieCostDictionary
        self.pieChart.centerDateString = "查询中..."
        self.pieChart.view.frame = CGRectMake(0, Utils.scaleFloat(100), Utils.screenWidth, Utils.screenWidth)
        self.pieChart.loadPieChartView()
        self.pieView.addSubview(self.pieChart.view)
        
        //柱形图设置
        self.barView.frame = CGRectMake(Utils.screenWidth, 0, Utils.screenWidth, Utils.screenHeight)
        self.barView.backgroundColor = UIColor.init(red: 230/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1.0)
        self.containerView.addSubview(self.barView)
        //柱形图的标题label
        self.barChart.view.frame = CGRectMake(0, Utils.scaleFloat(100), Utils.screenWidth, Utils.screenWidth)
        self.barChart.delegate = self
        self.barChart.view.addSubview(self.barTitleLabel)
        self.barTitleLabel.font = UIFont.systemFontOfSize(16)
        self.barTitleLabel.text = "\(PDCalendarAttribute.year(NSDate()))年"
        self.barTitleLabel.textAlignment = .Center
        self.barTitleLabel.textColor = UIColor.orangeColor()
        self.barTitleLabel.frame = CGRectMake(0, Utils.screenWidth + 5, Utils.screenWidth, 20)
    }
    
    //MARK:配置饼状图数据
    func configPieChartData(){
        self.pieCategoryDictionary.removeAll()
        self.pieCostDictionary.removeAll()
        for record in self.dataSource{
            //判断分类字典是否包含当前parentId
            if !self.pieCategoryDictionary.keys.contains(record.parentName){
                //统计消费项目数量
                self.pieCategoryDictionary[record.parentName] = 1
                //统计消费项目金额
                self.pieCostDictionary[record.parentName] = record.recordCost
            }else{
                self.pieCategoryDictionary[record.parentName] = self.pieCategoryDictionary[record.parentName]! + 1
                self.pieCostDictionary[record.parentName] = self.pieCostDictionary[record.parentName]! + record.recordCost
            }
        }
        //配置完数据之后，更新数据
        self.pieChart.categoryDictionary = self.pieCategoryDictionary
        self.pieChart.categoryDictionary = self.pieCategoryDictionary
        self.pieChart.costDictionary = self.pieCostDictionary
        self.pieChart.animation = (AVUser.currentUser()?.objectForKey(animationKey) as! String) == "1" ? true : false
        self.pieChart.delegate = self
        self.pieChart.updateData()
    }
    
    //MARK:piechart代理方法
    func showEventAtIndex(index: NSNumber!) {
        let keys = Array(self.pieCategoryDictionary.keys)
//        print("选中消费项目是 = \(keys[index.integerValue])")
        var showEventArray = [TimeLineRecord]()
        for record in self.dataSource {
            if record.recordEvent.containsString(keys[index.integerValue]) {
                showEventArray.append(record)
            }
            //默认将分组全部关闭
            record.isExpand = false
        }
        //将piechart位置移动，动画时间和detailVC的动画时间一致
        UIView.animateWithDuration(detailVC.animationDuration, animations: {
            self.pieChart.changeFrameSize(CGRectMake((Utils.screenWidth-(Utils.screenHeight-Utils.scaleFloat(400)))/2.0, 0, Utils.screenHeight-Utils.scaleFloat(400), Utils.screenHeight-Utils.scaleFloat(400)), animationDuration: CGFloat(self.detailVC.animationDuration))
        })
        //详情页面
        let window = UIApplication.sharedApplication().keyWindow
        detailVC.view.frame = window!.bounds
        detailVC.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
        detailVC.detailType = RecordType.EventType
        detailVC.eventName = keys[index.integerValue]
        detailVC.detailDataSource = showEventArray
        detailVC.detailTableView.contentOffset = CGPointZero
        detailVC.detailTableView.reloadData()
        detailVC.closeDetailVC = { [weak self] () in
            //回调方法，将pieChart复原
            UIView.animateWithDuration(self!.detailVC.animationDuration, animations: {
                self?.pieChart.changeFrameSize(self!.pieChart.view.bounds, animationDuration: CGFloat(self!.detailVC.animationDuration))
            })
        }
        window!.addSubview(detailVC.view)
    }
    
    //MARK:barchart代理方法
    func showMonthAtIndex(index: NSNumber!) {
        var tempArray = [TimeLineRecord]()
        let timeString = String.init(format: "%@-%02d", year,index.integerValue+1)
        for record in self.barDataSource {
            if record.recordTime.containsString(timeString) {
                tempArray.append(record)
            }
            record.isExpand = false
        }
        if tempArray.count > 0 {//数据长度大于1，才会显示详情列表
            //barchart位置移动
            UIView.animateWithDuration(yearDetailVC.animationDuration, animations: { 
                self.barChart.changeFrameSize(CGRectMake((Utils.screenWidth-(Utils.screenHeight-Utils.scaleFloat(400)-25))/2.0, 0, Utils.screenHeight-Utils.scaleFloat(400)-25, Utils.screenHeight-Utils.scaleFloat(400)-25), animationDuration: CGFloat(self.detailVC.animationDuration))
                self.barTitleLabel.frame = CGRectMake(0, Utils.screenHeight-Utils.scaleFloat(400)-20, Utils.screenWidth, 20)
            })
            //详情页面
            let window = UIApplication.sharedApplication().keyWindow
            yearDetailVC.view.frame = window!.bounds
            yearDetailVC.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
            yearDetailVC.detailType = RecordType.YearType
            yearDetailVC.yearTime = timeString
            yearDetailVC.detailDataSource = tempArray
            yearDetailVC.detailTableView.contentOffset = CGPointZero
            yearDetailVC.detailTableView.reloadData()
            yearDetailVC.closeDetailVC = { [weak self] () in
                //回调方法，将barchart复原
                UIView.animateWithDuration(self!.detailVC.animationDuration, animations: {
                    self?.barChart.changeFrameSize(self!.pieChart.view.bounds, animationDuration: CGFloat(self!.detailVC.animationDuration))
                    self?.barTitleLabel.frame = CGRectMake(0, Utils.screenWidth + 5, Utils.screenWidth, 20)
                })
            }
            window!.addSubview(yearDetailVC.view)
        }
    }
    
    //MARK:配置柱状图数据
    func configBarChartData(year: Int){
        //配置之前，先移除数据
        self.barCostDictionary.removeAll()
        if self.barDataSource.count > 0 {
            //先给数组按时间排序，按升序排
            self.barDataSource.sortInPlace({ (recordA, recordB) -> Bool in
                let result = recordA.recordTime.compare(recordB.recordTime)
                if result == NSComparisonResult.OrderedDescending{
                    return false
                }else{
                    return true
                }
            })
            var timeString = ""
            for i in 0..<12{
                self.barCostDictionary[i] = 0.0
                timeString = String.init(format: "%d-%02d", year,i+1)
                for record in self.barDataSource{
                    if record.recordTime.containsString(timeString) {//当月的数据
                        //如果字典中有当月数据，则将当月金额+当前金额
                        self.barCostDictionary[i] = self.barCostDictionary[i]! + record.recordCost
                    }
                }
            }
            //找出Y轴最大值
            var maxY:CGFloat = 0
            for i in 0..<12 {
                let value = self.barCostDictionary[i]
                if value > maxY {
                    maxY = value!
                }
            }
            self.barChart.maxY = maxY
        }
        self.barChart.costDictionary = self.barCostDictionary
        self.barChart.animation = (AVUser.currentUser()?.objectForKey(animationKey) as! String) == "1" ? true : false
        self.barChart.updateData()
    }
    
    //MARK:
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.tag == 1024 {//1024的tag值代表的是整个视图的scrollView
            if scrollView.contentOffset.x == 0 {
                self.dataType = .ProjectType    //统计类型
                self.pieChart.updateData()
            }else if scrollView.contentOffset.x == Utils.screenWidth{
                self.dataType = .MoneyType      //统计类型
                if self.barView.subviews.count == 0 {
                    //第一次加载页面时，先获取网络数据
                    self.getBarNetData(NSDate())
                    self.barChart.loadBarChartView()
                    self.barView.addSubview(self.barChart.view)
                }else{
                    self.barChart.updateData()
                }
            }
        }
    }
    
    //MARK:顶部segment点击时，改变视图
    func changeView(sender:UISegmentedControl){
        if self.isShowPanel {
            self.showYearMenu()
        }
        self.containerView.setContentOffset(CGPointMake(CGFloat(sender.selectedSegmentIndex) * Utils.screenWidth, 0), animated: true)
    }
    
    
    //MARK:顶部视图的设置
    func configbottomView(){
        //触发按钮
        self.triggerButton.frame = CGRectMake((Utils.screenWidth-30)/2.0, Utils.screenHeight-30, 30, 30)
        self.triggerButton.setImage(UIImage.init(named: "upArrow"), forState: .Normal)
        self.view.addSubview(self.triggerButton)
        self.triggerButton.addTarget(self, action: #selector(showYearMenu), forControlEvents: .TouchUpInside)
        //面板
        self.panelView.frame = CGRectMake(0, Utils.screenHeight, Utils.screenWidth, panelHeight)
        self.panelView.backgroundColor = panelColor
        self.view.addSubview(self.panelView)
        
        //选择信息显示：
        self.informationLable.text = String.init(format: "当前选择：%d年%02d月",PDCalendarAttribute.year(NSDate()), PDCalendarAttribute.month(NSDate()))
        self.informationLable.font = UIFont.systemFontOfSize(16)
        self.informationLable.textColor = UIColor.blackColor()
        self.informationLable.frame = CGRectMake(Utils.scaleFloat(15), Utils.scaleFloat(15), Utils.screenWidth - 30, Utils.scaleFloat(20))
        self.panelView.addSubview(self.informationLable)
        //年份按钮
        self.yearButton.setTitle("年份", forState: .Normal)
        self.yearButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.yearButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        self.yearButton.backgroundColor = UIColor.whiteColor()
        self.yearButton.frame = CGRectMake(Utils.scaleFloat(20), Utils.scaleFloat(45), Utils.scaleFloat(80), Utils.scaleFloat(40))
        self.yearButton.tag = 1
        self.yearButton.addTarget(self, action: #selector(yearOrMonthClick(_:)), forControlEvents: .TouchUpInside)
        self.panelView.addSubview(self.yearButton)
        //月份按钮
        self.monthButton.setTitle("月份", forState: .Normal)
        self.monthButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.monthButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        self.monthButton.backgroundColor = panelColor
        self.monthButton.frame = CGRectMake(CGRectGetMaxX(self.yearButton.frame), CGRectGetMinY(self.yearButton.frame), Utils.scaleFloat(80), Utils.scaleFloat(40))
        self.monthButton.tag = 2
        self.monthButton.addTarget(self, action: #selector(yearOrMonthClick(_:)), forControlEvents: .TouchUpInside)
        self.panelView.addSubview(self.monthButton)
        //动画开关
        self.animationSwitch.frame = CGRectMake(Utils.screenWidth-Utils.scaleFloat(80), CGRectGetMinY(self.yearButton.frame), Utils.scaleFloat(100), Utils.scaleFloat(40))
        self.animationSwitch.on = (AVUser.currentUser()?.objectForKey(animationKey) as! String) == "1" ? true : false
        self.animationSwitch.addTarget(self, action: #selector(animationSwitch(_:)), forControlEvents: .ValueChanged)
        self.panelView.addSubview(self.animationSwitch)
        
        self.switchLabel.text = "动画开关"
        self.switchLabel.font = UIFont.systemFontOfSize(16)
        self.switchLabel.textColor = UIColor.blackColor()
        let switchLabelLength = Utils.widthForText("动画开关", size: CGSizeMake(Utils.screenWidth, 20), font: UIFont.systemFontOfSize(16))
        self.switchLabel.frame = CGRectMake(CGRectGetMinX(self.animationSwitch.frame) - switchLabelLength - 10, CGRectGetMinY(self.yearButton.frame), switchLabelLength, 20)
        self.switchLabel.center.y = self.animationSwitch.center.y
        self.panelView.addSubview(self.switchLabel)
        
        //年份或者月份选择器  默认是年份
        flowLayout.itemSize = CGSizeMake(Utils.screenWidth/5.0, 50)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .Horizontal
        
        self.yearCollectionView = UICollectionView.init(frame: CGRectMake(0, CGRectGetMaxY(self.yearButton.frame), Utils.screenWidth, Utils.scaleFloat(150) - CGRectGetMaxY(self.yearButton.frame)), collectionViewLayout: flowLayout)
        self.yearCollectionView?.delegate = self
        self.yearCollectionView?.dataSource = self
        self.yearCollectionView?.backgroundColor = UIColor.whiteColor()
        self.yearCollectionView?.pagingEnabled = true
        self.yearCollectionView?.showsHorizontalScrollIndicator = false
        self.panelView.addSubview(self.yearCollectionView!)
        //注册cell和head
        self.yearCollectionView?.registerClass(YearCollectionCell.self, forCellWithReuseIdentifier: "yearCell")
    
        //年份数据
        for i in 1900...2100 {
            self.yearOrMonthArray.append("\(i)")
        }
        //滑动到当前年份
        let offsetX = (PDCalendarAttribute.year(NSDate()) - 1900)/5
        self.yearCollectionView?.contentOffset = CGPointMake( CGFloat(offsetX) * Utils.screenWidth, 0)
    }
    
    //MARK:弹出底部视图
    func showYearMenu(){
        self.isShowPanel = !self.isShowPanel
        //如果是展开，则滑动到当前年份
        UIView.animateWithDuration(animationDuration) {
            //面板位置
            let panelOriginY = self.isShowPanel ? (Utils.screenHeight-self.panelHeight) : Utils.screenHeight
            self.panelView.frame = CGRectMake(0, panelOriginY, Utils.screenWidth, self.panelHeight)
            //按钮位置
            let btnOriginY = self.isShowPanel ?  Utils.screenHeight-(self.panelHeight + 30) : Utils.screenHeight-30
            let btnOriginX = self.isShowPanel ? Utils.screenWidth-30 : (Utils.screenWidth-30)/2.0
            self.triggerButton.frame = CGRectMake(btnOriginX, btnOriginY, 30, 30)
        }
    }
    
    //MARK:UICollectionView代理方法
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.yearOrMonthArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("yearCell", forIndexPath: indexPath) as! YearCollectionCell
    
        cell.yearLabel.text = "\(yearOrMonthArray[indexPath.item])"
//        if self.selectorMode == .YearMode {//年份模式
//            if yearOrMonthArray[indexPath.item] == self.selectedYear {
//                cell.isCurrentTime = true
//            }else{
//                cell.isCurrentTime = false
//            }
//        }else {//月份模式
//            if yearOrMonthArray[indexPath.item] == self.selectedMonth {
//                cell.isCurrentTime = true
//            }else{
//                cell.isCurrentTime = false
//            }
//        }
        cell.isCurrentTime = false
        cell.setAttribute()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.dataType == .ProjectType {//消费项目统计
            if self.selectorMode == .YearMode{//年份模式
                self.selectorMode = .MonthMode//改变模式
                //选中年份
                self.selectedYear = self.yearOrMonthArray[indexPath.item]
                //月份选择器配置
                self.configMonthSelector()
            }else{//月份模式
                self.chooseDateComplete(indexPath.item)
            }
        }else{//消费金额统计
            let fmt = NSDateFormatter()
            fmt.dateFormat = "yyyy-MM-dd"
            let queryDate = String.init(format: "%@-01-01", self.yearOrMonthArray[indexPath.item])
            //当前选中年份
            year = self.yearOrMonthArray[indexPath.item]
            self.getBarNetData(fmt.dateFromString(queryDate)!)
        }
    }
    
    //MARK:日期选择完毕
    func chooseDateComplete(index: Int){
        var isByMonth = true            //是否按月份查询
        var queryDateString = ""        //字符时间
        //当前选择月份
        self.selectedMonth = "\(index)"
        if index > 0 {//查询某月
            queryDateString = String.init(format: "%@-%02d-01", selectedYear,index)
            //当前选择label
            self.informationLable.text = String.init(format: "当前选择：%@年%02d月",selectedYear, index)
        }else{//查询全年
            isByMonth = false
            queryDateString = String.init(format: "%@-01-01", selectedYear)
            //当前选择label
            self.informationLable.text = String.init(format: "当前选择：%@年",selectedYear)
        }
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        //数据查询
        self.getPieNetData(fmt.dateFromString(queryDateString)!, isByMonth: isByMonth)
    }
    
    //MARK:年份或者月份按钮点击
    func yearOrMonthClick(btn: UIButton){
        if btn.tag == 1 {//年份按钮点击
            if self.selectorMode == .MonthMode {
                //当前模式为月份选择器时，点击才有作用
                self.selectorMode = .YearMode
                //改变为年份选择器
                self.configYearSelector()
            }
        }else if btn.tag == 2{//月份按钮点击
            if self.selectorMode == .YearMode {
                //当前模式为年份选择器时，点击才有作用
                //按钮样式
                self.yearButton.backgroundColor = self.panelColor
                self.monthButton.backgroundColor = UIColor.whiteColor()
                self.collectionView(self.yearCollectionView!, didSelectItemAtIndexPath: NSIndexPath.init(forRow: PDCalendarAttribute.year(NSDate())-1900, inSection: 0))
            }
        }
    }
    
    //MARK:switch动画开关
    func animationSwitch(sender: UISwitch){
        self.pieChart.animation = sender.on
        self.barChart.animation = sender.on
        let animationString = sender.on ? "1" : "0"
        //设置全局属性
        AVUser.currentUser()?.setObject(animationString, forKey: animationKey)
        AVUser.currentUser()?.saveInBackground()
    }
    
    //MARK:年份选择器配置
    func configYearSelector(){
        //按钮样式
        self.yearButton.backgroundColor = UIColor.whiteColor()
        self.monthButton.backgroundColor = self.panelColor
        self.yearOrMonthArray.removeAll()
        //年份数据
        for i in 1900...2100 {
            self.yearOrMonthArray.append("\(i)")
        }
        self.yearCollectionView?.reloadData()
        //滑动到当前年份
        let offsetX = (PDCalendarAttribute.year(NSDate()) - 1900)/5
        self.yearCollectionView?.contentOffset = CGPointMake( CGFloat(offsetX) * Utils.screenWidth, 0)
    }
    
    //MARK:月份选择器配置
    func configMonthSelector(){
        //按钮样式
        self.yearButton.backgroundColor = self.panelColor
        self.monthButton.backgroundColor = UIColor.whiteColor()
        self.informationLable.text = "当前选择：\(self.selectedYear)年"
        self.yearOrMonthArray.removeAll()
        self.yearOrMonthArray.append("全年")
        for i in 0..<12{
            self.yearOrMonthArray.append("\(i+1)")
        }
        self.yearCollectionView!.reloadData()
        self.yearCollectionView!.contentOffset = CGPointZero
    }
    
    deinit{
        print("数据统计页面释放了")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
