//
//  TimeLineNormalCell.swift
//  EasyGoing
//
//  Created by King on 16/9/23.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import SnapKit

class TimeLineNormalCell: UITableViewCell {

    var eventLabel = UILabel()              //消费项目
    var costLable = UILabel()               //消费金额
    var markLabel = UILabel()               //备注
    var colorView = UIImageView()           //判断是否展开的属性，展开时变主题颜色，收起时为黑色
    var markImageView = UIImageView()       //备注旁边的的图案
    
    
    //备注的size  左右间距分别为20，则宽度=屏幕宽-20*2
    let markSize = CGSizeMake(Utils.screenWidth-40, CGFloat.max)
    
    func setModel(model:TimeLineRecord){
        //消费金额
        self.contentView.addSubview(costLable)
        costLable.text = String(model.recordCost) + "元"
        costLable.textColor = UIColor.blackColor()
        costLable.textAlignment = .Right
        costLable.sizeToFit()
        costLable.snp_makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(20)
        }
        //消费项目
        self.contentView.addSubview(eventLabel)
        eventLabel.text = model.recordEvent
        eventLabel.textColor = Utils.allTintColor
        eventLabel.snp_makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(10)
            make.right.equalTo(costLable.snp_left).offset(-10)
            make.height.equalTo(20)
        }
        //色块
        self.contentView.addSubview(colorView)
        colorView.backgroundColor = UIColor.grayColor()
        colorView.snp_makeConstraints { (make) in
            make.centerY.equalTo(eventLabel)
            make.left.equalToSuperview()
            make.width.equalTo(3)
            make.height.equalTo(15)
        }
        
        
        if model.isExpand {//展开
            self.contentView.addSubview(markLabel)
            if model.recordMark == "" {
                markLabel.text = "     无备注"
            }else{
                markLabel.text = "     " + model.recordMark
            }
            markLabel.numberOfLines = 0     //不限制行数
            markLabel.snp_makeConstraints(closure: { (make) in
                make.left.equalToSuperview().offset(20)
                make.top.equalTo(self.eventLabel.snp_bottom).offset(20)
                make.right.equalToSuperview().offset(-20)
            })
            //图案
            markImageView.image = UIImage.init(named: "mark")
            self.contentView.addSubview(markImageView)
            markImageView.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(markLabel)
                make.left.equalTo(markLabel)
                make.width.equalTo(17)
                make.height.equalTo(17)
            })
            
            //设置色块颜色
            colorView.backgroundColor = Utils.allTintColor
        }else{//收起
            markLabel.text = ""
            markImageView.removeFromSuperview()
        }
    }
    
    //计算cell的高度
    func heightForCell(model:TimeLineRecord) -> CGFloat{
        //标题距离顶部：10 距离底部：10  自身高度20
        var height:CGFloat = 10 + 10 + 20
 
        if model.isExpand {
            //备注顶部20 底部10 自身高度计算
            var selfHeight:CGFloat = 0.0
            if model.recordMark == "" {
                selfHeight = Utils.heightForText("     无备注", size: markSize, font: UIFont.systemFontOfSize(17))
            }else{
                selfHeight = Utils.heightForText("     " + model.recordMark, size: markSize, font: UIFont.systemFontOfSize(17))
            }
            height += 20 + 10 + selfHeight
        }
        
        return height
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
