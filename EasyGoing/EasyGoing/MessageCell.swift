//
//  MessageCell.swift
//  EasyGoing
//
//  Created by King on 16/11/25.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import SnapKit

class MessageCell: UITableViewCell {

    let title = UILabel()
    
    var timer:NSTimer?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        //属性设置
        self.contentView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        
        self.title.font = UIFont.systemFontOfSize(12)
        self.title.textColor = UIColor.blackColor()
        self.contentView.addSubview(self.title)
        self.title.snp_makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.centerY.equalToSuperview()
        }
        
        self.timer = NSTimer.init(timeInterval: 1, target: self, selector: #selector(hideContentView), userInfo: nil, repeats: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:添加title
    func addTitle(title: String){
        if self.timer != nil {
            self.title.text = title
        }
        if title == "" {
            self.contentView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
            self.title.removeFromSuperview()
            self.timer = nil
        }
    }
    
    //MARK:定时器方法：2秒之后，contentView隐藏
    func hideContentView(){
        UIView.animateWithDuration(1, animations: {
            self.contentView.backgroundColor = UIColor.clearColor()
        }) { (flag) in
            self.title.removeFromSuperview()
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    //MARK:启动定时器
    func startTimer(){
        if self.timer != nil {
            //将定时器加入到runloop中，定时器开启
            NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
//            self.timer?.fire()
        }
    }
    
}
