//
//  SearchModel.swift
//  EasyGoing
//
//  Created by King on 16/11/23.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class SearchModel: NSObject,NSCoding {

    var placeKey = ""
    var cityKey = ""
    var districtKey = ""
    var ptInfo:NSValue!
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.placeKey = aDecoder.decodeObjectForKey("placeKey") as! String
        self.cityKey = aDecoder.decodeObjectForKey("cityKey") as! String
        self.districtKey = aDecoder.decodeObjectForKey("districtKey") as! String
        self.ptInfo = NSValue.init(CGPoint: aDecoder.decodeCGPointForKey("ptInfo"))
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.placeKey, forKey: "placeKey")
        aCoder.encodeObject(self.cityKey, forKey: "cityKey")
        aCoder.encodeObject(self.districtKey, forKey: "districtKey")
        aCoder.encodeCGPoint(self.ptInfo.CGPointValue(), forKey: "ptInfo")
    }
    
}
