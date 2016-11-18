//
//  UIButton+Custom.swift
//  PromotedBySwift
//
//  Created by bluedaquiri on 16/9/12.
//  Copyright © 2016年 blue. All rights reserved.
//

import UIKit

private var buttonClickKey = ""
typealias buttonClickClosure = ((button: UIButton) -> Void)?

class ClosureWrapper<T> {
    var closure: T?
    init(_ closure: T?) {
        self.closure = closure
    }
}

extension UIButton {
    func buttonClickWithClosure(buttonClosure: buttonClickClosure) {
        self.addTarget(self, action:#selector(self.buttonClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        if (buttonClosure != nil) {
            objc_setAssociatedObject(self, &buttonClickKey, ClosureWrapper<buttonClickClosure>(buttonClosure), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc private func buttonClick(sender: UIButton) {
        let buttonClosure = (objc_getAssociatedObject(self, &buttonClickKey) as? ClosureWrapper<buttonClickClosure>)!.closure
        if (buttonClosure != nil) {
            buttonClosure!!(button: sender)
        }
    }
}