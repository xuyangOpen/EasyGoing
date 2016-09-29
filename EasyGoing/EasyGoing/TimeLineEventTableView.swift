//
//  TimeLineEventTableView.swift
//  EasyGoing
//
//  Created by King on 16/9/28.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class TimeLineEventTableView: UITableView {

    //子目录中的菜单打开的cell
    var openingCell:TimeLineEventCell?
    
    //父目录中菜单打开的视图
    var parentView:UIScrollView?
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        //原本点击的视图
        let originView = super.hitTest(point, withEvent: event)
        if openingCell != nil || parentView != nil{
            
            if openingCell != nil {
                //将self视图上的触摸点，转换为openingCell上的触摸点
                let convertPoint = self.convertPoint(point, toView: openingCell)
                //如果当前触摸点不在openingCell视图上，则设置属性为false，关闭菜单
                //如果在视图上，则可以点击视图上的操作按钮
                let isInside = openingCell?.pointInside(convertPoint, withEvent: event)
                if !isInside! {
                    self.userInteractionEnabled = false
                }else{
                    //就算当前点在本身视图上，也不可以滑动
                    self.scrollEnabled = false
                    self.performSelector(#selector(allowScroll), withObject: nil, afterDelay: 0.25)
                }
            }
            //定义一个变量用来控制是否关闭父目录菜单
            //如果点击事件发生在父目录视图上，则由父目录视图自己控制
            //如果点击事件没有发生在父目录视图上，则由hitTest方法控制
            if parentView != nil {
                let convertPoint = self.convertPoint(point, toView: parentView)
                let isInside = parentView?.pointInside(convertPoint, withEvent: event)
                if !isInside! {
                //    print("hittest控制父目录的关闭")
                    self.userInteractionEnabled = false
                }else{
                    //就算当前点在本身视图上，也不可以滑动
                    self.scrollEnabled = false
                    self.performSelector(#selector(allowScroll), withObject: nil, afterDelay: 0.25)
                //    print("父目录自己控制关闭菜单")
                    if parentView?.subviews.count > 0 {
                        for subview in (parentView?.subviews)! {
                            if subview is UIButton {
                                let btnPoint = self.convertPoint(point, toView: subview)
                                let inside = subview.pointInside(btnPoint, withEvent: event)
                                if inside {
                                    //如果是按钮，则返回按钮本身
                                    return subview
                                }
                            }
                        }
                    }
                    //如果不是点击在按钮上，则返回UIScrollView
                    return parentView
                }
            }
            //点击任意位置关闭菜单
            self.closeMenu(true)
            //如果有打开的菜单，则返回本身
            return self
        }else{
            return originView
        }
    }
    
    func closeMenu(closeParentView:Bool){
        if self.openingCell != nil {
            self.openingCell?.closeMenu()
            self.openingCell = nil
        }
        if closeParentView {
            if self.parentView != nil {
                self.parentView?.setContentOffset(CGPointMake(0, 0), animated: true)
                self.parentView = nil
            }
        }
        self.performSelector(#selector(allowEnable), withObject: nil, afterDelay: 0.25)
    }
    
    //允许用户操作
    func allowEnable(){
        self.userInteractionEnabled = true
    }
    
    //允许用户滑动
    func allowScroll(){
        self.scrollEnabled = true
    }

}
