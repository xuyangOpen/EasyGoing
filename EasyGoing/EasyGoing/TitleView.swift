//
//  TitleView.swift
//  EasyGoing
//
//  Created by King on 16/11/15.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

typealias tapTitleViewClosure = () -> Void

class TitleView: UIView {

    var titleLable = UILabel()
    var imageView = UIImageView.init(image: UIImage.init(named: "arrow"))
    var tapClosure:tapTitleViewClosure?
    
    convenience init(frame: CGRect,title: String) {
        self.init(frame: frame)
        
        titleLable.text = title
        
        layoutViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutViews(){
        self.addSubview(titleLable)
        self.addSubview(imageView)
        //计算宽度
        let titleLenght = Utils.widthForText(titleLable.text!, size: CGSizeMake(CGFloat.max, 20), font: UIFont.boldSystemFontOfSize(17))
        titleLable.textColor = UIColor.blackColor()
        titleLable.font = UIFont.boldSystemFontOfSize(17)
        titleLable.frame = CGRectMake((100-titleLenght-20-5)/2.0, CGRectGetMidY(self.frame) - 10, titleLenght, 20)
        imageView.frame = CGRectMake(CGRectGetMaxX(titleLable.frame) + 5, CGRectGetMidY(self.frame) - 12, 20, 20)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let titleLenght = Utils.widthForText(titleLable.text!, size: CGSizeMake(CGFloat.max, 20), font: UIFont.boldSystemFontOfSize(17))
        titleLable.frame = CGRectMake((100-titleLenght-20-5)/2.0, CGRectGetMidY(self.frame) - 10, titleLenght, 20)
        imageView.frame = CGRectMake(CGRectGetMaxX(titleLable.frame) + 5, CGRectGetMidY(self.frame) - 12, 20, 20)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.tapClosure != nil {
            self.tapClosure!()
        }
    }
    
}
