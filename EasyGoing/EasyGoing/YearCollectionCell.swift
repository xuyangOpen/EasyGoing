//
//  YearCollectionCell.swift
//  EasyGoing
//
//  Created by King on 16/11/18.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class YearCollectionCell: UICollectionViewCell {

    let yearLabel = UILabel()
    var isCurrentTime = false
    var isDisplay = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(yearLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAttribute(){
        if isCurrentTime  {
            yearLabel.textColor = UIColor.redColor()
        }else{
            yearLabel.textColor = UIColor.blackColor()
        }
        yearLabel.font = UIFont.systemFontOfSize(16)
        yearLabel.textAlignment = .Center
        yearLabel.backgroundColor = UIColor.init(red: 230/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1.0)
        yearLabel.layer.cornerRadius = 15
        yearLabel.layer.masksToBounds = true
        self.yearLabel.snp_makeConstraints(closure: { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.size.equalToSuperview()
        })
    }
    
}
