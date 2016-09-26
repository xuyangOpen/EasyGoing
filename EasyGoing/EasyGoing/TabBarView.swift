//
//  TabBarView.swift
//  EasyGoing
//
//  Created by King on 16/8/29.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

protocol TabBarViewDelegate {
    func changeControllers(index:Int)
}

class TabBarView: UIView,TabBarDelegate {

    //选中图片和未选中图片数组
    var selectedImageArray:[String]?
    var unSelectedImageArray:[String]?
    //文字数组
    var textArray:[String]?
    //文字选中颜色和未选中颜色
    var selectedColor:UIColor?
    var unSelectColor:UIColor?
    //是否更新视图的标识
    var didUpdateView = false
    //中间视图
    var centerView:UIView?
    
    //保存的item数组
    lazy var itemArray = [TabBarItem]()
    //当前选中下标
    var currentIndex = 0
    
    //代理
    var delegate:TabBarViewDelegate?
    
    init?(frame: CGRect,selectedImageArray:[String],unSelectedImageArray:[String],textArray:[String],textSelectedColor:UIColor) {
        super.init(frame: frame)
        self.selectedImageArray = selectedImageArray
        self.unSelectedImageArray = unSelectedImageArray
        self.selectedColor = textSelectedColor
        self.textArray = textArray
        //必须调用此初始化方法，视图才会更新布局
        self.didUpdateView = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if didUpdateView {
//            let splitView = UIImageView.init(frame: CGRectMake(0, 0, Utils.screenWidth, 1))
//            splitView.backgroundColor = UIColor.grayColor()
//            self.addSubview(splitView)
            if self.centerView == nil {
                //没有中间视图的情况下
                //计算每个item的宽度
                let itemWidth:CGFloat = Utils.screenWidth / CGFloat((self.selectedImageArray?.count)!)
                let itemHeight:CGFloat = 49.0
                for i in 0..<(self.selectedImageArray?.count)! {
                    let item = TabBarItem.init(frame: CGRectMake(CGFloat(i)*itemWidth, 0, itemWidth, itemHeight), text: self.textArray![i], selectedTextColor: self.selectedColor!, selectedImage: self.selectedImageArray![i], unSelectedImage: self.unSelectedImageArray![i])
                    if i == self.currentIndex {
                        item?.isSelected = true
                    }
                    item?.delegate = self
                    item?.tag = i
                    self.addSubview(item!)
                    self.itemArray.append(item!)
                }
            }else{
                //计算每个item的宽度
                let itemWidth:CGFloat = Utils.screenWidth / CGFloat((self.selectedImageArray?.count)!+1)
                let itemHeight:CGFloat = 49.0
                //有中间视图的情况下，且item的个数必须为偶数方能对称
                if ((self.selectedImageArray?.count)!)%2 == 0 {
                    //计算中间视图位置
                    let site = ((self.selectedImageArray?.count)!)/2
                    for i in 0...(self.selectedImageArray?.count)! {
                        
                        if i == site {
                            centerView?.frame = CGRectMake(CGFloat(i)*itemWidth, 0, itemWidth, itemHeight)
                            self.addSubview(centerView!)
                        }else{
                            let position = (i<site) ? i:i-1
                            let item = TabBarItem.init(frame: CGRectMake(CGFloat(i)*itemWidth, 0, itemWidth, itemHeight), text: self.textArray![position], selectedTextColor: self.selectedColor!, selectedImage: self.selectedImageArray![position], unSelectedImage: self.unSelectedImageArray![position])
                            if position == self.currentIndex {
                                item?.isSelected = true
                            }
                            item?.delegate = self
                            item?.tag = position
                            self.addSubview(item!)
                            self.itemArray.append(item!)
                        }
                    }
                }else{
                    print("视图非偶数个，不能生成")
                }
            }
            
            didUpdateView = false
        }
        super.layoutSubviews()
    }
    
    //改变item的方法
    func changeIndex(index: Int) {
        self.itemArray[self.currentIndex].isSelected = false
        self.itemArray[index].isSelected = true
        self.currentIndex = index
        //调用代理方法
        self.delegate?.changeControllers(self.currentIndex)
    }
    
}
