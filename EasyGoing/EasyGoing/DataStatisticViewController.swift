//
//  DataStatisticViewController.swift
//  EasyGoing
//
//  Created by King on 16/10/9.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import AVOSCloud

//MARK:数据统计控制器视图
class DataStatisticViewController: UIViewController,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

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
    
    //=============================================================
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
    var yearArray = [Int]()         //年份数组
    let monthParentView = UIScrollView()    //月份选择按钮的父视图
    var selectedYear = PDCalendarAttribute.year(NSDate())   //当前选中的年份
    
    //面板的年份和月份按钮以及开关动画的switch
    let informationLable = UILabel()
    let yearButton = UIButton()
    let monthButton = UIButton()
    let switchLabel = UILabel()
    let animationSwitch = UISwitch()
    
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
                    self.barTitleLabel.text = "\(self.barTitleLabel.text)无数据"
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
        self.pieView.autoresizingMask = .FlexibleHeight
        self.containerView.addSubview(self.pieView)
        
        //饼状图
        self.pieChart.showFrame = CGRectMake(0, 0, Utils.screenWidth, Utils.screenWidth)
        self.pieChart.categoryDictionary = self.pieCategoryDictionary
        self.pieChart.costDictionary = self.pieCostDictionary
        self.pieChart.centerDateString = "查询中..."
        self.pieChart.loadPieChartView()
        self.pieView.addSubview(self.pieChart.view)
        
        //柱形图设置
        self.barView.frame = CGRectMake(Utils.screenWidth, 0, Utils.screenWidth, Utils.screenHeight)
        self.barView.backgroundColor = UIColor.init(red: 230/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1.0)
        self.containerView.addSubview(self.barView)
        //柱形图的标题label
        self.barChart.view.addSubview(self.barTitleLabel)
        self.barTitleLabel.font = UIFont.systemFontOfSize(16)
        self.barTitleLabel.text = "\(PDCalendarAttribute.year(NSDate()))年"
        self.barTitleLabel.textAlignment = .Center
        self.barTitleLabel.textColor = UIColor.orangeColor()
        self.barTitleLabel.frame = CGRectMake(0, 105 + Utils.screenWidth, Utils.screenWidth, 20)
    
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
        self.pieChart.costDictionary = self.pieCostDictionary
        self.pieChart.updateData()
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
            self.barChart.costDictionary = self.barCostDictionary
            self.barChart.updateData()
        }
    }
    
    //MARK:
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 {
            self.pieChart.updateData()
        }else if scrollView.contentOffset.x == Utils.screenWidth{
            if self.barView.subviews.count == 0 {
                self.barChart.showFrame = CGRectMake(Utils.screenWidth, 0, Utils.screenWidth, Utils.screenWidth)
                //第一次加载页面时，先获取网络数据
                self.getBarNetData(NSDate())
                self.barChart.loadBarChartView()
                self.barView.addSubview(self.barChart.view)
            }else{
                self.barChart.updateData()
            }
        }
    }
    
    //MARK:顶部segment点击时，改变视图
    func changeView(sender:UISegmentedControl){
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
        self.panelView.addSubview(self.yearButton)
        //月份按钮
        self.monthButton.setTitle("月份", forState: .Normal)
        self.monthButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.monthButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        self.monthButton.backgroundColor = panelColor
        self.monthButton.frame = CGRectMake(CGRectGetMaxX(self.yearButton.frame), CGRectGetMinY(self.yearButton.frame), Utils.scaleFloat(80), Utils.scaleFloat(40))
        self.panelView.addSubview(self.monthButton)
        //动画开关
        
        
        //月份选择的父视图
        monthParentView.frame = CGRectMake(0, CGRectGetMaxY(self.yearButton.frame), Utils.screenWidth, Utils.scaleFloat(150) - CGRectGetMaxY(self.yearButton.frame))
        //"年份" + "全年" + 12个月份按钮
        monthParentView.contentSize = CGSizeMake(Utils.screenWidth/5.0*13, 50)
        monthParentView.backgroundColor = UIColor.whiteColor()
        monthParentView.showsHorizontalScrollIndicator = false
//        self.panelView.addSubview(monthParentView)
        //年份选择器
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
            self.yearArray.append(i)
        }
        //滑动到当前年份
        let offsetX = (PDCalendarAttribute.year(NSDate()) - 1900)/5
        self.yearCollectionView?.contentOffset = CGPointMake( CGFloat(offsetX) * Utils.screenWidth, 0)
    }
    
    //MARK:弹出底部视图
    func showYearMenu(){
        self.isShowPanel = !self.isShowPanel
        //如果是展开，则滑动到当前年份
        if self.isShowPanel {
            let offsetX = (PDCalendarAttribute.year(NSDate()) - 1900)/5
            self.yearCollectionView?.contentOffset = CGPointMake( CGFloat(offsetX) * Utils.screenWidth, 0)
        }
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
        return self.yearArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("yearCell", forIndexPath: indexPath) as! YearCollectionCell
    
        cell.yearLabel.text = "\(yearArray[indexPath.item])"
        if yearArray[indexPath.item] == PDCalendarAttribute.year(NSDate()) {
            cell.isCurrentTime = true
        }else{
            cell.isCurrentTime = false
        }
        cell.setAttribute()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        UIView.animateWithDuration(animationDuration) { 
            self.panelView.frame = CGRectMake(0, Utils.screenHeight-150, Utils.screenWidth, 150)
            self.triggerButton.frame = CGRectMake(Utils.screenWidth-30, Utils.screenHeight-180, 30, 30)
            self.selectedYear = self.yearArray[indexPath.item]
            self.monthParentView.setContentOffset(CGPointZero, animated: true)
            //月份选择按钮
            for i in 0..<13{
                let btn = UIButton.init(frame: CGRectMake(CGFloat(i)*Utils.screenWidth/5.0, 0, Utils.screenWidth/5.0, 50))
                if i == 0{
                    btn.setTitle("全年", forState: .Normal)
                }
                else{
                    btn.setTitle("\(i)", forState: .Normal)
                }
                btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
                btn.titleLabel?.font = UIFont.systemFontOfSize(16)
                btn.backgroundColor = UIColor.init(red: 230/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1.0)
                btn.layer.cornerRadius = 15
                btn.layer.masksToBounds = true
                btn.tag = i
                btn.addTarget(self, action: #selector(self.chooseDateComplete(_:)), forControlEvents: .TouchUpInside)
                self.monthParentView.addSubview(btn)
            }
        }
    }
    
    //MARK:日期选择完毕
    func chooseDateComplete(btn: UIButton){
//        self.showYearMenu()             //关闭底部菜单
        var isByMonth = true            //是否按月份查询
        var queryDateString = ""        //字符时间
        if btn.tag > 0 {//查询某月
            queryDateString = String.init(format: "%d-%02d-01", selectedYear,btn.tag)
        }else{//查询全年
            isByMonth = false
            queryDateString = String.init(format: "%d-01-01", selectedYear)
        }
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        //数据查询
        self.getPieNetData(fmt.dateFromString(queryDateString)!, isByMonth: isByMonth)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
