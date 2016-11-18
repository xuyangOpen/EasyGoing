//
//  NSString+LCCalcSize.swift
//  PromotedBySwift
//
//  Created by bluedaquiri on 16/9/12.
//  Copyright © 2016年 blue. All rights reserved.
//

import UIKit

extension String {
    /**< font -> size */
    func sizeWithCalcFont(font: UIFont) -> CGSize {
        var calcSize = CGSizeZero
        calcSize = self.sizeWithAttributes([NSFontAttributeName : font])
        return calcSize
    }
    
    /**< font/size -> size */
    func sizeWithCalcFontToConstrainedSize(font: UIFont, constrainedSize: CGSize) -> CGSize {
        var calcSize = CGSizeZero
        calcSize = self.boundingRectWithSize(constrainedSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).size
        return calcSize
    }
    
    /**< font -> height */
    func contentofHeightWithFont(font: UIFont) -> CGFloat {
        let contentOfSize = "计算".sizeWithCalcFontToConstrainedSize(font, constrainedSize: CGSizeMake(100, CGFloat(MAXFLOAT))).height
        return contentOfSize
    }
}