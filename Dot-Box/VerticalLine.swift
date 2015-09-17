//
//  VerticalLine.swift
//  Project2
//
//  Created by SAITS Manage Account on 5/1/15.
//  Copyright (c) 2015 Tom Domenico. All rights reserved.
//

import Foundation
import UIKit
class VerticalLine: UIImageView{
    var lineImage = UIImage(named: "vertLine.png")
    var x:CGFloat?
    var y:CGFloat?
    var isNil = false
    
    override init(frame: CGRect) {
        super.init(frame: CGRect())
        self.frame = frame
        self.x = frame.origin.x
        self.y = frame.origin.y
        if(self.x == -1){
            isNil = true
        }
        self.image = lineImage
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}