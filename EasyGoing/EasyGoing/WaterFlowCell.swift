//
//  WaterFlowCell.swift
//  EasyGoing
//
//  Created by King on 16/9/21.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import Foundation
import SnapKit

public enum UIEffectType : Int {
    
    case EffectTitle                //高斯模糊的标题
    case EffectBackground           //高斯模糊的背景
}

class WaterFlowCell: UICollectionViewCell {
    
    /*动画效果  
     1、CAGradientLayer动画 （05）
     2、Easing 圆形动画 （07）
     3、显示一个当前时间 （13）
     4、粒子雪花 （18）
     5、图片切换效果 （20）
     6、心电图效果 （28）
     7、音乐波形图动画 （29）
     8、水波纹效果 （54）
     
    */
    var style = UICollectionStyle.None
    
    let itemTitle = UILabel()
    
    let gradientMask = CAGradientViewController()
    let easing = CircleAnimationViewController()
    let emitterSnow = EmitterSnowController()
    let musicBar = MusicBarAnimationController()
    let waterwave = WaterWaveViewController()
    //时间显示的label
    let ymdLable = UILabel()
    let hmsLable = UILabel()
    var timer:NSTimer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor.whiteColor()
        //设置一个圆角
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        //设置定时器
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
        //将定时器添加到运行循环，保证滑动视图时，也能更新时间
        NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //设置实体类
    func setModel(model:WaterFlowModel){
        //获取style
        self.style = model.style!
        switch style {
        //如果是复用的cell，则直接拿来用，不再重复设置内容，节省内存，使视图滑动起来更流畅
        case .CAGradientLayer:
            if self.contentView.subviews.count == 0 {
                var images = [UIImage]()
                for i in 0..<3 {
                    var image = UIImage.init(named: "show\(i+1).jpg")
                    //对图片进行处理，减少图片内存
                    image = image?.adjustImage(image!, newSize: (image?.scaleImage(image!, imageLength: model.itemWidth))!)
                    images.append(image!)
                }
                self.gradientMask.addGradientOnView(self.contentView, andImages: images)
                self.setEffectViewBackground(.EffectTitle)
                self.setItemTitle("我的相册")
            }
        case .Easing:
            if self.contentView.subviews.count == 0 {
                self.setEffectViewBackground(.EffectBackground)
                self.easing.addEasingOnView(self.contentView)
                self.setItemTitle("小金库")
            }
        case .Clock:
            if self.contentView.subviews.count == 0 {
                self.setEffectViewBackground(.EffectBackground)
                //设置时间的label
                self.setTimeLocation()
                self.setItemTitle("北京时间")
            }
        case .EmitterSnow:
            if self.contentView.subviews.count == 0 {
                self.emitterSnow.addEmitterSnowOnView(self.contentView)
                self.setItemTitle("我是标题")
            }
        case .MusicBar:
            if self.contentView.subviews.count == 0 {
                self.musicBar.addMusicBarOnView(self.contentView)
                self.setItemTitle("我是标题")
            }
        case .WaterWave:
            if self.contentView.subviews.count == 0 {
                self.setEffectViewBackground(.EffectBackground)
                self.waterwave.addWaterWaveOnView(self.contentView)
                self.setItemTitle("我是标题")
            }
        default:
            break
        }
    }
    
    //MARK:设置item的标题
    func setItemTitle(title:String){
        self.itemTitle.text = title
        self.itemTitle.textColor = UIColor.whiteColor()
        self.itemTitle.textAlignment = .Center
        self.contentView.addSubview(self.itemTitle)
        self.itemTitle.snp_makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-2)
            make.height.equalTo(20)
        }
    }
    
    //MARK:定时更新时间的方法
    func updateTimeLabel(){
        self.ymdLable.text = self.getCurrentDate("yyyy-MM-dd")
        self.hmsLable.text = self.getCurrentDate("HH:mm:ss")
    }
    
    //MARK:获取当前时间
    func getCurrentDate(dateFormat:String) -> String{
        let fmt = NSDateFormatter()
        fmt.dateFormat = dateFormat
        return fmt.stringFromDate(NSDate())
    }
    
    //MARK:设置当前时间label所在位置
    func setTimeLocation(){
        self.hmsLable.font = UIFont.boldSystemFontOfSize(25)
        self.hmsLable.textColor = UIColor.whiteColor()
        self.hmsLable.text = self.getCurrentDate("HH:mm:ss")
        self.contentView.addSubview(self.hmsLable)
        self.hmsLable.snp_makeConstraints(closure: { (make) in
            make.center.equalToSuperview()
        })
        self.ymdLable.font = UIFont.systemFontOfSize(17)
        self.ymdLable.textColor = UIColor.whiteColor()
        self.ymdLable.text = self.getCurrentDate("yyyy-MM-dd")
        self.contentView.addSubview(self.ymdLable)
        self.ymdLable.snp_makeConstraints(closure: { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.hmsLable.snp_top).offset(-15)
        })
    }
    
    //MARK:设置高斯模糊背景
    func setEffectViewBackground(type:UIEffectType){
        let effectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .Light))
        self.contentView.addSubview(effectView)
        effectView.snp_makeConstraints(closure: { (make) in
            switch type{
            case .EffectTitle:
                make.left.equalToSuperview()
                make.bottom.equalToSuperview()
                make.right.equalToSuperview()
                make.height.equalTo(22)
            case .EffectBackground:
                make.size.equalToSuperview()
            }
        })
    }
    
    deinit{
        if self.timer?.valid == true {
            self.timer?.invalidate()
        }
        self.timer = nil
    }
}
