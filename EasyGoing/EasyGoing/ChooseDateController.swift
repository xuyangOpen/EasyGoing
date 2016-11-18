//
//  ChooseDateController.swift
//  EasyGoing
//
//  Created by King on 16/11/15.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

typealias chooseDateClosure = (Int,Int) -> Void

class ChooseDateController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    var chooseMenuCollectionView:UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    //当前年份
    var year = 2016
    var chooseYear = 2016
    //当前月份
    var month = 0
    //所有年份
    var yearArray = [Int]()
    //月份视图
    var monthView = UIView()
    //月份选择按钮
    var monthBtnArray = [UIButton]()
    
    var bounds = CGRectZero
    
    //日期选择回调
    var chooseDate:chooseDateClosure?
    
    //当前选中cell的frame
    var chooseCellFrame = CGRectZero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setCollectionView()
    }
    
    func setCollectionView(){
        chooseMenuCollectionView = UICollectionView.init(frame: CGRectMake(0, 0, bounds.width, bounds.height), collectionViewLayout: flowLayout)
        self.view.addSubview(chooseMenuCollectionView!)
        
        flowLayout.itemSize = CGSizeMake(bounds.width/4.0, bounds.height/3.0)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .Horizontal
        
        chooseMenuCollectionView?.delegate = self
        chooseMenuCollectionView?.dataSource = self
        chooseMenuCollectionView?.pagingEnabled = true
        chooseMenuCollectionView?.showsHorizontalScrollIndicator = false
        chooseMenuCollectionView?.showsVerticalScrollIndicator = false
        
        
        chooseMenuCollectionView?.registerClass(ChooseMenuCell.self, forCellWithReuseIdentifier: "chooseMenuCell")
        chooseMenuCollectionView?.backgroundColor = UIColor.whiteColor()
        //最小年份为1900  最大年份为2100
        for i in 1900...2100 {
            yearArray.append(i)
        }
        let offsetX = Int((year - 1900) / 12)
        chooseMenuCollectionView?.contentOffset = CGPointMake(CGFloat(offsetX)*bounds.width, 0)
    }
    
    //MARK:collectionView代理方法
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return yearArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("chooseMenuCell", forIndexPath: indexPath) as! ChooseMenuCell
        
        if yearArray[indexPath.item] == year {
            cell.setCellAttributes("\(yearArray[indexPath.item])年", isNow: true)
        }else{
            cell.setCellAttributes("\(yearArray[indexPath.item])年", isNow: false)
        }
        
        return cell
    }
    
    //MARK:点击cell弹出月份选择器
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //当前选择年份
        chooseYear = indexPath.item + 1900
        
        let selectCell = collectionView.cellForItemAtIndexPath(indexPath)
        let cellRect = selectCell?.convertRect(selectCell!.bounds, toView: self.view)
        //当前选中cell的frame
        if cellRect == nil {//如果cellRect为空，则缩放到中心位置
            self.chooseCellFrame = CGRectMake((self.bounds.width-bounds.width/4.0)/2.0, (self.bounds.height - self.bounds.height/3.0)/2.0, self.bounds.width/4.0, self.bounds.height/3.0)
        }else{
            self.chooseCellFrame = cellRect!
        }
        
        if self.monthView.superview != nil {
            self.monthView.removeFromSuperview()
            self.monthView = UIView()
        }
        monthView.alpha = 1
        monthView.frame = cellRect!
        monthView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(monthView)
        
        self.monthBtnArray.removeAll()
        //添加按钮到视图上
        for i in 0..<12 {
            let  btn = UIButton.init(frame: CGRectMake(CGFloat(i%4)*(monthView.frame.size.width/4.0), CGFloat(i/4)*(monthView.frame.size.height/3.0), cellRect!.width/4.0, cellRect!.height/3.0))
            btn.tag = i + 1
            if chooseYear == year && (i+1) == month {//当前月份
                btn.setTitleColor(UIColor.redColor(), forState: .Normal)
            }else{
                btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            }
            
            btn.setTitle("\(i+1)月", forState: .Normal)
            
            btn.addTarget(self, action: #selector(chooseCompleteAction(_:)), forControlEvents: .TouchUpInside)
            
            self.monthView.addSubview(btn)
            self.monthBtnArray.append(btn)
        }
        
        UIView.animateWithDuration(0.3, animations: {
            for i in 0..<12{
                self.monthBtnArray[i].frame = CGRectMake(CGFloat(i%4)*(self.bounds.width/4.0), CGFloat(i/4)*(self.bounds.height/3.0), self.bounds.width/4.0, self.bounds.height/3.0)
            }
            self.monthView.frame = CGRectMake(0, 0, self.bounds.width, self.bounds.height)
        }) { (flag) in
            
        }
    }
    
    //MARK:日期选择回调方法
    func chooseCompleteAction(btn: UIButton){
        if self.chooseDate != nil {
            self.chooseDate!(chooseYear,btn.tag)
        }
    }
    
}

