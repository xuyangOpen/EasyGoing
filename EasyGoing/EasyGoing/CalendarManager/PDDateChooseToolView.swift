//
//  PDDateChooseToolView.swift
//  Bluedaquiri
//
//  Created by bluedaquiri on 16/10/26.
//  Copyright © 2016年 blue. All rights reserved.
//

import UIKit

class PDDateChooseToolView: UIView {
    var dateLabel = UILabel()
    var leftOrRightClourse: ((isDirectionToLeft: Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configToolView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configToolView() {
        // 1.线
        let lineBottom = UIView(frame: CGRectMake(0, self.size_height - 1, self.size_width, 1))
        lineBottom.backgroundColor = UIColor.colorWithCustomName("分割线")
        self.addSubview(lineBottom)
        // 2.年月
        dateLabel.frame = CGRectMake(self.center_x - 49, 5, 98, 61 / 2.0)
        dateLabel.textAlignment = .Center
        dateLabel.textColor = PDCalendarAttribute().calendarAfterDayColor
        dateLabel.font = PDCalendarAttribute().calendarMonthYearFont
        self.addSubview(dateLabel)
        // 3.左右滑动按钮
        let leftButton = UIButton(type: .Custom)
        leftButton.setImage(UIImage(named: "green_arrows_left"), forState: .Normal)
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(17 / 2.0, 20, 17 / 2.0, 20)
        leftButton.frame = CGRectMake(CGRectGetMinX(dateLabel.frame) - 28, 5, 28, 65 / 2.0)
        leftButton.buttonClickWithClosure { [weak self] (button) in
            self?.leftOrRightClourse?(isDirectionToLeft: true)
        }
        self.addSubview(leftButton)
        
        let rightButton = UIButton(type: .Custom)
        rightButton.setImage(UIImage(named: "green_arrows_right"), forState: .Normal)
        rightButton.imageEdgeInsets = UIEdgeInsetsMake(17 / 2.0, 20, 17 / 2.0, 20)
        rightButton.frame = CGRectMake(CGRectGetMaxX(dateLabel.frame), 5, 28, 65 / 2.0)
        rightButton.buttonClickWithClosure { [weak self] (button) in
            self?.leftOrRightClourse?(isDirectionToLeft: false)
        }
        self.addSubview(rightButton)
    }
}
