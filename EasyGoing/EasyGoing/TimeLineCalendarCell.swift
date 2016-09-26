//
//  TimeLineCalendarCell.swift
//  EasyGoing
//
//  Created by King on 16/9/23.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

typealias calendarClosure = (Int,Int,Int) -> Void

class TimeLineCalendarCell: UITableViewCell {
    //日历点击时的回调
    var calendarCallBack:calendarClosure?
    
    func setCalendarView(){
        if self.contentView.subviews.count == 0 {
            let calendar = SZCalendarPicker.showOnView(self.contentView)
            calendar.today = NSDate()
            calendar.date = calendar.today
            calendar.snp_makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.height.equalTo(300)
            }
            calendar.backgroundColor = Utils.bgColor
            calendar.calendarBlock = {
                (day,month,year) in
                self.calendarCallBack!(day,month,year)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
