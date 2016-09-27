//
//  TimeLineChooseEventController.swift
//  EasyGoing
//
//  Created by King on 16/9/27.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import SnapKit

//参数1：当前选中的消费类型  参数2：父目录的选中下标  参数2：子目录的选中下标
typealias chooseEventClosure = (TimeLineEvent,Int,Int) -> Void

class TimeLineChooseEventController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {

    var eventPickView:UIPickerView = UIPickerView()
    //加载中的视图
    let activity = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
    //数据源
    var dataSource = Utils.eventDataSource
    //父目录
    var parentEvent = [TimeLineEvent]()
    //子目录 -> ["objectId":[TimeLineEvent]]  通过父目录的objectId找到所有子目录的数组
    var childEvent = NSMutableDictionary()
    //当前选中的父目录下标 ， 和子目录下标
    var parentIndex = 0
    var childIndex = 0
    //回调，向上传值
    var chooseCompleteClosure:chooseEventClosure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(activity)
        activity.startAnimating()
        activity.snp_makeConstraints { (make) in
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.center.equalToSuperview()
        }
        //查询数据
        if self.dataSource == nil {
            //查询数据
            let query = AVQuery.init(className: "TimeLineEvent")
            //查询userId为空的数据
            query.whereKey("userId", equalTo: "")
            query.findObjectsInBackgroundWithBlock({ (objs, error) in
                if error == nil{
                    if objs.count > 0{//print("数据长度== \(objs.count)")
                        self.dataSource = [TimeLineEvent]()
                        let avObj = objs as! [AVObject]
                        for obj in avObj{
                            let model = TimeLineEvent()
                            model.objectId = obj.objectForKey("objectId") as! String
                            model.eventName = obj.objectForKey("eventName") as! String
                            //查询父目录id
                            if obj.objectForKey("parentId") != nil{
                                let parentObject = obj.objectForKey("parentId") as! AVObject
                                model.parentId = parentObject.objectForKey("objectId") as! String
                            }
                            if obj.objectForKey("userId") != nil{
                                model.userId = obj.objectForKey("userId") as! String
                            }
                            self.dataSource?.append(model)
                        }
                        //保存数据到本地
                        Utils.eventDataSource = self.dataSource
                        //配置数据源:将父目录和子目录分开
                        self.configDataSource()
                        //初始化视图
                        self.configPickView()
                    }else{
                        Utils.showHUDWithMessage("没有查询到数据", time: 1, block: {})
                    }
                }else{
                    Utils.showHUDWithMessage(error.localizedDescription, time: 2, block: {})
                }
            })
        }else{
            //设置pickView
            self.configDataSource()
            self.configPickView()
        }
    }
    
    //MARK:设置视图
    func configPickView(){
        self.activity.stopAnimating()
        self.activity.removeFromSuperview()
        self.eventPickView.delegate = self
        self.eventPickView.dataSource = self
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.eventPickView)
        self.eventPickView.snp_makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.size.equalToSuperview()
        }
    }
    
    //MARK:配置数据源
    func configDataSource(){
        self.parentEvent.removeAll()
        self.childEvent.removeAllObjects()
        //数据源有数据的情况下
        if self.dataSource?.count>0 {
            //得到父目录
            for model in self.dataSource! {
                if model.parentId == "" {
                    self.parentEvent.append(model)
                }
            }
            //得到子目录，通过父目录的objectId，查找所有的子目录
            for parentModel in self.parentEvent {
                var childArray = [TimeLineEvent]()
                for allModel in self.dataSource! {
                    if allModel.parentId == parentModel.objectId {
                        //设置父目录名称
                        allModel.parentName = parentModel.eventName
                        childArray.append(allModel)
                    }
                }
                //设置子目录的字典
                self.childEvent.setValue(childArray, forKey: parentModel.objectId)
            }
        }
    }
    
    //MARK:设置PickView的默认选中项
    func defaultSelect(parentIndex:Int,childIndex:Int){
        //设置组件1选中下标
        self.eventPickView.selectRow(parentIndex, inComponent: 0, animated: false)
        //设置当前父目录选中下标
        self.parentIndex = parentIndex
        //设置组件2选中下标
        self.eventPickView.selectRow(childIndex, inComponent: 1, animated: false)
        //设置子目录选中下标
        self.childIndex = childIndex
    }
    
    //MARK:UIPickView的代理方法
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return self.parentEvent.count
        }else{
            return self.childEvent[self.parentEvent[self.parentIndex].objectId]!.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return self.parentEvent[row].eventName
        }else{
            //根据父目录的objectId获取数组
            let childArray = self.childEvent.valueForKey(self.parentEvent[parentIndex].objectId) as! [TimeLineEvent]
            return childArray[row].eventName
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            if row != self.parentIndex {
                self.parentIndex = row
                //根据父目录的objectId获取数组
                let childArray = self.childEvent.valueForKey(self.parentEvent[parentIndex].objectId) as! [TimeLineEvent]
                if self.childIndex > childArray.count-1{
                    self.childIndex = childArray.count - 1
                }
                self.chooseCompleteClosure!(childArray[self.childIndex],self.parentIndex,self.childIndex)
                
                pickerView.reloadComponent(1)
            }
        }else{
            self.childIndex = row
            //根据父目录的objectId获取数组
            let childArray = self.childEvent.valueForKey(self.parentEvent[parentIndex].objectId) as! [TimeLineEvent]
            self.chooseCompleteClosure!(childArray[self.childIndex],self.parentIndex,self.childIndex)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
