//
//  AddRecordViewController.swift
//  EasyGoing
//
//  Created by King on 16/9/23.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import BlocksKit

typealias executeInBlockClosure = () ->Void
//更新数据的块，如果添加了当前日期（当前选中日期，不一定是当天）的数据，则回调更新块
typealias updateDataClosure = () -> Void

class AddRecordViewController: UIViewController {
    //MARK:属性声明
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    
    
    @IBOutlet weak var submitButton: UIButton!              //提交按钮
    @IBOutlet weak var timeButton: UIButton!                //选择时间按钮
    @IBOutlet weak var eventButton: UIButton!               //选择消费项目按钮
    @IBOutlet weak var costTextField: UITextField!          //花费输入框
    @IBOutlet weak var markTextView: UITextView!            //备注输入框
    
    var chooseEventVC:TimeLineChooseEventController?
    var updateTimeLine:updateDataClosure?
    //当前消费项目
    var event:TimeLineEvent?
    //消费类型的默认选中项
    var parentIndex = 0
    var childIndex = 0
    //选中时间
    var addTimeString = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
    }
    
    //MARK:页面设置
    func setUp(){
        self.title = NSLocalizedString("TimeLine.add.title", comment: "添加消费记录")
        self.view.backgroundColor = Utils.bgColor
        
        //页面文字国际化
        self.timeLable.text = NSLocalizedString("AddRecordViewController.label.time", comment: "日期")
        self.eventLabel.text = NSLocalizedString("AddRecordViewController.label.event", comment: "消费项目")
        self.eventButton.setTitle(NSLocalizedString("AddRecordViewController.label.select", comment: "请选择消费项目"), forState: .Normal)
        self.costLabel.text = NSLocalizedString("AddRecordViewController.label.cost", comment: "消费金额")
        self.costTextField.placeholder = NSLocalizedString("AddRecordViewController.placehold.cost", comment: "最多保留两位小数")
        self.markLabel.text = NSLocalizedString("AddRecordViewController.label.mark", comment: "备注")
        self.submitButton.setTitle(NSLocalizedString("AddRecordViewController.submit.text", comment: "提交"), forState: .Normal)
        //设置默认时间
        self.timeButton.setTitle(self.addTimeString, forState: .Normal)
    }
    
    //MARK:选择时间
    @IBAction func chooseTimeAction(sender: AnyObject) {
        //弹出日历
        let dimView = UIView.init(frame: Utils.keyWindow.frame)
        Utils.keyWindow.addSubview(dimView)
        dimView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
 
        let calendar = SZCalendarPicker.showOnView(dimView)
        calendar.today = NSDate()
        calendar.date = calendar.today
        calendar.snp_makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(300)
            make.center.equalToSuperview()
        }
        calendar.backgroundColor = Utils.bgColor
        calendar.calendarBlock = {
            (day,month,year) in
            self.timeButton.setTitle(String.init(format: "%d-%02d-%02d", year,month,day), forState: .Normal)
                dimView.removeFromSuperview()
        }
        //执行动画，弹出视图，参数1：整个视图背景  参数2：主要显示的视图
        self.executeAnimation(dimView,mainView: calendar) {
            dimView.layoutSubviews()
        }
    }
    
    //MARK:选择消费项目的按钮
    @IBAction func chooseEventAction(sender: AnyObject) {
        //背景
        let dimView = UIView.init(frame: Utils.keyWindow.frame)
        Utils.keyWindow.addSubview(dimView)
        dimView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        if chooseEventVC == nil {
            chooseEventVC = TimeLineChooseEventController()
        }
        dimView.addSubview(chooseEventVC!.view)
        chooseEventVC!.view.snp_makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(300)
        }
        //选择内容之后的回调
        chooseEventVC!.chooseCompleteClosure = {
            (event,parentIndex,childIndex) in
            //参数说明：消费项目类、父目录选中下标、子目录选中下标
            self.event = event
            self.parentIndex = parentIndex
            self.childIndex = childIndex
            self.eventButton.setTitle((self.event?.parentName)!+" - "+(self.event?.eventName)!, forState: .Normal)
        }
        chooseEventVC!.defaultSelect(self.parentIndex, childIndex: self.childIndex)
        //弹出视图
        self.executeAnimation(dimView, mainView: chooseEventVC!.view) { 
            dimView.layoutSubviews()
        }
        
        
    }
    
    
    //MARK:提交表单
    @IBAction func submitAction(sender: AnyObject) {
        let time = Utils.isNullString((self.timeButton.titleLabel?.text)!)
        let cost = Utils.isNullString(self.costTextField.text!)
        let mark = Utils.isNullString(self.markTextView.text!)
        if time.0 {
            Utils.showHUDWithMessage(NSLocalizedString("AddRecordViewController.error.time", comment: "请选择时间"), time: 1, block: {})
            return
        }else if self.event == nil{
            Utils.showHUDWithMessage(NSLocalizedString("AddRecordViewController.error.event", comment: "请选择消费项目"), time: 1, block: {})
            return
        }else if cost.0{
            Utils.showHUDWithMessage(NSLocalizedString("AddRecordViewController.error.cost", comment: "请填写消费金额"), time: 1, block: {})
            return
        }else if !Utils.validateNumber(self.costTextField.text!){
            Utils.showHUDWithMessage(NSLocalizedString("AddRecordViewController.placehold.cost", comment: "最多保留两位小数"), time: 1, block: {})
            return
        }else{
            self.timeButton.enabled = false //防止多次提交
            //显示保存加载进度条
            Utils.sharedInstance.showLoadingView(NSLocalizedString("AddRecordViewController.save.loading", comment: "保存中"))
            //表单验证成功，提交表单
            let testObj = AVObject.init(className: "TimeLineRecord")
            testObj.setObject("", forKey: "userId")
            testObj.setObject(time.1, forKey: "recordTime")
            //添加消费项目
            testObj.setObject(AVObject.init(className: "TimeLineEvent", objectId: self.event!.objectId), forKey: "eventObject")
            testObj.setObject(Float(cost.1), forKey: "recordCost")
            testObj.setObject(mark.1, forKey: "recordMark")
            testObj.saveInBackgroundWithBlock({ (saveResult, error) in
                Utils.sharedInstance.hud.hideAnimated(true)
                if saveResult{
                    self.clearTextContent()//保存成功之后清除内容
                    Utils.showHUDWithMessage(NSLocalizedString("AddRecordViewController.save.success", comment: "保存成功"), time: 1, block: {
                        //如果添加了选中日期的数据，则回调更新数据
                        if time.1 == self.addTimeString{
                            self.updateTimeLine!()
                        }
                    })
                }else{
                    Utils.showHUDWithMessage(error.localizedDescription, time: 2, block: {})
                }
                self.timeButton.enabled = true
            })
        }
    }

    //MARK:清除内容
    func clearTextContent(){
        self.costTextField.text = ""
        self.markTextView.text = ""
        //清除项目内容
        self.parentIndex = 0
        self.childIndex = 0
        self.event = nil
        self.eventButton.setTitle(NSLocalizedString("AddRecordViewController.error.event", comment: "请选择消费项目"), forState: .Normal)
    }
    
    //执行动画的方法
    func executeAnimation(parentView:UIView,mainView:UIView,block:executeInBlockClosure){
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseIn, animations: {
            block()
            }, completion: { (flag) in
                //添加一个关闭按钮
                let closeBtn = UIButton.init(type: .Custom)
                closeBtn.setImage(UIImage.init(named: "close"), forState: .Normal)
                //点击时，移除视图
                closeBtn.bk_addEventHandler({ (obj) in
                    parentView.removeFromSuperview()
                    
                    self.chooseEventVC = nil
                    }, forControlEvents: .TouchUpInside)
                parentView.addSubview(closeBtn)
                closeBtn.snp_makeConstraints { (make) in
                    make.right.equalToSuperview().offset(-3)
                    make.bottom.equalTo(mainView.snp_top).offset(-3)
                    make.height.equalTo(30)
                    make.width.equalTo(30)
                }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
