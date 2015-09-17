//
//  MyCustomButton.swift
//  Project2
//
//  Created by Tom Domenico on 4/1/15.
//  Copyright (c) 2015 Tom Domenico. All rights reserved.
//

import Foundation
import UIKit
class MyCustomButton: UIButton{
    
    var x:CGFloat?
    var y:CGFloat?
    var numLines = 0
    private var dotImage = UIImage(named: "dot.jpg")
    private var activeImage = UIImage(named: "active.jpg")
    private var invalidImage = UIImage(named: "invalid.jpg")
    private var active = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setImage(dotImage, forState: UIControlState.Normal)
        self.frame=frame
        self.x = frame.origin.x
        self.y = frame.origin.y
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func validPress(){
        if(!active){
            self.setImage(activeImage, forState: UIControlState.Normal)
            active = true
        }
        else{
            self.setImage(dotImage, forState: UIControlState.Normal)
            active = false
        }
    }
    
    func invalidPress(){
        self.setImage(invalidImage, forState: UIControlState.Normal)
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "endInvalid", userInfo: nil, repeats: false)
    }
    
    func endInvalid(){
        self.setImage(dotImage, forState: UIControlState.Normal)
    }
    
    func setNumLines(dotDistance: Int, xSize: Int, ySize: Int, xOffset: Int, yOffset: Int){
        if(self.x == CGFloat(dotDistance+xOffset) || self.x == CGFloat((xSize*dotDistance)+xOffset)){
            numLines++
        }
        if(self.y == CGFloat(dotDistance+yOffset)||self.y == CGFloat((ySize*dotDistance)+yOffset)){
            numLines++
        }
    }
}