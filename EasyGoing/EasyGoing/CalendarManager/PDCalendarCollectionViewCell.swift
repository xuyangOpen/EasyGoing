//
//  PDCalendarCollectionViewCell.swift
//  Bluedaquiri
//
//  Created by bluedaquiri on 16/10/26.
//  Copyright © 2016年 blue. All rights reserved.
//

import UIKit

class PDCalendarCollectionViewCell: UICollectionViewCell {
    let attriManager = PDCalendarAttribute()
    var dayLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell() {
        dayLabel = UILabel(frame: self.bounds)
        dayLabel.font = attriManager.calendarFont ?? UIFont.systemFontOfSize(15)
        dayLabel.textAlignment = .Center
        self.contentView.addSubview(dayLabel)
    }
}
