//
//  ChooseMenuCell.swift
//  ChooseDateMenu
//
//  Created by King on 16/11/14.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class ChooseMenuCell: UICollectionViewCell {

    var labelView = UILabel()
    var showText = ""
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    func setCellAttributes(title: String, isNow:Bool){
        labelView.text = title
        labelView.font = UIFont.systemFontOfSize(16)
        labelView.textAlignment = .Center
        if isNow {
            labelView.textColor = UIColor.redColor()
        }else{
            labelView.textColor = UIColor.blackColor()
        }
        labelView.frame = self.contentView.bounds
        self.contentView.addSubview(labelView)
    }
    
}
