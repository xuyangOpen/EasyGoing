//
//  AddRecordViewController.swift
//  EasyGoing
//
//  Created by King on 16/9/23.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import BlocksKit

class AddRecordViewController: UIViewController {
    //MARK:属性声明
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var eventTextField: UITextField!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var markTextView: UITextView!
    
    
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
        
         UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseIn, animations: {
         dimView.layoutSubviews()
         }, completion: nil)
 
    }
    
    //MARK:提交表单
    @IBAction func submitAction(sender: AnyObject) {
        let time = Utils.isNullString((self.timeButton.titleLabel?.text)!)
        let event = Utils.isNullString(self.eventTextField.text!)
        let cost = Utils.isNullString(self.costTextField.text!)
        let mark = Utils.isNullString(self.markTextView.text!)
        if time.0 {
            Utils.showHUDWithMessage(NSLocalizedString("AddRecordViewController.error.time", comment: "请选择时间"), time: 1, block: {})
            return
        }else if event.0{
            Utils.showHUDWithMessage(NSLocalizedString("AddRecordViewController.error.event", comment: "请填写消费项目"), time: 1, block: {})
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
            testObj.setObject(event.1, forKey: "recordEvent")
            testObj.setObject(Float(cost.1), forKey: "recordCost")
            testObj.setObject(mark.1, forKey: "recordMark")
            testObj.saveInBackgroundWithBlock({ (saveResult, error) in
                Utils.sharedInstance.hud.hideAnimated(true)
                if saveResult{
                    self.clearTextContent()//保存成功之后清除内容
                    Utils.showHUDWithMessage(NSLocalizedString("AddRecordViewController.save.success", comment: "保存成功"), time: 1, block: {})
                }else{
                    Utils.showHUDWithMessage(error.localizedDescription, time: 2, block: {})
                }
                self.timeButton.enabled = true
            })
        }
    }

    //MARK:清除内容
    func clearTextContent(){
        self.eventTextField.text = ""
        self.costTextField.text = ""
        self.markTextView.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
