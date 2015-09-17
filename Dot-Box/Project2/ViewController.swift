//
//  ViewController.swift
//  Project2
//
//  Created by Tom Domenico on 4/1/15.
//  Copyright (c) 2015 Tom Domenico. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate{
    //all the dots, and lines created in the game
    var dots: [MyCustomButton] = []
    var vertLines: [VerticalLine] = []
    var horzLines: [HorizontalLine] = []
    var boxes: [UIImageView] = []
    var freeHorzPoints: [(CGFloat,CGFloat)] = []
    var freeVertPoints: [(CGFloat,CGFloat)] = []
    var freeHorzPointsNoScore: [(CGFloat,CGFloat)] = []
    var freeVertPointsNoScore: [(CGFloat,CGFloat)] = []
    
    //completed boxes, and if a box was made this turn
    var boxLocations:[(CGFloat,CGFloat)] = []
    var boxMade = false //true when box has been made
    
    //first dot clicked each turn
    var active = false //True if one dot has been selected  so far in the turn
    var activeDot = MyCustomButton(frame: CGRectMake(1000, 1000, 20, 20)) //temp dot when game starts
    var tempDot = MyCustomButton(frame: CGRectMake(-1, -1, 20, 20))
    var tempVertLine = VerticalLine(frame: CGRectMake(-1, -1, 20, 20))
    var tempHorzLine = HorizontalLine(frame: CGRectMake(-1, -1, 20, 20))
    
    //used to initialize dot positions
    var yOffset = 50 //offsets dot gird on the y axis
    var xOffset = 0 //offsets dot gird on the x axis
    var xSize = 6 //number of columns of dots, 6 is full size
    var ySize = 10 //number of rows of dots, 10 is full size
    var dotDistance = 50 //distance between dots
    var canEditBoard = true
    
    //player label, score, and turn info
    var color = UIColor.yellowColor() //background color of player/score lable when it's that players turn
    var player1Turn = true // false when it's player 2's turn
    @IBOutlet weak var player1Label: UILabel! //name label for player 1
    @IBOutlet weak var player1ScoreLabel: UILabel! //score label for player 1
    @IBOutlet weak var player2Label: UILabel! //name label for player 2
    @IBOutlet weak var player2ScoreLabel: UILabel! //score label for player 2
    
    //AI
    @IBOutlet weak var npcLabel: UILabel!
    @IBOutlet weak var npcSlider: UISlider!
    var npcEasy = false
    var npcMedium = false
    var npcHard = true
    
    //size of board text fields
    @IBOutlet weak var numberOfRows: UITextField! //right
    @IBOutlet weak var numberOfColumns: UITextField!//left
    
    var singlePlayer = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //restartGame()
    }
    override func viewDidAppear(animated: Bool) {
        restartGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func changeDifficulty(sender: UISlider) {
        if(sender.value<=1){
            self.npcEasy = true
            self.npcMedium = false
            self.npcHard = false
        }
        else if(sender.value<=2){
            self.npcEasy = false
            self.npcMedium = true
            self.npcHard = false
        }
        else{
            self.npcEasy = false
            self.npcMedium = false
            self.npcHard = true
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool { //gets called everytime text field is changed
        let text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string) //text we just typed (not yet shown in text field
        if(text == ""){
            if(textField == self.numberOfColumns){
                self.xSize = 0
            }
            else{
                self.ySize = 0
            }
            removeDots() //clear board
            return true //replace textField.text with variable text
        }
        else if let num = text.toInt(){
            if(textField == self.numberOfColumns){
                if(num > 5){
                    textField.text = "5"
                    self.xSize = 6
                }
                else if(num < 1){
                    textField.text = "1"
                    self.xSize = 2
                }
                else{
                    textField.text = text
                    self.xSize = num+1
                }
            }
            else{
                if(num > 9){
                    textField.text = "9"
                    self.ySize = 10
                }
                else if(num < 1){
                    textField.text = "1"
                    self.ySize = 2
                }
                else{
                    textField.text = text
                    self.ySize = num+1
                }
            }
        }
        addDots() //create board
        return false
    }
    
    @IBAction func restartGame(sender: AnyObject) {
        let controller = UIAlertController(title: "Restart Game", message: "Are you sure you want to restart the game?", preferredStyle: UIAlertControllerStyle.Alert)
        let action1 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let action2 = UIAlertAction(title: "Restart", style: UIAlertActionStyle.Destructive) { (action: UIAlertAction!) -> Void in
            // this is what happens when "Restart" is selected
            self.restartGame()
        }
        controller.addAction(action1)
        controller.addAction(action2)
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func pressed(sender: MyCustomButton){
        if((self.singlePlayer && self.player1Turn) || !self.singlePlayer){
            if(!active){
                if(sender.numLines<4){
                    active = true
                    activeDot = sender
                    sender.validPress()
                }
                else{
                    sender.invalidPress()
                }
            }
            else{
                if(sender == activeDot){
                    active = false
                    sender.validPress()
                }
                else if(abs(sender.x! - activeDot.x!) == 50 && sender.y! - activeDot.y! == 0){ //determine whether to try and place horizontal line
                    if(sender.x!>activeDot.x!){ //find which dot has the lower x value and try to make line at that point
                        if(!createHorzLine(activeDot,dot2:sender)){ //if we could not create horizontal line indicate invalid
                            sender.invalidPress()
                        }
                        else{ //created new horizontal line
                            newTurn()
                        }
                    }
                    else{
                        if(!createHorzLine(sender,dot2:activeDot)){
                            sender.invalidPress()
                        }
                        else{
                            newTurn()
                        }
                    }
                }
                else if(abs(sender.y! - activeDot.y!) == 50 && sender.x! - activeDot.x! == 0){ //determine whether to try and place vertical line
                    if(sender.y!>activeDot.y!){ //find which dot has the lower y value and try to make line at that point
                        if(!createVertLine(activeDot,dot2:sender)){ //if we could not create vertical line indicate invalid
                            sender.invalidPress()
                        }
                        else{ //created new vertical line
                            newTurn()
                        }
                    }
                    else{
                        if(!createVertLine(sender,dot2:activeDot)){
                            sender.invalidPress()
                        }
                        else{
                            newTurn()
                        }
                    }
                }
                else{
                    sender.invalidPress()
                }
            }
        }
    }
    
    
    func createVertLine(dot1:MyCustomButton, dot2:MyCustomButton)->Bool{
        for line in self.vertLines{
            if(line.x == dot1.x && line.y == dot1.y){
                return false
            }
        }
        var line = VerticalLine(frame: CGRect(x: dot1.x!, y: dot1.y!, width: 20, height: 70))
        self.vertLines.append(line)
        self.view.addSubview(line)
        remove(dot1.x!,y: dot1.y!,list: &self.freeVertPoints)
        dot1.numLines++
        dot2.numLines++
        canCreateVertBox(line)
        return true
    }
    
    func createHorzLine(dot1:MyCustomButton, dot2:MyCustomButton)->Bool{
        for line in self.horzLines{
            if(line.x == dot1.x && line.y == dot1.y){
                return false
            }
        }
        var line = HorizontalLine(frame: CGRect(x: dot1.x!, y: dot1.y!, width: 70, height: 20))
        self.horzLines.append(line)
        self.view.addSubview(line)
        remove(dot1.x!,y: dot1.y!,list: &self.freeHorzPoints)
        dot1.numLines++
        dot2.numLines++
        canCreateHorzBox(line)
        return true
    }
    
    func newTurn(){
        if((self.singlePlayer && player1Turn) || !self.singlePlayer){
            active = false
            activeDot.validPress()
        }
        if(!self.boxMade){
            player1Turn = !player1Turn
            if(player1Turn){
                player1Label.backgroundColor = self.color
                player1ScoreLabel.backgroundColor = self.color
                player2Label.backgroundColor = nil
                player2ScoreLabel.backgroundColor = nil
            }
            else{
                player2Label.backgroundColor = self.color
                player2ScoreLabel.backgroundColor = self.color
                player1Label.backgroundColor = nil
                player1ScoreLabel.backgroundColor = nil
                if(self.singlePlayer){
                    var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "npcStart", userInfo: nil, repeats: false)
                }
            }
        }
        else{
            self.boxMade = false
            if(self.singlePlayer && !self.player1Turn){
                var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "npcStart", userInfo: nil, repeats: false)
            }
        }
        if(self.canEditBoard){
            self.canEditBoard = false
            self.numberOfColumns.enabled = false
            self.numberOfRows.enabled = false
        }
    }
    
    func canCreateVertBox(line:VerticalLine){
        if(checkForRightBoxWithVertLine(line.x!, y: line.y!)){
            createBox(line.x!+20, y: line.y!+20)
        }
        if(checkForLeftBoxWithVertLine(line.x!, y: line.y!)){
            createBox(line.x!-30, y: line.y!+20)
        }
        
    }
    
    func canCreateHorzBox(line:HorizontalLine){
        if(checkForBottomBoxWithHorzLine(line.x!, y: line.y!)){
            createBox(line.x!+20, y: line.y!+20)
        }
        if(checkForTopBoxWithHorzLine(line.x!, y: line.y!)){
            createBox(line.x!+20, y: line.y!-30)
        }
    }
    
    func createBox(/*image:UIImage,*/ x:CGFloat, y:CGFloat/*, player:UILabel*/){
        self.boxMade = true
        var boxView = UIImageView(frame: CGRect(x: x, y: y, width: 30, height: 30))
        if(self.player1Turn){
            boxView.image = UIImage(named: "oneBox.jpg")
            player1ScoreLabel.text = String((player1ScoreLabel.text?.toInt())!+1)
        }
        else{
            boxView.image = UIImage(named: "twoBox.jpg")
            player2ScoreLabel.text = String((player2ScoreLabel.text?.toInt())!+1)
        }
        //boxView.image = image
        self.view.addSubview(boxView)
        self.boxes.append(boxView)
        //var score = (player.text?.toInt())!+1
        //player.text = String(score)
        self.boxLocations.append(x,y)
        if(self.boxes.count == (self.xSize-1)*(self.ySize-1)){
            var endGameText:String
            if(self.player1ScoreLabel.text?.toInt()>self.player2ScoreLabel.text?.toInt()){
                endGameText = "Player one wins!"
            }
            else if(self.player1ScoreLabel.text?.toInt()<self.player2ScoreLabel.text?.toInt()){
                endGameText = "Player two wins!"
            }
            else{
                endGameText = "It's a draw!"
            }
            let controller = UIAlertController(title: endGameText, message: "Would you like to restart the game?", preferredStyle: UIAlertControllerStyle.Alert)
            let action1 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            let action2 = UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
                // this is what happens when "Restart" is selected
                self.restartGame()
            }
            controller.addAction(action1)
            controller.addAction(action2)
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func removeDots(){
        for dot in self.dots{
            dot.removeFromSuperview()
        }
        self.dots = []
        self.freeHorzPoints = []
        self.freeVertPoints = []
        self.active = false
    }
    
    func removeLines(){
        for line in self.horzLines{
            line.removeFromSuperview()
        }
        self.horzLines = []
        for line in self.vertLines{
            line.removeFromSuperview()
        }
        self.vertLines = []
    }
    
    func removeBoxes(){
        for box in boxes{
            box.removeFromSuperview()
        }
        self.boxLocations = []
        self.boxes = []
    }
    
    func addDots(){
        self.xOffset = (6 - self.xSize) * 25
        self.yOffset = ((10 - self.ySize) * 25) + 50
        if(self.xSize > 0 && self.ySize > 0){
            for xVal in 1...self.xSize{
                for yVal in 1...self.ySize{
                    let button = MyCustomButton(frame: CGRect(x: (xVal*dotDistance)+self.xOffset, y: (yVal*dotDistance)+self.yOffset, width: 20, height: 20))
                    button.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
                    button.setNumLines(self.dotDistance, xSize: self.xSize, ySize: self.ySize, xOffset: self.xOffset, yOffset: self.yOffset)
                    dots.append(button)
                    self.view.addSubview(button)
                    if(xVal != self.xSize){
                        var xCord = (xVal*dotDistance)+self.xOffset
                        var yCord = (yVal*dotDistance)+self.yOffset
                        self.freeHorzPoints.append(CGFloat(xCord),CGFloat(yCord))
                    }
                    if(yVal != self.ySize){
                        var xCord = (xVal*dotDistance)+self.xOffset
                        var yCord = (yVal*dotDistance)+self.yOffset
                        self.freeVertPoints.append(CGFloat(xCord),CGFloat(yCord))
                    }
                }
            }
        }
    }
    
    func restartGame(){
        removeDots()
        removeLines()
        removeBoxes()
        addDots()
        self.player1ScoreLabel.text = "0"
        self.player2ScoreLabel.text = "0"
        self.numberOfColumns.enabled = true
        self.numberOfRows.enabled = true
        self.npcLabel.enabled = false
        self.npcSlider.enabled = false
        self.npcSlider.value = 3
        self.npcEasy = false
        self.npcMedium = false
        self.npcHard = true
        self.canEditBoard = true
        self.player1Turn = true
        self.singlePlayer = false
        player1Label.backgroundColor = self.color
        player1ScoreLabel.backgroundColor = self.color
        player2Label.backgroundColor = nil
        player2ScoreLabel.backgroundColor = nil
        let controller = UIAlertController(title: "Welcome to Dot-Box!", message: "How would you like to play?", preferredStyle: UIAlertControllerStyle.Alert)
        let action1 = UIAlertAction(title: "Multiplayer", style: UIAlertActionStyle.Default, handler: nil)
        let action2 = UIAlertAction(title: "Single Player", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
            self.singlePlayer = true
            self.npcSlider.enabled = true
            self.npcLabel.enabled = true
        }
        controller.addAction(action2)
        controller.addAction(action1)
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func remove(x:CGFloat,y:CGFloat,inout list:[(CGFloat,CGFloat)]){
        for(var i = 0; i < list.count; i++){
            if(list[i].0 == x && list[i].1 == y){
                list.removeAtIndex(i)
            }
        }
    }
    
    //AI
    func npcStart(){
        if(self.npcEasy){
            npcCreateRandomLine()
        }
        else if(self.npcMedium){
            if(!npcCanCreateBox()){
                npcCreateRandomLine()
            }
        }
        else{
            if(!npcCanCreateBox()){
                npcOpponentBoxCheck()
                if(!npcCreateSemiRandomLine()){
                    if(!npcFindSmallestPath()){
                        npcCreateRandomLine()
                    }
                }
            }
        }
        newTurn()
    }
    
    func npcCanCreateBox()->Bool{
        for point in self.freeHorzPoints{
            if(checkForBottomBoxWithHorzLine(point.0, y: point.1)){
                createHorzLine(dotAtPoint(point.0, y: point.1), dot2: dotAtPoint(point.0+50, y: point.1))
                return true
            }
            if(checkForTopBoxWithHorzLine(point.0, y: point.1)){
                createHorzLine(dotAtPoint(point.0, y: point.1), dot2: dotAtPoint(point.0+50, y: point.1))
                return true
            }
        }
        for point in self.freeVertPoints{
            if(checkForRightBoxWithVertLine(point.0, y: point.1)){
                createVertLine(dotAtPoint(point.0, y: point.1), dot2: dotAtPoint(point.0, y: point.1+50))
                return true
            }
            if(checkForLeftBoxWithVertLine(point.0, y: point.1)){
                createVertLine(dotAtPoint(point.0, y: point.1), dot2: dotAtPoint(point.0, y: point.1+50))
                return true
            }
        }
        return false
    }
    
    func npcOpponentBoxCheck(){
        var tempHorzList: [(CGFloat,CGFloat)] = []
        var tempVertList: [(CGFloat,CGFloat)] = []
        for point in self.freeHorzPoints{
            fakeCreateHorzLine(point.0, y: point.1)
            if((!checkForRightBoxWithVertLine(point.0, y: point.1-50)) &&
                (!checkForBottomBoxWithHorzLine(point.0, y: point.1-50)) &&
                (!checkForLeftBoxWithVertLine(point.0+50, y: point.1-50)) &&
                (!checkForLeftBoxWithVertLine(point.0+50, y: point.1)) &&
                (!checkForTopBoxWithHorzLine(point.0, y: point.1+50)) &&
                (!checkForRightBoxWithVertLine(point.0, y: point.1))){
                    tempHorzList.append(point)
            }
            self.horzLines.removeAtIndex(self.horzLines.count - 1).removeFromSuperview()
        }
        
        for point in self.freeVertPoints{
            fakeCreateVertLine(point.0, y:point.1)
            if((!checkForBottomBoxWithHorzLine(point.0, y: point.1)) &&
                (!checkForLeftBoxWithVertLine(point.0+50, y: point.1)) &&
                (!checkForTopBoxWithHorzLine(point.0, y: point.1+50)) &&
                (!checkForTopBoxWithHorzLine(point.0-50, y: point.1+50)) &&
                (!checkForRightBoxWithVertLine(point.0-50, y: point.1)) &&
                (!checkForBottomBoxWithHorzLine(point.0-50, y: point.1))){
                    tempVertList.append(point)
            }
            self.vertLines.removeAtIndex(self.vertLines.count - 1).removeFromSuperview()
        }
        self.freeHorzPointsNoScore = tempHorzList
        self.freeVertPointsNoScore = tempVertList
    }
    
    func npcCreateRandomLine(){
        var randNum = arc4random_uniform(2)
        if(randNum == 0){
            var point = getRandomPoint(self.freeVertPoints)
            var dot1 = dotAtPoint(point.0, y: point.1)
            var dot2 = dotAtPoint(point.0, y: point.1+50)
            if(point.0 != -1){
                createVertLine(dot1, dot2: dot2)
            }
        }
        else{
            var point = getRandomPoint(self.freeHorzPoints)
            var dot1 = dotAtPoint(point.0, y: point.1)
            var dot2 = dotAtPoint(point.0+50, y: point.1)
            if(point.0 != -1){
                createHorzLine(dot1, dot2: dot2)
            }
        }
    }
    func npcCreateSemiRandomLine()->Bool{
        var randNum = arc4random_uniform(2)
        if((randNum == 0 || self.freeHorzPointsNoScore.count == 0) && self.freeVertPointsNoScore.count>0){
            var point = getRandomPoint(self.freeVertPointsNoScore)
            if(point.0 == -1){
                return false
            }
            var dot1 = dotAtPoint(point.0, y: point.1)
            var dot2 = dotAtPoint(point.0, y: point.1+50)
            createVertLine(dot1, dot2: dot2)
            return true
        }
        else if(self.freeHorzPointsNoScore.count>0){
            var point = getRandomPoint(self.freeHorzPointsNoScore)
            if(point.0 == -1){
                return false
            }
            var dot1 = dotAtPoint(point.0, y: point.1)
            var dot2 = dotAtPoint(point.0+50, y: point.1)
            createHorzLine(dot1, dot2: dot2)
            return true
        }
        else{
            return false
        }
    }
    
    func npcFindSmallestPath()->Bool{
        println()
        var tempHorzPoints = findTopBottomHorz(self.freeHorzPoints) //self.freeHorzPoints
        var tempVertPoints = findTopBottomVert(self.freeVertPoints)//self.freeVertPoints
        var min = self.xSize * self.ySize
        var horz = true
        var startPoint:(CGFloat,CGFloat) = (-1,-1)
        if(self.freeHorzPoints.count>0){
            startPoint = self.freeHorzPoints[0]
        }
        else if(self.freeVertPoints.count>0){
            startPoint = self.freeVertPoints[0]
        }
        for(var i = 0; i<tempHorzPoints.count; i++){
            var tempPoint = tempHorzPoints[i]
            var minCheck = npcHorzPathCheck(tempHorzPoints[i],point2:(-1,-1),horzList: &tempHorzPoints, vertList: &tempVertPoints)
            if(minCheck<min){
                startPoint = tempPoint
                min = minCheck
            }
        }
        for(var i = 0; i<tempVertPoints.count; i++){
            var tempPoint = tempVertPoints[i]
            var minCheck = npcVertPathCheck(tempVertPoints[i],point2:(-1,-1),horzList: &tempHorzPoints, vertList: &tempVertPoints)
            if(minCheck<min){
                if(horz){
                    horz = false
                }
                startPoint = tempPoint
                min = minCheck
            }
        }
        if(startPoint.0 == -1){
            return false
        }
        else if(horz){
            var dot1 = dotAtPoint(startPoint.0, y: startPoint.1)
            var dot2 = dotAtPoint(startPoint.0+50, y: startPoint.1)
            createHorzLine(dot1, dot2: dot2)
            return true
        }
        else{
            var dot1 = dotAtPoint(startPoint.0, y: startPoint.1)
            var dot2 = dotAtPoint(startPoint.0, y: startPoint.1+50)
            createVertLine(dot1, dot2: dot2)
            return true
        }
    }
    
    func npcHorzPathCheck(point:(CGFloat,CGFloat),point2:(CGFloat,CGFloat),inout horzList:[(CGFloat,CGFloat)],inout vertList:[(CGFloat,CGFloat)])->Int{
        fakeCreateHorzLine(point.0, y: point.1)
        if(checkForRightBoxWithVertLine(point.0, y: point.1-50) && (point.0 != point2.0 || point.1-50 != point2.1)){
            self.horzLines.removeAtIndex(self.horzLines.count - 1).removeFromSuperview()
            if(isFreeHorzPoint(point.0, y: point.1)){
                remove(point.0, y: point.1, list: &horzList)
            }
        return 1 + npcVertPathCheck((point.0,point.1-50),point2:point,horzList:&horzList,vertList:&vertList)
        }
        if(checkForBottomBoxWithHorzLine(point.0, y: point.1-50) && (point.0 != point2.0 || point.1-50 != point2.1)){
            self.horzLines.removeAtIndex(self.horzLines.count - 1).removeFromSuperview()
            if(isFreeHorzPoint(point.0, y: point.1)){
                remove(point.0, y: point.1, list: &horzList)
            }
            return 1 + npcHorzPathCheck((point.0,point.1-50),point2:point,horzList:&horzList,vertList:&vertList)
        }
        if(checkForLeftBoxWithVertLine(point.0+50, y: point.1-50) && (point.0+50 != point2.0 || point.1-50 != point2.1)){
            self.horzLines.removeAtIndex(self.horzLines.count - 1).removeFromSuperview()
            if(isFreeHorzPoint(point.0, y: point.1)){
                remove(point.0, y: point.1, list: &horzList)
            }
            return 1 + npcVertPathCheck((point.0+50,point.1-50),point2:point,horzList:&horzList,vertList:&vertList)
        }
        if(checkForLeftBoxWithVertLine(point.0+50, y: point.1) && (point.0+50 != point2.0 || point.1 != point2.1)){
            self.horzLines.removeAtIndex(self.horzLines.count - 1).removeFromSuperview()
            if(isFreeHorzPoint(point.0, y: point.1)){
                remove(point.0, y: point.1, list: &horzList)
            }
            return 1 + npcVertPathCheck((point.0+50,point.1),point2:point,horzList:&horzList, vertList:&vertList)
        }
        if(checkForTopBoxWithHorzLine(point.0, y: point.1+50) && (point.0 != point2.0 || point.1+50 != point2.1)){
            self.horzLines.removeAtIndex(self.horzLines.count - 1).removeFromSuperview()
            if(isFreeHorzPoint(point.0, y: point.1)){
                remove(point.0, y: point.1, list: &horzList)
            }
            return 1 + npcHorzPathCheck((point.0,point.1+50),point2:point,horzList:&horzList,vertList:&vertList)
        }
        if(checkForRightBoxWithVertLine(point.0, y: point.1) && (point.0 != point2.0 || point.1 != point2.1)){
            self.horzLines.removeAtIndex(self.horzLines.count - 1).removeFromSuperview()
            if(isFreeHorzPoint(point.0, y: point.1)){
                remove(point.0, y: point.1, list: &horzList)
            }
            return 1 + npcVertPathCheck((point.0,point.1),point2:point,horzList:&horzList, vertList:&vertList)
        }
        if(isFreeHorzPoint(point.0, y: point.1)){
            remove(point.0, y: point.1, list: &horzList)
        }
        self.horzLines.removeAtIndex(self.horzLines.count - 1).removeFromSuperview()
        return 0
    }
    
    func npcVertPathCheck(point:(CGFloat,CGFloat),point2:(CGFloat,CGFloat),inout horzList:[(CGFloat,CGFloat)],inout vertList:[(CGFloat,CGFloat)])->Int{
        fakeCreateVertLine(point.0, y:point.1)
        if(checkForBottomBoxWithHorzLine(point.0, y: point.1) && (point.0 != point2.0 || point.1 != point2.1)){
            self.vertLines.removeAtIndex(self.vertLines.count - 1).removeFromSuperview()
            if(isFreeVertPoint(point.0, y: point.1)){
                remove(point.0, y: point.1, list: &vertList)
            }
            return 1 + npcHorzPathCheck((point.0,point.1),point2:point, horzList: &horzList, vertList: &vertList)
        }
        if(checkForLeftBoxWithVertLine(point.0+50, y: point.1) && (point.0+50 != point2.0 || point.1 != point2.1)){
            self.vertLines.removeAtIndex(self.vertLines.count - 1).removeFromSuperview()
            if(isFreeVertPoint(point.0, y: point.1)){
                remove(point.0, y: point.1, list: &vertList)
            }
            return 1 + npcVertPathCheck((point.0+50,point.1),point2:point, horzList: &horzList, vertList: &vertList)
        }
        if(checkForTopBoxWithHorzLine(point.0, y: point.1+50) && (point.0 != point2.0 || point.1+50 != point2.1)){
            self.vertLines.removeAtIndex(self.vertLines.count - 1).removeFromSuperview()
            if(isFreeVertPoint(point.0, y: point.1)){
                remove(point.0, y: point.1, list: &vertList)
            }
            return 1 + npcHorzPathCheck((point.0,point.1+50),point2:point, horzList: &horzList, vertList: &vertList)
        }
        if(checkForTopBoxWithHorzLine(point.0-50, y: point.1+50) && (point.0-50 != point2.0 || point.1+50 != point2.1)){
            self.vertLines.removeAtIndex(self.vertLines.count - 1).removeFromSuperview()
            if(isFreeVertPoint(point.0, y: point.1)){
                remove(point.0, y: point.1, list: &vertList)
            }
            return 1 + npcHorzPathCheck((point.0-50,point.1+50),point2:point, horzList: &horzList, vertList: &vertList)
        }
        if(checkForRightBoxWithVertLine(point.0-50, y: point.1) && (point.0-50 != point2.0 || point.1 != point2.1)){
            self.vertLines.removeAtIndex(self.vertLines.count - 1).removeFromSuperview()
            if(isFreeVertPoint(point.0, y: point.1)){
                remove(point.0, y: point.1, list: &vertList)
            }
            return 1 + npcVertPathCheck((point.0-50,point.1),point2:point, horzList: &horzList, vertList: &vertList)
        }
        if(checkForBottomBoxWithHorzLine(point.0-50, y: point.1) && (point.0-50 != point2.0 || point.1 != point2.1)){
            self.vertLines.removeAtIndex(self.vertLines.count - 1).removeFromSuperview()
            if(isFreeVertPoint(point.0, y: point.1)){
                remove(point.0, y: point.1, list: &vertList)
            }
            return 1 + npcHorzPathCheck((point.0-50,point.1),point2:point, horzList: &horzList, vertList: &vertList)
        }
        self.vertLines.removeAtIndex(self.vertLines.count - 1).removeFromSuperview()
        if(isFreeVertPoint(point.0, y: point.1)){
            remove(point.0, y: point.1, list: &vertList)
        }
        return 0
    }
    
    func findTopBottomHorz(list:[(CGFloat,CGFloat)])->[(CGFloat,CGFloat)]{
        var newList:[(CGFloat,CGFloat)] = []
        for i in list{
            if (i.1 == CGFloat(50+self.yOffset)){
                newList.append(i)
                println("Found Top")
            }
            if(i.1 == CGFloat((self.ySize*50)+self.yOffset)){
                newList.append(i)
                println("Found Bottom")
            }
        }
        return newList
    }
    
    func findTopBottomVert(list:[(CGFloat,CGFloat)])->[(CGFloat,CGFloat)]{
        var newList:[(CGFloat,CGFloat)] = []
        for i in list{
            if (i.0 == CGFloat(50+self.xOffset)){
                newList.append(i)
                println("Found Left")
            }
            if(i.0 == CGFloat((self.xSize*50)+self.xOffset)){
                newList.append(i)
                println("Found Right")
            }
        }
        return newList
    }
    
    func fakeCreateVertLine(x:CGFloat,y:CGFloat){
        var line = VerticalLine(frame: CGRect(x: x, y: y, width: 20, height: 70))
        self.vertLines.append(line)
        self.view.addSubview(line)
    }
    func fakeCreateHorzLine(x:CGFloat,y:CGFloat){
        var line = HorizontalLine(frame: CGRect(x: x, y: y, width: 20, height: 70))
        self.horzLines.append(line)
        self.view.addSubview(line)
    }
    
    func getRandomPoint(list:[(CGFloat,CGFloat)])->(CGFloat,CGFloat){
        if(list.count>0){
            var randomIndex = arc4random_uniform(UInt32(list.count - 1))
            return list[Int(randomIndex)]
        }
        return (CGFloat(-1),CGFloat(-1))
    }
    
    func isFreeHorzPoint(x:CGFloat,y:CGFloat)->Bool{
        for point in self.freeHorzPoints{
            if(point.0 == x && point.1 == y){
                return true
            }
        }
        return false
    }
    func isFreeVertPoint(x:CGFloat,y:CGFloat)->Bool{
        for point in self.freeVertPoints{
            if(point.0 == x && point.1 == y){
                return true
            }
        }
        return false
    }
    
    func dotAtPoint(x:CGFloat, y:CGFloat)->MyCustomButton{
        for dot in self.dots{
            if(dot.x! == x && dot.y! == y){
                return dot
            }
        }
        return self.tempDot
    }
    
    func vertLineAtPoint(x:CGFloat, y:CGFloat)->VerticalLine{
        for line in self.vertLines{
            if(line.x! == x && line.y! == y){
                return line
            }
        }
        return tempVertLine
    }
    
    func horzLineAtPoint(x:CGFloat, y:CGFloat)->HorizontalLine{
        for line in self.horzLines{
            if(line.x! == x && line.y! == y){
                return line
            }
        }
        return tempHorzLine
    }
    
    func checkForRightBoxWithVertLine(x:CGFloat,y:CGFloat)->Bool{
        if(vertLineAtPoint(x+50, y: y).isNil || horzLineAtPoint(x, y: y).isNil || horzLineAtPoint(x, y: y+50).isNil){
            return false
        }
        else{
            return true
        }
    }
    
    func checkForLeftBoxWithVertLine(x:CGFloat,y:CGFloat)->Bool{
        if(vertLineAtPoint(x-50, y: y).isNil || horzLineAtPoint(x-50, y: y).isNil || horzLineAtPoint(x-50, y: y+50).isNil){
            return false
        }
        else{
            return true
        }
    }
    
    func checkForBottomBoxWithHorzLine(x:CGFloat,y:CGFloat)->Bool{
        if(horzLineAtPoint(x, y: y+50).isNil || vertLineAtPoint(x, y: y).isNil || vertLineAtPoint(x+50, y: y).isNil){
            return false
        }
        else{
            return true
        }
    }
    
    func checkForTopBoxWithHorzLine(x:CGFloat,y:CGFloat)->Bool{
        if(horzLineAtPoint(x, y: y-50).isNil || vertLineAtPoint(x, y: y-50).isNil || vertLineAtPoint(x+50, y: y-50).isNil){
            return false
        }
        else{
            return true
        }
    }
}


