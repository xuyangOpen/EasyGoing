//
//  HomeTabBarController.swift
//  EasyGoing
//
//  Created by King on 16/8/29.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class HomeTabBarController: UITabBarController,HcdPopMenuViewDelegate,TabBarViewDelegate {
    //
    var didRemoveSubviews = false
    
    override func viewWillAppear(animated: Bool) {
        if !didRemoveSubviews {
            for subview in self.tabBar.subviews {
                subview.removeFromSuperview()
            }
            didRemoveSubviews = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //创建一个表，并保存一条数据
        //        let testObj = AVObject.init(className: "TestObject")
        //        testObj.setObject("lily", forKey: "name")
        //        testObj.save()
        
        let selectedImageArray = ["classlist_bar_selected","teacher_bar_selected","class_bar_selected","me_bar_selected"]
        let unSelectedImageArray = ["classlist_bar_unselected","teacher_bar_unselected","class_bar_unselected","me_bar_unselected"]
        let selectedColor = UIColor.orangeColor()
        let textArray = ["新闻","趣闻乐事","大事件","呵呵哒哒"]
        
        let itemView = TabBarView.init(frame: CGRectMake(0, Utils.screenHeight-49, Utils.screenWidth, 49), selectedImageArray: selectedImageArray, unSelectedImageArray: unSelectedImageArray, textArray: textArray, textSelectedColor: selectedColor)
        //设置代理
        itemView?.delegate = self
        let btn = UIButton()
        btn.setTitle("弹弹", forState: .Normal)
        btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btn.addTarget(self, action: #selector(btnClick), forControlEvents: .TouchUpInside)
        itemView?.centerView = btn
        
        self.view.addSubview(itemView!)
    }
    
    func btnClick(){
        /*添加菜单项*/
        let array: [AnyObject] = [[kHcdPopMenuItemAttributeTitle: "添加", kHcdPopMenuItemAttributeIconImageName: "wechat"], [kHcdPopMenuItemAttributeTitle: "微博", kHcdPopMenuItemAttributeIconImageName: "weibo"],[kHcdPopMenuItemAttributeTitle: "QQ空间", kHcdPopMenuItemAttributeIconImageName: "qqzone"]]
        
        /*调用*/
        HcdPopMenuView.createPopmenuItems(array, closeImageName: "center_exit", backgroundImageUrl: nil, tipStr: "", completionBlock: nil, delegate: self)
    }
    
    //代理方法：弹出层点击按钮事件
    func didClickBtn(index: Int32) {
        print("点触的是第\(index)个")
    }
    
    //代理方法：TabBar
    func changeControllers(index: Int) {
        self.selectedIndex = index
    }
    
}
