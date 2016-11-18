//
//  LoginViewController.swift
//  EasyGoing
//
//  Created by King on 16/11/8.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import AVOSCloud

class LoginViewController: UIViewController,UITextFieldDelegate {
    
    //提示语
    let tipLabel = UILabel()
    //输入框
    let inputText = UITextField()
    let leftView = UIImageView()
    //登录按钮
    let loginBtn = UIButton()
    //注册按钮
    let registerBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Utils.bgColor
        
        self.setViews()
        
//        self.addAnimation()
        self.navigationController?.navigationBarHidden = true
    }
    
    //MARK:设置页面跳转动画
    func addAnimation(){
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.duration = 0.5
        transition.delegate = self
        transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.subtype = kCATransitionFromRight
        
        self.navigationController?.view.layer.addAnimation(transition, forKey: "NavAnimation")
    }
    
    deinit{
        print("登录界面已经释放")
    }
    
    //MARK:配置页面布局
    func setViews(){
        self.view.addSubview(tipLabel)
        self.view.addSubview(inputText)
        self.view.addSubview(loginBtn)
        self.view.addSubview(registerBtn)
        inputText.delegate = self
        //提示语
        tipLabel.text = "请输入登录口令"
        tipLabel.textColor = UIColor.blackColor()
        tipLabel.textAlignment = .Center
        tipLabel.font = UIFont.systemFontOfSize(16)
        tipLabel.snp_makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(Utils.scale(200))
        }
        
        leftView.image = UIImage.init(named: "lock")
        leftView.frame = CGRectMake(0, 0, CGFloat(Utils.scale(30)), CGFloat(Utils.scale(30)))
        //输入框
        inputText.font = UIFont.systemFontOfSize(16)
        inputText.placeholder = "不超过10个字符"
        inputText.secureTextEntry = true
        inputText.leftView = leftView
        inputText.leftViewMode = .Always
        inputText.borderStyle = .RoundedRect
        inputText.snp_makeConstraints { (make) in
            make.left.equalToSuperview().offset(Utils.scale(50))
            make.right.equalToSuperview().offset(-Utils.scale(50))
            make.top.equalTo(tipLabel.snp_bottom).offset(Utils.scale(20))
            make.height.equalTo(Utils.scale(40))
        }
        
        //登录按钮
        loginBtn.setTitle("开启", forState: .Normal)
        loginBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        loginBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        loginBtn.layer.cornerRadius = CGFloat(Utils.scale(20))
        loginBtn.layer.masksToBounds = true
        loginBtn.backgroundColor = Utils.allTintColor
        loginBtn.addTarget(self, action: #selector(loginAction), forControlEvents: .TouchUpInside)
        loginBtn.snp_makeConstraints { (make) in
            make.top.equalTo(inputText.snp_bottom).offset(Utils.scale(20))
            make.left.equalTo(inputText)
            make.height.equalTo(Utils.scale(40))
            make.width.equalTo(Utils.scale(100))
        }
        
        //注册按钮
        registerBtn.setTitle("NEW", forState: .Normal)
        registerBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        registerBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        registerBtn.layer.cornerRadius = CGFloat(Utils.scale(20))
        registerBtn.layer.masksToBounds = true
        registerBtn.backgroundColor = Utils.allTintColor
        registerBtn.addTarget(self, action: #selector(registerAction), forControlEvents: .TouchUpInside)
        registerBtn.snp_makeConstraints { (make) in
            make.top.equalTo(inputText.snp_bottom).offset(Utils.scale(20))
            make.right.equalTo(inputText)
            make.height.equalTo(Utils.scale(40))
            make.width.equalTo(Utils.scale(100))
        }
    }
    
    //UITextField代理方法限制输入长度为10
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.characters.count >= 10 {
            let str = NSString.init(string: textField.text!)
            inputText.text = str.substringToIndex(10)
        }
        return true
    }
    
    //MARK:登录方法
    func loginAction(){
        if inputText.text?.characters.count == 0 || inputText.text?.characters.count > 10 {
            Utils.showHUDWithMessage("口令长度不符合规范", time: 1.5, block: {})
        }else{
            let query = AVQuery.init(className: EGUser)
            query.whereKey("userOnlyKey", equalTo: inputText.text!)
            Utils.sharedInstance.showLoadingViewOnView("登录中", parentView: self.view)
            query.findObjectsInBackgroundWithBlock({ [weak self] (objects, error) in
                if error == nil{
                    if objects != nil && objects?.count > 0{
                        let avObject = objects![0] as! AVObject
                        let egUser = EGUserModel.initEGUserWithAVObject(avObject)
                        //用户登录
                        AVUser.logInWithUsernameInBackground(egUser.userOnlyKey, password: egUser.userUUID, block: { (avUser, error2) in
                            Utils.sharedInstance.hideLoadingView()
                            if error2 == nil{//登录成功
                                if egUser.isSet == "1"{//用户数据已设置，跳转到主界面
                                    let homeVC = HomeViewController()
                                    self?.navigationController?.pushViewController(homeVC, animated: true)
                                }else{//用户数据未设置，跳转到配置页面
                                    self?.navigationController?.pushViewController(SettingsController(), animated: true)
                                }
                            }else{//登录失败
                                Utils.showHUDWithMessage(error!.localizedDescription, time: 2, block: {})
                            }
                        })
                    }else{//用户登录口令不存在
                        Utils.sharedInstance.hideLoadingView()
                        Utils.showHUDWithMessage("登录口令不存在", time: 2, block: {})
                    }
                }else{//查询用户信息出错
                    Utils.sharedInstance.hideLoadingView()
                    Utils.showHUDWithMessage(error!.localizedDescription, time: 2, block: {})
                }
            })
        }
    }
    
    //MARK:注册方法
    func registerAction(){
        if inputText.text?.characters.count == 0 || inputText.text?.characters.count > 10 {
            Utils.showHUDWithMessage("口令长度不符合规范", time: 1.5, block: {})
        }else{
            inputText.resignFirstResponder()
            Utils.showJCAlert("提示", tips: "是否使用 '" + inputText.text! + "' 口令注册EasyGoing", complete: {
                let userObj = AVObject.init(className: EGUser)
                let uuid = RandomString.uuidString()
                userObj.setObject(self.inputText.text, forKey: "userOnlyKey")
                userObj.setObject(uuid, forKey: "userUUID")
                userObj.setObject("0", forKey: "isSet")
                Utils.sharedInstance.showLoadingViewOnView("数据请求中", parentView: self.view)
                //保存用户
                userObj.saveInBackgroundWithBlock { [weak self] (flag, error) in
                    if error == nil{
                        //注册用户
                        let newUser = AVUser()
                        newUser.username = self?.inputText.text
                        newUser.password = uuid
                        newUser.signUpInBackgroundWithBlock({ [weak self] (flag2, error2) in
                            if error2 == nil{
                                //注册成功后，开始登录
                                AVUser.logInWithUsernameInBackground(newUser.username!, password: newUser.password!, block: { (avUser, error3) in
                                    if error3 == nil{
                                        //跳转到配置页面
                                        self?.navigationController?.pushViewController(SettingsController(), animated: true)
                                    }else{
                                        Utils.sharedInstance.hideLoadingView()
                                        Utils.showHUDWithMessage(error!.localizedDescription, time: 2, block: {})
                                    }
                                })
                            }else{
                                //注册失败，则删除当前用户
                                AVQuery.doCloudQueryWithCQL("delete from eg_user where objectId = '" + userObj.objectId! + "'")
                                
                                Utils.sharedInstance.hideLoadingView()
                                //Username has already been taken
                                var errorMsg = NSString.init(string: error2!.localizedDescription)
                                if errorMsg.containsString("存在") || errorMsg.containsString("Username has already been taken"){
                                    errorMsg = "登录口令已经存在"
                                }
                                Utils.showHUDWithMessage(errorMsg as String, time: 2, block: {})
                            }
                            })
                        
                    }else{
                        Utils.sharedInstance.hideLoadingView()
                        Utils.showHUDWithMessage(error!.localizedDescription, time: 2, block: {})
                    }
                }
            })
        }
    }
    
    
}
