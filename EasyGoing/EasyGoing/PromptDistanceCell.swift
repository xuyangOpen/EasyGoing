//
//  PromptDistanceCell.swift
//  EasyGoing
//
//  Created by King on 16/11/28.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class PromptDistanceCell: UITableViewCell {

    let title = UILabel()
    let rightImageView = UIImageView.init(image: UIImage.init(named: "choose"))
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.subviewLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func subviewLayout(){
        self.contentView.addSubview(self.title)
        self.contentView.addSubview(self.rightImageView)
        
        self.title.textColor = UIColor.blackColor()
        self.title.font = UIFont.systemFontOfSize(16)
        self.title.snp_makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        self.rightImageView.snp_makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSizeMake(30, 20))
        }
    }
    
    func setData(titleStr: String, isChoose: Bool){
        self.title.text = titleStr
        
        if isChoose {
           self.contentView.addSubview(self.rightImageView)
            self.rightImageView.snp_makeConstraints { (make) in
                make.right.equalToSuperview().offset(-20)
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSizeMake(30, 20))
            }
        }else{
            self.rightImageView.removeFromSuperview()
        }
    }
    
}
