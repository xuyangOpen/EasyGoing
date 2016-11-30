//
//  SearchViewCell.swift
//  EasyGoing
//
//  Created by King on 16/11/23.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class SearchViewCell: UITableViewCell {

    let iconImageView = UIImageView()
    let mainTitle = UILabel()
    let cityLabel = UILabel()
    let districtLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.whiteColor()
        self.subviewLayout()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func subviewLayout(){
        self.contentView.addSubview(iconImageView)
        self.contentView.addSubview(mainTitle)
        self.contentView.addSubview(cityLabel)
        self.contentView.addSubview(districtLabel)
        
        iconImageView.image = UIImage.init(named: "search")
        iconImageView.snp_makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.size.equalTo(CGSizeMake(18, 18))
            make.centerY.equalToSuperview()
        }
        
        mainTitle.font = UIFont.systemFontOfSize(16)
        mainTitle.textColor = UIColor.blackColor()
        mainTitle.snp_makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp_right).offset(15)
            make.centerY.equalToSuperview()
        }
        
        cityLabel.font = UIFont.systemFontOfSize(12)
        cityLabel.textColor = UIColor.blackColor()
        cityLabel.snp_makeConstraints { (make) in
            make.top.equalTo(mainTitle.snp_bottom).offset(5)
            make.left.equalTo(mainTitle)
        }
        
        districtLabel.font = UIFont.systemFontOfSize(12)
        districtLabel.textColor = UIColor.blackColor()
        districtLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(cityLabel)
            make.left.equalTo(cityLabel.snp_right).offset(20)
        }
    }
    
    func setModel(model: SearchModel){
        self.mainTitle.text = model.placeKey
        self.cityLabel.text = model.cityKey
        self.districtLabel.text = model.districtKey
    }
    
}

