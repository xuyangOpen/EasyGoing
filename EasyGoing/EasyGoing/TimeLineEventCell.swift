//
//  TimeLineEventCell.swift
//  EasyGoing
//
//  Created by King on 16/9/28.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

//cell的代理方法
protocol TimeLineCellDelete {
    func deleteCellAction(event:TimeLineEvent,cell:TimeLineEventCell,clickBtn:UIButton) -> Void      //删除项目
    func updateCellAction(event:TimeLineEvent,cell:TimeLineEventCell,clickBtn:UIButton) -> Void      //修改项目
}

public enum UITableViewCellStatus : Int {
    
    case Normal = 0                              //正常状态
    case Open
}

typealias tapCellClosure = (TimeLineEventCell) -> Void

class TimeLineEventCell: UITableViewCell,UIScrollViewDelegate {

    //按钮的宽度默认为70
    let btnWidth:CGFloat = 70
    var deleteButton = UIButton()           //删除按钮
    var updateButton = UIButton()           //修改按钮
    var addButton = UIButton()              //添加按钮
    var containerView = UIScrollView()      //滚动视图
    var mainCellView = UIView()             //呈现内容的视图
    var numberOfButton = 0                  //按钮个数
    var cellStatus = UITableViewCellStatus.Normal
    
    let icon = UIImageView()                //小icon
    let titleLabel = UILabel()              //目录标题
    
    var delegate:TimeLineCellDelete?        //cell的代理
    
    var event:TimeLineEvent?
    
    //cell打开时的回调
    var openCellClosure:tapCellClosure?
    
    //MARK:设置cell的内容
    func setContentOfCell(title:String,image:String,numberOfBtn:Int,beginOffset:CGFloat,bgColor:UIColor,event:TimeLineEvent,indexPath:NSIndexPath){
        //先移除所有子视图
        for subview in self.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        self.numberOfButton = numberOfBtn
        //滚动视图
        containerView.contentSize = CGSizeMake(Utils.screenWidth + btnWidth * CGFloat(numberOfBtn), 44)
        containerView.contentOffset = CGPointMake(0, 0)
        containerView.backgroundColor = UIColor.cyanColor()
        containerView.bounces = false
        containerView.showsHorizontalScrollIndicator = false
        containerView.delegate = self
        containerView.pagingEnabled = true
        self.contentView.addSubview(containerView)
        containerView.snp_makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.size.equalToSuperview()
        }
        //设置按钮
        containerView.addSubview(deleteButton)
        deleteButton.setTitle("删除", forState: .Normal)
        deleteButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        deleteButton.backgroundColor = UIColor.redColor()
        deleteButton.snp_makeConstraints { (make) in
            make.right.equalTo(self.contentView)
            make.top.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(btnWidth)
        }
        deleteButton.bk_addEventHandler({ (obj) in
    //        print("cell中的删除按钮")
            //防止按钮连续点击
            let button = obj as! UIButton
            button.enabled = false
            self.delegate?.deleteCellAction(event,cell: self,clickBtn: obj as! UIButton)
            }, forControlEvents: .TouchUpInside)
        //设置修改按钮
        containerView.addSubview(updateButton)
        updateButton.setTitle("修改", forState: .Normal)
        updateButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        updateButton.backgroundColor = UIColor.lightGrayColor()
        updateButton.snp_makeConstraints { (make) in
            make.right.equalTo(deleteButton.snp_left)
            make.top.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(btnWidth)
        }
        //保存实体类
        self.event = event
        updateButton.addTarget(self, action: #selector(updateAction(_:)), forControlEvents: .TouchUpInside)
//        updateButton.bk_addEventHandler({ (obj) in
//            print("cell中的修改按钮")
//            //防止按钮连续点击
//            let button = obj as! UIButton
//            button.enabled = false
//            self.delegate?.updateCellAction(event,cell: self,clickBtn: obj as! UIButton)
//            }, forControlEvents: .TouchUpInside)
        //cell的内容呈现视图
        mainCellView.backgroundColor = bgColor
        self.containerView.addSubview(mainCellView)
        mainCellView.snp_makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.size.equalToSuperview()
        }
        //图片
        icon.image = UIImage.init(named: image)
        mainCellView.addSubview(icon)
        icon.snp_makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(beginOffset)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        //文字
        titleLabel.text = title
        titleLabel.textColor = UIColor.blackColor()
        mainCellView.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(icon.snp_right).offset(10)
            make.width.equalTo(Utils.screenWidth - 80)
        }
    }
    //修改操作回调代理
    func updateAction(btn:UIButton){
        print("cell中的修改按钮")
        //防止按钮连续点击
        btn.enabled = false
        self.delegate?.updateCellAction(self.event!,cell: self,clickBtn: btn)
    }
    
    //MARK:UIScrollView的代理方法
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.x == 0 {
        }else{
            self.openCellClosure!(self)
        }
    }
    
    //MARK:关闭菜单的方法
    func closeMenu(){
        self.containerView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
