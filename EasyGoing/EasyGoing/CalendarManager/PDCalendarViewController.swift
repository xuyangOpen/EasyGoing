//
//  PDCalendarViewController.swift
//  Bluedaquiri
//
//  Created by bluedaquiri on 16/10/26.
//  Copyright © 2016年 blue. All rights reserved.
//

import UIKit

typealias monthChangeClosure = (NSDate) -> Void

class PDCalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var calendarView = UIView()
    var transferShowDate: NSDate?
    var selectedCompeletionClourse: ((year: Int, month: Int, day: Int) -> Void)?
    //绿色圆圈的直径
    var greenCircleDiameter: CGFloat = 35.0
    
    private var weekArr = [String]()
    private var dateArr = [String]()
    private var toolView: PDDateChooseToolView?
    private var calendarCollectionView: UICollectionView!
    private let collectionIdentify = "collectionIdentify"
    private var currentDateStr: String?
    private var currentDayStr: String?
    private var indexForSelected: (String, Int)?
    private let monthAnimDuration = 0.7
    private let circleAnimDuration = 0.5
    //当前日期
    var dateVisual: NSDate?
    //需要跳转的日期
    var jumpDate:NSDate?{
        didSet{
            if dateVisual != nil && jumpDate != nil {
                //比较年份
                if PDCalendarAttribute.year(dateVisual!) > PDCalendarAttribute.year(jumpDate!) {//日历往回翻
                    self.previousMonthAnim()
                }else if PDCalendarAttribute.year(dateVisual!) < PDCalendarAttribute.year(jumpDate!){//日历往后翻
                    self.nextMothAnim()
                }else{//年份相同比较月份
                    if PDCalendarAttribute.month(dateVisual!) > PDCalendarAttribute.month(jumpDate!) {//日历往回翻
                        self.previousMonthAnim()
                    }else if PDCalendarAttribute.month(dateVisual!) < PDCalendarAttribute.month(jumpDate!){//日历往后翻
                        self.nextMothAnim()
                    }//年份和月份都相同的情况下，日历不翻
                }
            }
        }
    }
    //是否显示日历顶部工具条  默认为false
    var isShowTool = false
    
    private var nextAnim = CATransition()
    private var prevoiusAnim = CATransition()
    private var showAnim = CAAnimationGroup()
    private var hideAnim = CAAnimationGroup()
    
    //日历翻页时的回调
    var monthChange:monthChangeClosure?
    
    // MARK: - Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        pageSetting()
        arrayWithInit()
        configCalendarView()
        configSwipGuesture()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // 默认选中
        calendarCollectionView.performBatchUpdates(nil) { (finished) in
            let row = PDCalendarAttribute.weekForMonthFistDay(self.dateVisual!) - 1 + PDCalendarAttribute.day(self.dateVisual!) - 1
            self.greenCircleShow(NSIndexPath.init(forRow: row, inSection: 1))
        }
    }
    
    // MARK: - PageSetting
    func pageSetting() {
        self.view.backgroundColor = UIColor.clearColor()
    }
    
    // MARK: - ArrayWithInit
    func arrayWithInit() {
        dateVisual = transferShowDate ?? NSDate()
        //"\(PDCalendarAttribute.year(dateVisual!))年" + "\(PDCalendarAttribute.month(dateVisual!))月"
        currentDateStr = "\(PDCalendarAttribute.year(dateVisual!))-" + "\(PDCalendarAttribute.month(dateVisual!))"
        weekArr = ["日","一","二","三","四","五","六"]
        dateArr = dateArrWithInit(dateVisual!)
        indexForSelected = (currentDateStr!, PDCalendarAttribute.weekForMonthFistDay(NSDate()) - 1)
    }
    
    // MARK: - ConfigCalendarView
    func configCalendarView() {
        // 1.容器
        calendarView.frame = CGRectMake(0, 0, self.view.size_width, 0)
        calendarView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(calendarView)
        // 2.工具栏
        if self.isShowTool {
            toolView = PDDateChooseToolView.init(frame: CGRectMake(0, 0, self.view.size_width, 81 / 2.0 + 2))
            toolView!.backgroundColor = UIColor.clearColor()
            toolView!.dateLabel.text = currentDateStr
            calendarView.addSubview(toolView!)
            //将工具栏左右的翻页按钮事件注释
            toolView!.leftOrRightClourse = {// [weak self]
            (isLeft) in
                if isLeft {
//                    self?.previousMonthAnim()
                } else {
//                    self?.nextMothAnim()
                }
            }
        }
        
        // 3.collectionView
        let itemWidth = KScreenWidth / CGFloat(weekArr.count)
        let itemHeight = itemWidth - 15
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.minimumLineSpacing = 0
        collectionLayout.minimumInteritemSpacing = 0
        collectionLayout.itemSize = CGSizeMake(itemWidth, itemHeight)
        //CGRectGetMaxY(toolView.frame)
        calendarCollectionView = UICollectionView(frame: CGRectMake(0, isShowTool ? CGRectGetMaxY(toolView!.frame) : 0, KScreenWidth, itemHeight * 7), collectionViewLayout: collectionLayout)
        calendarCollectionView.registerClass(PDCalendarCollectionViewCell.self, forCellWithReuseIdentifier: collectionIdentify)
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarCollectionView.backgroundColor = UIColor.clearColor()
        calendarCollectionView.showsVerticalScrollIndicator = false
        calendarCollectionView.showsVerticalScrollIndicator = false
        calendarView.addSubview(calendarCollectionView)

        calendarView.size_height = CGRectGetMaxY(calendarCollectionView.frame)
    }
    
    // MARK - UIGestureRecognizer
    func configSwipGuesture() {
        let swipeLeftGuesture = UISwipeGestureRecognizer(target: self, action: #selector(nextMothAnim))
        swipeLeftGuesture.direction = .Left
        calendarView.addGestureRecognizer(swipeLeftGuesture)
        
        let swipeRightGuesture = UISwipeGestureRecognizer(target: self, action: #selector(previousMonthAnim))//previousMonthAnim
        swipeRightGuesture.direction = .Right
        calendarView.addGestureRecognizer(swipeRightGuesture)
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return weekArr.count
        } else {
            return dateArr.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionIdentify, forIndexPath: indexPath) as! PDCalendarCollectionViewCell
        if indexPath.section == 0 {
            collectionCell.dayLabel.text = weekArr[indexPath.row]
            collectionCell.dayLabel.textColor = PDCalendarAttribute().calendarAfterDayColor
        } else {
            collectionCell.dayLabel.text = dateArr[indexPath.row]
            changeCollectionLabelColor(collectionCell.dayLabel)
        }
        
        return collectionCell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 {
            let totalDaysInMonth = PDCalendarAttribute.totalDaysInMonth(dateVisual!)
            let firstWeekDayInMonth = PDCalendarAttribute.weekForMonthFistDay(dateVisual!)
            let index = indexPath.row
            if index >= firstWeekDayInMonth - 1 && index < firstWeekDayInMonth + totalDaysInMonth - 1 {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            currentDayStr = (collectionView.cellForItemAtIndexPath(indexPath) as! PDCalendarCollectionViewCell).dayLabel.text
            greenCircleHide(NSIndexPath(forRow: indexForSelected!.1, inSection: 1))
            greenCircleShow(indexPath)
            selectedClourse()
        }
    }
    
    //MARK: - Public Method
    func calendarShow(viewController: UIViewController, animated: Bool, calendarOriginY: CGFloat) {
        viewController.view.insertSubview(self.view, atIndex: 0)
        viewController.addChildViewController(self)
        calendarView.origin_y = calendarOriginY
        
        if animated {
            let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
            scaleAnim.fromValue = 0
            scaleAnim.toValue = 1
            
            let startPoint = CGPointMake(calendarView.origin_x, calendarView.origin_y)
            let endPoint = CGPointMake(calendarView.center_x, calendarView.center_y)
            let posiAnim = CABasicAnimation(keyPath: "position")
            posiAnim.fromValue = NSValue.init(CGPoint: startPoint)
            posiAnim.toValue = NSValue.init(CGPoint: endPoint)
            
            showAnim.animations = [scaleAnim, posiAnim]
            showAnim.duration = 0.5
            showAnim.setValue("showAnim", forKey: "animType")
            calendarView.layer.addAnimation(showAnim, forKey: "")
        }
    }
    
    func calendarHide(viewController: UIViewController?, animted: Bool) {
        if animted {
            UIView.animateWithDuration(0.5, animations: {
                self.calendarView.center = CGPointMake(self.calendarView.origin_x, self.calendarView.origin_y)
                self.calendarView.transform = CGAffineTransformMakeScale(0.1, 0.1)
            }) { (finished) in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        } else {
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
    }
    
    // MARK: - Private Method
    /**
     返回日期数组
     
     - parameter date: NSDate
     
     - returns: 数组
     */
    func dateArrWithInit(date: NSDate) -> [String] {
        var dateArr = [String]()
        let totalDays = PDCalendarAttribute.totalDaysInMonth(date)
        let firstDayIndex = PDCalendarAttribute.weekForMonthFistDay(date) - 1
        for index in 0..<42 {
            if index >= firstDayIndex && index < firstDayIndex + totalDays {
                dateArr += ["\(index - firstDayIndex + 1)"]
            } else {
                dateArr += [""]
            }
        }
        return dateArr
    }
    
    /**
     根据日期改变Label颜色
     
     - parameter dateLabel: Label
     */
    func changeCollectionLabelColor(dateLabel: UILabel) {
        var yearMonthStr = currentDateStr
        yearMonthStr = yearMonthStr?.stringByReplacingOccurrencesOfString("月", withString: "")
        //Int((yearMonthStr?.componentsSeparatedByString("年")[0])!)
        let year = Int((yearMonthStr?.componentsSeparatedByString("-")[0])!)
        let month = Int((yearMonthStr?.componentsSeparatedByString("-")[1])!)
        let attri = PDCalendarAttribute()
        
        if year < PDCalendarAttribute.year(NSDate()) || (year == PDCalendarAttribute.year(NSDate()) && month < PDCalendarAttribute.month(NSDate())) {
            dateLabel.textColor = attri.calendarBeforeDayColor
        } else if year > PDCalendarAttribute.year(NSDate()) ||  (year == PDCalendarAttribute.year(NSDate()) && month > PDCalendarAttribute.month(NSDate())) {
            dateLabel.textColor = attri.calendarAfterDayColor
        } else if year == PDCalendarAttribute.year(NSDate()) && month == PDCalendarAttribute.month(NSDate()) {
            let today = PDCalendarAttribute.day(NSDate())
            if let index = Int(dateLabel.text!) {
                if index > today {
                    dateLabel.textColor = attri.calendarAfterDayColor
                } else if index < today {
                    dateLabel.textColor = attri.calendarBeforeDayColor
                } else {
                    dateLabel.textColor = attri.calendarTodayColor
                }
            }
        }
    }
    
    /**
     回调闭包
     */
    func selectedClourse() {
        var yearMonthStr = indexForSelected!.0
        yearMonthStr = yearMonthStr.stringByReplacingOccurrencesOfString("月", withString: "")
        //Int(yearMonthStr.componentsSeparatedByString("年")[0])
        let year = Int(yearMonthStr.componentsSeparatedByString("-")[0])
        let month = Int(yearMonthStr.componentsSeparatedByString("-")[1])
        let day = Int(currentDayStr!)
        selectedCompeletionClourse?(year: year!, month: month!, day: day!)
    }
    
    /**
     转场动画到下个月
     */
    func nextMothAnim() {
        greenCircleHide(NSIndexPath(forRow: indexForSelected!.1, inSection: 1))
        nextAnim.type = "pageCurl"//pageUnCurl
        nextAnim.duration = monthAnimDuration
        nextAnim.delegate = self
        nextAnim.setValue("nextAnim", forKey: "animType")
        calendarView.layer.addAnimation(nextAnim, forKey: "")
    }
    
    /**
     转场动画到上个月
     */
    func previousMonthAnim() {
        greenCircleHide(NSIndexPath(forRow: indexForSelected!.1, inSection: 1))
        
        prevoiusAnim.type = "pageUnCurl"
        prevoiusAnim.duration = monthAnimDuration
        prevoiusAnim.delegate = self
        prevoiusAnim.setValue("prevoiusAnim", forKey: "animType")
        calendarView.layer.addAnimation(prevoiusAnim, forKey: "")
    }
    
    /**
     数据刷新
     
     - parameter date: 根据Date
     */
    func reloadByDate(date: NSDate) {
        dateArr = dateArrWithInit(date)
        //"\(PDCalendarAttribute.year(date))年" + "\(PDCalendarAttribute.month(date))月"
        currentDateStr =  "\(PDCalendarAttribute.year(date))-" + "\(PDCalendarAttribute.month(date))"
        if toolView != nil {
            toolView!.dateLabel.text = self.currentDateStr
        }
        if self.monthChange != nil {
            self.monthChange!(dateVisual!)
        }
        calendarCollectionView.reloadData()
    }
    
    // MARK: - Animation
    
    /**
     绿圈显示动画
     
     - parameter indexPath: 显示在IndexPath位置
     */
    func greenCircleShow(indexPath: NSIndexPath) {
        let calendarCell = calendarCollectionView.cellForItemAtIndexPath(indexPath) as! PDCalendarCollectionViewCell
        calendarCell.dayLabel.textColor = PDCalendarAttribute().calendarSelectdayColor
        let greenView = UIImageView(frame:  CGRectMake(calendarCell.dayLabel.center_x, calendarCell.dayLabel.center_y, 0, 0))
        greenView.backgroundColor = UIColor.colorWithCustomName("绿")
        greenView.layer.cornerRadius = greenCircleDiameter / 2.0
        calendarCell.contentView.insertSubview(greenView, atIndex: 0)
        
        let scalceAnim = CABasicAnimation(keyPath: "bounds")
        scalceAnim.duration = circleAnimDuration
        scalceAnim.toValue = NSValue.init(CGRect: CGRectMake(greenView.origin_x, greenView.origin_y, greenCircleDiameter, greenCircleDiameter))
        scalceAnim.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        scalceAnim.removedOnCompletion = false
        scalceAnim.fillMode = "forwards"
        greenView.layer.addAnimation(scalceAnim, forKey: "")
        
        let valueOne = NSValue.init(CATransform3D: CATransform3DMakeScale(1.2, 1.2, 1))
        let valueTwo = NSValue.init(CATransform3D: CATransform3DMakeScale(0.9, 0.9, 1))
        let valueThree = NSValue.init(CATransform3D: CATransform3DMakeScale(1.1, 1.1, 1))
        let timeOne = NSNumber(float: 0.4)
        let timeTwo = NSNumber(float: 0.7)
        let timeThree = NSNumber(float: 0.9)
        let springAnim = CAKeyframeAnimation(keyPath: "transform.scale")
        springAnim.beginTime = CACurrentMediaTime() + circleAnimDuration * 0.6
        springAnim.duration = circleAnimDuration
        springAnim.values = [valueOne, valueTwo, valueThree]
        springAnim.keyTimes = [timeOne, timeTwo, timeThree]
        greenView.layer.addAnimation(springAnim, forKey: "")
        
        indexForSelected = (currentDateStr!, indexPath.row)
    }
    
    /**
     绿圈隐藏
     
     - parameter indexPath: 根据IndexPath
     */
    func greenCircleHide(indexPath: NSIndexPath) {
        let calendarCell = calendarCollectionView.cellForItemAtIndexPath(indexPath) as? PDCalendarCollectionViewCell
        changeCollectionLabelColor((calendarCell?.dayLabel)!)
        if let subviews = calendarCell?.contentView.subviews {
            for view in subviews {
                if view.isKindOfClass(UIImageView.self) {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    // MARK: - CAAnimtionDelegate
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag {
            if anim.valueForKey("animType") as! String == "nextAnim" {
                if self.indexForSelected?.0 == self.currentDateStr {
                 self.greenCircleShow(NSIndexPath(forRow: self.indexForSelected!.1, inSection: 1))
                }
            } else if anim.valueForKey("animType") as! String == "prevoiusAnim"  {
                if self.indexForSelected?.0 == self.currentDateStr {
                    self.greenCircleShow(NSIndexPath(forRow: self.indexForSelected!.1, inSection: 1))
                }
            }
        }
    }
    
    override func animationDidStart(anim: CAAnimation) {
        if anim.valueForKey("animType") as! String == "nextAnim" {
            if jumpDate != nil {
                self.dateVisual = self.jumpDate
                self.reloadByDate((self.dateVisual)!)
                //更新完视图之后，跳转日期置空
                self.jumpDate = nil
            }else{
                self.dateVisual = PDCalendarAttribute.nextMothDate((self.dateVisual)!)
                self.reloadByDate((self.dateVisual)!)
            }
            
        } else if anim.valueForKey("animType") as! String == "prevoiusAnim" {
            if jumpDate != nil {
                self.dateVisual = self.jumpDate
                self.reloadByDate(self.dateVisual!)
                //更新完视图之后，跳转日期置空
                self.jumpDate = nil
            }else{
                self.dateVisual = PDCalendarAttribute.lastMothDate(self.dateVisual!)
                self.reloadByDate(self.dateVisual!)
            }
            
        }
    }
}
