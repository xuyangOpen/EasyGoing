//
//  HomeHeaderView.swift
//  EasyGoing
//
//  Created by King on 16/11/23.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class HomeHeaderView: UICollectionReusableView,UIScrollViewDelegate {

    let scrollView = UIScrollView()
    let pagePoint = UIPageControl()
    
    var imageViewArray = [UIImageView]()
    
    var timer:NSTimer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.subviewLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func subviewLayout(){
        //设置UIScrollView
        self.scrollView.frame = self.bounds
        self.scrollView.backgroundColor = UIColor.whiteColor()
        self.scrollView.pagingEnabled = true
        self.scrollView.delegate = self
        self.scrollView.contentOffset = CGPointMake(self.bounds.width, 0)
        self.scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(self.scrollView)
        
        //设置分页圆点
        self.pagePoint.currentPage = 0
        self.addSubview(self.pagePoint)
        self.pagePoint.snp_makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-15)
            make.width.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    //MARK:设置头视图内容
    func configHeaderView(imagesName: [String]) -> Void {
        self.imageViewArray.removeAll()
        //初始化视图
        for i in 0...imagesName.count + 1 {
            let imageView = UIImageView.init(frame: CGRectMake(CGFloat(i)*self.bounds.width, 0, self.bounds.width, self.bounds.height))
            if i == 0 {//第一个位置为最后一张图片
                imageView.image = UIImage.init(named: imagesName[imagesName.count - 1])
            }else if  i == imagesName.count + 1 && imagesName.count > 1 {
                //最后一个位置为第一张图片
                imageView.image = UIImage.init(named: imagesName[0])
            }else{
                imageView.image = UIImage.init(named: imagesName[i - 1])
            }
            imageView.contentMode = .ScaleAspectFill
            imageView.layer.masksToBounds = true
            self.scrollView.addSubview(imageView)
            self.imageViewArray.append(imageView)
        }
        //设置页数
        self.pagePoint.numberOfPages = imagesName.count
        if imagesName.count > 1 {
            self.scrollView.contentSize = CGSizeMake(self.bounds.width*CGFloat(imagesName.count + 2), 0)
        }else{
            self.scrollView.contentSize = self.bounds.size
        }
        
        //添加一个定时器
        self.addTimer()
    }
    
    //MARK:添加定时器
    func addTimer(){
        if self.timer == nil {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: #selector(unlimitedRotation), userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
        }
    }
    
    //MARK:移除定时器
    func removeTimer(){
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    //MARK:UIScrollView代理方法
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= CGFloat(self.imageViewArray.count - 1) * self.bounds.width {//当滑动到最后一张图片时，分页点到第一个点，scrollView设置contentoffset为第二张图片的位置
            self.pagePoint.currentPage = 0
            self.scrollView.contentOffset = CGPointMake(self.bounds.width, 0)
        }else if scrollView.contentOffset.x <= 0{//当滑动到第一张图片位置时，分页到最后一个点，contentOffset为第倒数第二张图片位置
            self.pagePoint.currentPage = self.imageViewArray.count - 2
            self.scrollView.contentOffset = CGPointMake(CGFloat(self.imageViewArray.count - 2) * self.bounds.width, 0)
            
        }else if scrollView.contentOffset.x % self.bounds.width == 0{
            let index = Int(scrollView.contentOffset.x / self.bounds.width)
            self.pagePoint.currentPage = index - 1
        }
    }
    
    //MARK:用户滑动scrollView时，停止定时器
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.removeTimer()
    }
    
    //MARK:用户停止滑动scrollView时，开启定时器
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.addTimer()
    }
    
    func unlimitedRotation(){
        //获取当前位置
        let point = scrollView.contentOffset
        self.scrollView.setContentOffset(CGPointMake(point.x + self.bounds.width, 0), animated: true)
    }
    
    deinit{
        self.timer?.invalidate()
        self.timer = nil
    }
    
}
