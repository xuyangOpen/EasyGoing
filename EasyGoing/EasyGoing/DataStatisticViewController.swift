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
    //创建一个分类的空字典，key表示消费项目  value表示数量
    var barCategoryDictionary = Dictionary<String, Int>()
    //创建一个计算金额的字典 ，key表示消费项目  value表示消费金额
    var barCostDictionary = Dictionary<String, CGFloat>()
    
    //数据源
    var dataSource = [TimeLineRecord]()
    
    //=============================================================
    //底部按钮
    let triggerButton = UIButton()
    //底部面板
    let panelView = UIView()
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
    let animationDuration = 0.5     //动画时间
    //选择年份的UICollectionView
    var yearCollectionView:UICollectionView?
    let flowLayout = UICollectionViewFlowLayout()
    var yearArray = [Int]()         //年份数组
    let titleYearLabel = UILabel()      //年份标题
    let titleMonthLabel = UILabel()     //月份标题
    let monthParentView = UIScrollView()    //月份选择按钮的父视图
    
    //MARK:ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置背景颜色
        self.view.backgroundColor = UIColor.init(red: 230/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1.0)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //标题栏
        self.setTitleView()
        self.configScrollView()
        //底部视图
        self.configbottomView()
        
        //获取网络数据
        self.getPieNetData()
        
        
    }

    //MARK:设置标题视图
    func setTitleView(){
        self.segmentView.selectedSegmentIndex = 0
        self.segmentView.frame = CGRectMake(0, 0, CGFloat(Utils.scale(150)), CGFloat(Utils.scale(30)))
        self.segmentView.addTarget(self, action: #selector(changeView(_:)), forControlEvents: .ValueChanged)
        self.navigationItem.titleView = self.segmentView
    }
    
    //MARK:请求网络数据
    func getPieNetData(){
        //网络加载数据
        Utils.sharedInstance.showLoadingViewOnView("数据加载中", parentView: self.view)
        //查询数据
        let query = AVQuery.init(className: "TimeLineRecord")
        //级联查询子目录
        query.includeKey("eventObject")
        //二级级联查询，查询子目录的父目录
        query.includeKey("eventObject.parentId")
        query.whereKey("userId", equalTo: AVUser.currentUser()!.objectId!)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            Utils.sharedInstance.hideLoadingView()
            if error == nil{
                self.dataSource.removeAll()
                if objects!.count > 0{
                    for obj in objects!{
                        self.dataSource.append(TimeLineRecord.initRecordWithAVObject(obj as! AVObject))//添加数据
                    }
                    
                    self.configPieChartData()
                    self.configBarChartData()
                    //配置视图
                    self.configMainView()
                }else{
                    Utils.showHUDWithMessage("暂无数据", time: 1, block: {})
                }
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
        self.pieChart.loadPieChartView()
        self.pieView.addSubview(self.pieChart.view)
        
        //柱形图设置
        self.barView.frame = CGRectMake(Utils.screenWidth, 0, Utils.screenWidth, Utils.screenHeight)
        self.barView.backgroundColor = UIColor.init(red: 230/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1.0)
        self.containerView.addSubview(self.barView)
    }
    
    //MARK:配置饼状图数据
    func configPieChartData(){
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
    }
    
    //MARK:配置柱状图数据
    func configBarChartData(){
        for record in self.dataSource{
            //判断分类字典是否包含当前parentId
            if !self.barCategoryDictionary.keys.contains(record.parentName){
                //统计消费项目数量
                self.barCategoryDictionary[record.parentName] = 1
                //统计消费项目金额
                self.barCostDictionary[record.parentName] = record.recordCost
            }else{
                self.barCategoryDictionary[record.parentName] = self.barCategoryDictionary[record.parentName]! + 1
                self.barCostDictionary[record.parentName] = self.barCostDictionary[record.parentName]! + record.recordCost
            }
        }
    }
    
    //MARK:
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 {
            self.pieChart.updateData()
        }else if scrollView.contentOffset.x == Utils.screenWidth{
            if self.barView.subviews.count == 0 {
                self.barChart.showFrame = CGRectMake(Utils.screenWidth, 0, Utils.screenWidth, Utils.screenWidth)
                self.barChart.categoryDictionary = self.barCategoryDictionary
                self.barChart.costDictionary = self.barCostDictionary
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
        self.pieChart.view.addSubview(self.triggerButton)
        self.triggerButton.addTarget(self, action: #selector(showYearMenu), forControlEvents: .TouchUpInside)
        //面板
        self.panelView.frame = CGRectMake(0, Utils.screenHeight, Utils.screenWidth, 150)
        self.panelView.backgroundColor = UIColor.whiteColor()
        self.pieChart.view.addSubview(self.panelView)
        //年份选择标题
        titleYearLabel.frame = CGRectMake(20, 0, Utils.screenWidth, 20)
        titleYearLabel.textAlignment = .Left
        titleYearLabel.textColor = UIColor.blackColor()
        titleYearLabel.text = "年份选择"
        titleYearLabel.font = UIFont.systemFontOfSize(16)
        self.panelView.addSubview(titleYearLabel)
        //月份选择标题
        titleMonthLabel.frame = CGRectMake(20, 75, Utils.screenWidth, 20)
        titleMonthLabel.textAlignment = .Left
        titleMonthLabel.textColor = UIColor.blackColor()
        titleMonthLabel.text = "月份选择"
        titleMonthLabel.font = UIFont.systemFontOfSize(16)
        self.panelView.addSubview(titleMonthLabel)
        //月份选择的父视图
        monthParentView.frame = CGRectMake(0, 95, Utils.screenWidth, 50)
        //"年份" + "全年" + 12个月份按钮
        monthParentView.contentSize = CGSizeMake(Utils.screenWidth/5.0*13, 50)
        monthParentView.backgroundColor = UIColor.whiteColor()
        monthParentView.showsHorizontalScrollIndicator = false
        self.panelView.addSubview(monthParentView)
        //年份选择器
        flowLayout.itemSize = CGSizeMake(Utils.screenWidth/5.0, 50)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .Horizontal
        
        self.yearCollectionView = UICollectionView.init(frame: CGRectMake(0, 20, Utils.screenWidth, 50), collectionViewLayout: flowLayout)
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
            let panelOriginY = self.isShowPanel ? (Utils.screenHeight-75) : Utils.screenHeight
            self.panelView.frame = CGRectMake(0, panelOriginY, Utils.screenWidth, 150)
            //按钮位置
            let btnOriginY = self.isShowPanel ?  Utils.screenHeight-105 : Utils.screenHeight-30
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
            self.titleMonthLabel.text = "\(self.yearArray[indexPath.item])年-月份选择"
            self.monthParentView.setContentOffset(CGPointZero, animated: true)
            //月份选择按钮
            for i in 0..<14{
                let btn = UIButton.init(frame: CGRectMake(CGFloat(i)*Utils.screenWidth/5.0, 0, Utils.screenWidth/5.0, 50))
                if i == 0{
                    btn.setTitle("全年", forState: .Normal)
                }
                else{
                    btn.setTitle("\(i-1)", forState: .Normal)
                }
                btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
                btn.titleLabel?.font = UIFont.systemFontOfSize(16)
                btn.backgroundColor = UIColor.init(red: 230/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1.0)
                btn.layer.cornerRadius = 15
                btn.layer.masksToBounds = true
                btn.tag = i - 1
                btn.addTarget(self, action: #selector(self.chooseDateComplete(_:)), forControlEvents: .TouchUpInside)
                self.monthParentView.addSubview(btn)
            }
        }
    }
    
    //MARK:日期选择完毕
    func chooseDateComplete(btn: UIButton){
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
