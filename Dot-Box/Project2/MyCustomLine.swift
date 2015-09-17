//
//  MyCustomLine.swift
//  Project2
//
//  Created by SAITS Manage Account on 5/1/15.
//  Copyright (c) 2015 Tom Domenico. All rights reserved.
//

import Foundation
import UIKit
class MyCustomLine: UIImageView{
    var lineImage = UIImage(named: "line.png")
    //self.image = lineImage
    
    override init(frame: CGRect) {
        super.init(frame: CGRect())
        self.frame = frame
        self.image = lineImage
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
