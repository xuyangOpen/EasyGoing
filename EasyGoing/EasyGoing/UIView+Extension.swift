//
//  UIView+Extension.swift
//  EasyGoing
//
//  Created by King on 16/11/3.
//  Copyright © 2016年 kf. All rights reserved.
//

import Foundation

private var tapKey = ""
typealias viewTapClosure = ((view:UIView) -> Void)?

class ViewClosureWrapper<T> {
    var closure: T?
    init(_ closure: T?) {
        self.closure = closure
    }
}

extension UIView{
    
    func viewWhenTapClosure(tapClosure:viewTapClosure){
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(viewTapAction(_:)))
        self.addGestureRecognizer(tapGesture)
        if tapClosure != nil {
            objc_setAssociatedObject(self, &tapKey, ViewClosureWrapper<viewTapClosure>(tapClosure), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc private func viewTapAction(sender:UIView){
        let tapClosure = (objc_getAssociatedObject(self, &tapKey) as? ViewClosureWrapper<viewTapClosure>)!.closure
        
        if tapClosure != nil {
            tapClosure!!(view: sender)
        }
        
        
    }
}
