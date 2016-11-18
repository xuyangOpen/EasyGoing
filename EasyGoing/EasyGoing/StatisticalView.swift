//
//  StatisticalView.swift
//  EasyGoing
//
//  Created by King on 16/11/14.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class StatisticalView: UIScrollView,UIScrollViewDelegate {

    let line = UIImageView()
    
    let timeImage = UIImageView()
    let timeLabel = UILabel()
    let projectImage = UIImageView()
    let projectLabel = UILabel()
    let moneyImage = UIImageView()
    let moneyLabel = UILabel()
    
    //最大宽度
    var maxWidth:CGFloat = 0.0
    
    convenience init(frame: CGRect, projectCount: Int, money: CGFloat, timeStr: String){
        self.init(frame: frame)
        
        self.projectLabel.text = "消费项目：\(projectCount)"
        self.moneyLabel.text = "金额：\(money)"
        self.timeLabel.text = timeStr
        
        self.layoutViews()
        self.calculateWidth()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutViews(){
        self.addSubview(line)
        self.addSubview(timeImage)
        self.addSubview(timeLabel)
        self.addSubview(projectImage)
        self.addSubview(projectLabel)
        self.addSubview(moneyImage)
        self.addSubview(moneyLabel)
        
        line.backgroundColor = Utils.bgColor
        line.frame = CGRectMake(0, 0, self.bounds.width, 1)
        
        timeImage.image = UIImage.init(named: "time-icon")
        timeImage.frame = CGRectMake(20, (44-20)/2.0, 20, 20)
        
        timeLabel.font = UIFont.systemFontOfSize(16)
        let size = CGSizeMake(CGFloat.max, 20)
        timeLabel.frame = CGRectMake(CGRectGetMaxX(timeImage.frame)+5, 0, Utils.widthForText(timeLabel.text!, size: size, font: UIFont.systemFontOfSize(16)), 18)
        timeLabel.center.y = timeImage.center.y
        
        projectImage.image = UIImage.init(named: "project-icon")
        projectImage.frame = CGRectMake(CGRectGetMaxX(timeLabel.frame)+20, 0, 20, 20)
        projectImage.center.y = timeLabel.center.y
        
        projectLabel.font = UIFont.systemFontOfSize(16)
        projectLabel.textColor = UIColor.blackColor()
        projectLabel.frame = CGRectMake(CGRectGetMaxX(projectImage.frame)+5, 0, Utils.widthForText(projectLabel.text!, size: size, font: UIFont.systemFontOfSize(16)), 18)
        projectLabel.center.y = projectImage.center.y
        
        moneyImage.image = UIImage.init(named: "money-icon")
        moneyImage.frame = CGRectMake(CGRectGetMaxX(projectLabel.frame)+20, 0, 20, 20)
        moneyImage.center.y = projectLabel.center.y

        moneyLabel.font = UIFont.systemFontOfSize(16)
        moneyLabel.textColor = UIColor.blackColor()
        moneyLabel.frame = CGRectMake(CGRectGetMaxX(moneyImage.frame)+5, 0, Utils.widthForText(moneyLabel.text!, size: size, font: UIFont.systemFontOfSize(16)), 18)
        moneyLabel.center.y = moneyImage.center.y
    }
    
    func calculateWidth(){
        let size = CGSizeMake(CGFloat.max, 20)
        //时间文本宽
        let timeWidth = Utils.widthForText(timeLabel.text!, size: size, font: UIFont.systemFontOfSize(16))
        //项目文本宽
        let projectWidth = Utils.widthForText(projectLabel.text!, size: size, font: UIFont.systemFontOfSize(16))
        //金额文本宽
        let moneyWidth = Utils.widthForText(moneyLabel.text!, size: size, font: UIFont.systemFontOfSize(16))
        //最大宽度 = 距离左边20 + 时间图片20 + 小间隔5 + 时间文本宽 + 大间隔20 +
        //                     项目图片20 + 小间隔5 + 项目文本宽 + 大间隔20 +
        //                     金额图片20 + 小间隔5 + 金额文本宽
        maxWidth = 20 + 20 + 5 + timeWidth + 20 +
            20 + 5 + projectWidth + 20 +
            20 + 5 + moneyWidth
        self.showsHorizontalScrollIndicator = false
        //最大宽度 + 预留20
        self.contentSize = CGSizeMake(maxWidth + 20, 0)
    }

    
}
