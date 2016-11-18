//
//  UIViewExtension.swift
//  PromotedBySwift
//
//  Created by bluedaquiri on 16/9/12.
//  Copyright © 2016年 blue. All rights reserved.
//

import UIKit

extension UIView {
    /**< getSetForFrame */
    var origin_x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            self.frame = CGRectMake(newValue, self.frame.origin.y, self.frame.size.width, self.frame.size.height)
        }
    }
    
    var origin_y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            self.frame = CGRectMake(self.frame.origin.x, newValue, self.frame.size.width, self.frame.size.height)
        }
    }
    
    var size_width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newValue, self.frame.size.height)
        }
    }
    
    var size_height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newValue)
        }
    }
    
    var center_x: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width / 2.0
        }
        set {
             self.frame = CGRectMake(center_x - self.size_width / 2.0, self.origin_y, self.size_width, self.size_height)
        }
    }
    
    var center_y: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height / 2.0
        }
        set {
             self.frame = CGRectMake(self.origin_x, center_y - self.size_height / 2.0, self.size_width, self.size_height)
        }
    }
    
    /**< roundedRectangle*/
    func makeRoundedRectangleShape(cornerRadius: CGFloat) {
        assert(!(self.size_width == 0 && self.size_height == 0), "assert: view need set bounds For Clip")
        let width = self.size_width
        let height = self.size_height
        let circleRadius = min(width, height)
        var radius = cornerRadius
        if cornerRadius == -1 {
            radius = circleRadius
        }        
        let maskBezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSizeMake(radius, radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskBezierPath.CGPath
        self.layer.mask = maskLayer
    }
    
    /**
     Generates the affine transform for transforming the first CGRect into the second one
     
     - parameter frame:   CGRect to transform from
     - parameter toFrame: CGRect to transform to
     
     - returns: CGAffineTransform that transforms the first CGRect into the second
     */
    func CGAffineTransformMakeRectToRect(frame: CGRect, toFrame: CGRect) -> CGAffineTransform {
        let scale = toFrame.size.width / frame.size.width
        let tx = toFrame.origin.x + toFrame.width / 2 - (frame.origin.x + frame.width / 2)
        let ty = toFrame.origin.y - frame.origin.y * scale * 2
        let translation = CGAffineTransformMakeTranslation(tx, ty)
        let scaledAndTranslated = CGAffineTransformScale(translation, scale, scale)
        return scaledAndTranslated
    }

}
