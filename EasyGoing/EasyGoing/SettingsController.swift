//
//  SettingsController.swift
//  EasyGoing
//
//  Created by King on 16/11/10.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import AVOSCloud

class SettingsController: UIViewController {
    
    var saveSuccessCount = 0{
        didSet{
            if saveSuccessCount == 3 {
                self.userDataComplete()
            }
        }
    }
    //计时器
    var timer:NSTimer?
    var clock = 5//至少在页面停止5秒钟
    var userOperationComplete = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.cleanMenu()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(enableJump), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Utils.sharedInstance.showHourGlassOnView(self.view)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        Utils.sharedInstance.hideHourGlass()
    }
    
    //MARK:清除用户的所有目录数据
    func cleanMenu(){
        let query = AVQuery.init(className: "TimeLineEvent")
        query.whereKey("userId", equalTo: AVUser.currentUser()!.objectId!)
        query.findObjectsInBackgroundWithBlock { [weak self] (objects, error) in
            if error == nil{
                if objects != nil && objects?.count > 0{
                    AVObject.deleteAllInBackground(objects!, block: { (flag, error) in
                        if error == nil{
                            //数据清除完成之后，开始配置用户数据
                            self?.configUserDefaultData()
                        }else{
                            Utils.showHUDWithMessage(error!.localizedDescription, time: 2, block: {
                                //回到登录界面
                                self?.navigationController?.popViewControllerAnimated(true)
                            })
                        }
                    })
                }else{
                    //数据清除完成之后，开始配置用户数据
                    self?.configUserDefaultData()
                }
            }else{
                Utils.showHUDWithMessage(error!.localizedDescription, time: 2, block: {
                    //回到登录界面
                    self?.navigationController?.popViewControllerAnimated(true)
                })
            }
        }
    }
    
    //MARK:配置用户默认数据
    func configUserDefaultData(){
        //父目录数组
        var parentArray = [AVObject]()
        //子目录数组
        var childArray1 = [AVObject]()
        var childArray2 = [AVObject]()
        var childArray3 = [AVObject]()
        
        let obj = AVObject.init(className: "TimeLineEvent")
        obj.setObject("投资", forKey: "eventName")
        obj.setObject(AVUser.currentUser()?.objectId!, forKey: "userId")
        
        let obj1 = AVObject.init(className: "TimeLineEvent")
        obj1.setObject("购物", forKey: "eventName")
        obj1.setObject(AVUser.currentUser()?.objectId!, forKey: "userId")
        
        let obj2 = AVObject.init(className: "TimeLineEvent")
        obj2.setObject("出行", forKey: "eventName")
        obj2.setObject(AVUser.currentUser()?.objectId!, forKey: "userId")
        
        parentArray.append(obj)
        parentArray.append(obj1)
        parentArray.append(obj2)
        
        //保存父目录
        AVObject.saveAllInBackground(parentArray) { [weak self] (flag1, error1) in
            if error1 == nil{
                //创建 '投资' 的子项
                let investArray = ["股票","国债","保险"]
                for i in 0..<investArray.count{
                    let child = AVObject.init(className: "TimeLineEvent")
                    child.setObject(investArray[i], forKey: "eventName")
                    child.setObject(AVUser.currentUser()?.objectId!, forKey: "userId")
                    child.setObject(AVObject.init(className: "TimeLineEvent", objectId: obj.objectId!), forKey: "parentId")
                    childArray1.append(child)
                }
                
                //保存子项
                AVObject.saveAllInBackground(childArray1, block: { (flag2, error2) in
                    if error2 == nil{
                        self?.saveSuccessCount += 1
                    }else{
                        Utils.showHUDWithMessage(error2!.localizedDescription, time: 2, block: {
                            //回到登录界面
                            self?.navigationController?.popViewControllerAnimated(true)
                        })
                    }
                })
                
                //创建 '购物' 的子项
                let shopArray = ["商场购物","礼物","家居用品","网购"]
                for i in 0..<shopArray.count{
                    let shopChild = AVObject.init(className: "TimeLineEvent")
                    shopChild.setObject(shopArray[i], forKey: "eventName")
                    shopChild.setObject(AVUser.currentUser()?.objectId!, forKey: "userId")
                    shopChild.setObject(AVObject.init(className: "TimeLineEvent", objectId: obj1.objectId!), forKey: "parentId")
                    childArray2.append(shopChild)
                }
                
                AVObject.saveAllInBackground(childArray2, block: { (flag, error) in
                    if error == nil{
                        self?.saveSuccessCount += 1
                    }else{
                        Utils.showHUDWithMessage(error!.localizedDescription, time: 2, block: {
                            //回到登录界面
                            self?.navigationController?.popViewControllerAnimated(true)
                        })
                    }
                })
                
                //创建 '出行' 的子项
                let outArray = ["打车","票价"]
                for i in 0..<outArray.count{
                    let outChild = AVObject.init(className: "TimeLineEvent")
                    outChild.setObject(outArray[i], forKey: "eventName")
                    outChild.setObject(AVUser.currentUser()?.objectId!, forKey: "userId")
                    outChild.setObject(AVObject.init(className: "TimeLineEvent", objectId: obj2.objectId!), forKey: "parentId")
                    childArray3.append(outChild)
                }
                
                AVObject.saveAllInBackground(childArray3, block: { (flag, error) in
                    if error == nil{
                        self?.saveSuccessCount += 1
                    }else{
                        Utils.showHUDWithMessage(error!.localizedDescription, time: 2, block: {
                            //回到登录界面
                            self?.navigationController?.popViewControllerAnimated(true)
                        })
                    }
                })
                
                
            }else{
                Utils.showHUDWithMessage(error1!.localizedDescription, time: 2, block: {
                    //回到登录界面
                    self?.navigationController?.popViewControllerAnimated(true)
                })
            }
        }
    }
    
    //MARK:用户信息配置完成后，设置配置完成的属性
    func userDataComplete(){
        //将用户的配置记录保存下来
        let egUserQuery = AVQuery.init(className: EGUser)
        egUserQuery.whereKey("userOnlyKey", equalTo: AVUser.currentUser()!.username!)
        egUserQuery.findObjectsInBackgroundWithBlock({ [weak self] (egUsers, error3) in
            if error3 == nil{
                if egUsers != nil && egUsers?.count > 0{
                    let egUserModel = egUsers![0] as! AVObject
                    AVQuery.doCloudQueryInBackgroundWithCQL("update eg_user set isSet='1' where objectId='" + egUserModel.objectId! + "'", callback: { (reuslt, err) in
                        if err == nil{//创建成功，跳转到首页
                            self?.userOperationComplete = true
                        }else{
                            Utils.showHUDWithMessage(err!.localizedDescription, time: 2, block: {
                                //回到登录界面
                                self?.navigationController?.popViewControllerAnimated(true)
                            })
                        }
                    })
                    
                }
            }else{
                Utils.showHUDWithMessage(error3!.localizedDescription, time: 2, block: {
                    //回到登录界面
                    self?.navigationController?.popViewControllerAnimated(true)
                })
            }
        })
    }
    
    //最少在页面停留clock秒钟
    func enableJump(){
        clock = clock - 1
        if clock <= 0 && userOperationComplete{
            timer?.invalidate()
            timer = nil
            self.navigationController?.pushViewController(HomeViewController(), animated: true)
        }
    }
    
}
