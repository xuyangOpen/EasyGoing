//
//  TabBarItem.swift
//  EasyGoing
//
//  Created by King on 16/8/29.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import SnapKit
protocol TabBarDelegate {
    func changeIndex(index:Int)
}

class TabBarItem: UIView {
    //视图
    var itemImageView = UIImageView()
    var itemText = UILabel()
    
    var delegate:TabBarDelegate?
    
    //视图属性
    var isSelected = false{
        didSet{
            if isSelected {
                self.itemText.textColor = self.selectedColor
                self.itemImageView.image = self.selectedImage
            }else{
                self.itemText.textColor = self.unSelectedColor
                self.itemImageView.image = self.unSelectedImage
            }
        }
    }
    //选中文字
    var selectedColor = UIColor.orangeColor()
    var unSelectedColor = UIColor.grayColor()
    //选中图片
    var selectedImage:UIImage?
    var unSelectedImage:UIImage?
    
    //是否更新子视图的变量
    var didUpdateView = false
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(frame: CGRect,text:String,selectedTextColor:UIColor,selectedImage:String,unSelectedImage:String) {
        super.init(frame: frame)
        self.itemText.text = text
        
        self.selectedColor = selectedTextColor
        self.selectedImage = UIImage.init(named: selectedImage)
        self.unSelectedImage = UIImage.init(named: unSelectedImage)
        //必须调用此初始化方法，视图才会更新
        self.didUpdateView = true
    }
    
    override func layoutSubviews() {
        if didUpdateView {
            //图片是48 * 32
            self.addSubview(self.itemImageView)
            self.addSubview(self.itemText)
            //布局图片
            self.itemImageView.image = self.isSelected ? self.selectedImage! : self.unSelectedImage!
            self.itemImageView.snp_makeConstraints(closure: { (make) in
                make.centerY.equalToSuperview().offset(-7)
                make.centerX.equalToSuperview()
                make.height.equalTo(32)
                make.width.equalTo(48)
            })
            //布局文字
            self.itemText.font = UIFont.systemFontOfSize(12)
            self.itemText.textAlignment = .Center
            self.itemText.textColor = self.isSelected ? self.selectedColor : self.unSelectedColor
            self.itemText.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(self.itemImageView.snp_bottom)
                make.centerX.equalToSuperview()
                make.height.equalTo(12)
                make.width.equalToSuperview()
            })
            
            didUpdateView = false
        }
        super.layoutSubviews()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !self.isSelected {
            self.isSelected = true
            if ((self.delegate?.changeIndex(self.tag)) != nil) {
                
            }
        }
    }
    
}
