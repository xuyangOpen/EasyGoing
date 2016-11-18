//
//  ShowCalendarController.swift
//  EasyGoing
//
//  Created by King on 16/11/16.
//  Copyright © 2016年 kf. All rights reserved.
//  添加消费记录 -->  选择日历视图
//

import UIKit

class ShowCalendarController: UIViewController {

    //日历控制器
    let calendarController = PDCalendarViewController()
    let parentVC = UIViewController()
    var chooseComplete : ((year: Int, month: Int, day: Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Utils.coverColor
    }
    
    func beginShow(date: NSDate){
        calendarController.calendarView.backgroundColor = UIColor.whiteColor()
        calendarController.transferShowDate = date
        //日历总高度 (item宽度-15) * 7 + 工具条高度
        let calendarHeight = ((KScreenWidth / 7) - 15) * 7 + (81 / 2.0 + 2)
        calendarController.isShowTool = true
        calendarController.calendarShow(parentVC, animated: false, calendarOriginY: (KScreenHeight - calendarHeight)/2.0)
        calendarController.selectedCompeletionClourse = { [weak self] (year,month,day) in
            if self?.chooseComplete != nil {
                self?.chooseComplete!(year: year,month: month,day: day)
            }
        }
        self.view.addSubview(parentVC.view)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let object = (touches as NSSet).anyObject() as! UITouch
        let point  = object.locationInView(self.view)
        if !CGRectContainsPoint(calendarController.calendarView.frame, point) {
            self.view.removeFromSuperview()
        }
    }
}
