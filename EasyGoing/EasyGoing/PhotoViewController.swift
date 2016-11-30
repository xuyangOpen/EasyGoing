//
//  PhotoViewController.swift
//  EasyGoing
//
//  Created by King on 16/11/29.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    //消息控制器
    let messageController = MessageController()
    
    let btn = UIButton()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //显示导航栏
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        //状态栏为黑色
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(messageController.view)
     
        messageController.view.snp_makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSizeMake(150, 100))
        }
        
        btn.setTitle("添加", forState: .Normal)
        btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btn.addTarget(self, action: #selector(addMsg), forControlEvents: .TouchUpInside)
        self.view.addSubview(btn)
        btn.snp_makeConstraints { (make) in
            make.top.equalTo(messageController.view.snp_bottom).offset(50)
            make.centerX.equalTo(messageController.view)
            make.size.equalTo(CGSizeMake(50, 50))
        }
    }
    
    func addMsg(){
        let msg = arc4random_uniform(100000000)
        print("添加一条\(msg)消息")
        messageController.addMessage("\(msg)")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
