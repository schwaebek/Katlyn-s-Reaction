//
//  ViewController.swift
//  Katlyn's Reaction
//
//  Created by Katlyn Schwaebe on 9/18/14.
//  Copyright (c) 2014 Katlyn Schwaebe. All rights reserved.
//

import UIKit
import GameKit

let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height

class ViewController: UIViewController {
    
    var timerBar = UIView()
    var buttons = [UIButton(), UIButton(), UIButton()]
    //[UIButton] (count: 3, repeatedValue: UIButton())
    
    var scoreLabel = UILabel()
    var timer: NSTimer?
    
    var currentScore = 0
    var buttonToTap = 0
    
    var player = GKLocalPlayer.localPlayer()
    
    var allLeaderboards: [String:GKLeaderboard] = Dictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        //first color
        var topColor = UIColor(red: 0.910, green: 0.976, blue: 0.333, alpha: 1.0)
        
        //second color
        var bottomColor = UIColor(red: 0.973, green: 0.204, blue: 0.333, alpha: 1.0)
        
        //array of colors in gradient
        var gradientColors: [AnyObject] = [topColor.CGColor, bottomColor.CGColor]
        
        //array of locaions for colors in gradient
        var gradientLocations = [0.0,1.0]
        
        //gradient layer
        var gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.frame
        gradientLayer.startPoint = CGPointMake(1.0, 0.0)
        gradientLayer.endPoint = CGPointMake(0.0, 1.0)
        
        //add colors to gradient layer
        gradientLayer.colors = gradientColors
        
        //add locations to gradient layer
        gradientLayer.locations = gradientLocations
        
        //add gradient to view layer as background
        self.view.layer.addSublayer(gradientLayer)
        
        for i in 0..<buttons.count {
            var button = buttons[i]
            var size: CGFloat = 100.0
            
            var x = (SCREEN_WIDTH / 2.0) - (size / 2.0)
            var y = (SCREEN_HEIGHT / 2.0) - (size / 2.0) - (CGFloat(i - 1) * (size + 20))
            
            button.alpha = 0.6
            button.frame = CGRectMake(x, y, size, size)
            button.layer.cornerRadius = size / 2.0
            button.backgroundColor = UIColor.whiteColor()
            button.tag = i
            
            button.addTarget(self, action: Selector("buttonTapped:"), forControlEvents: .TouchUpInside)
            
            self.view.addSubview(button)
            
        }
        timerBar.backgroundColor = UIColor.whiteColor()
        timerBar.frame = CGRectMake(0, 0, 0, 30)
        self.view.addSubview(timerBar)
        
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
            
            dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
                self.runLevel()
       
        }
        var nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: Selector("authChanged"), name: GKPlayerAuthenticationDidChangeNotificationName, object: nil)
        
            if player.authenticated == false {
            player.authenticateHandler = { (viewController, error) -> Void in
                
                if viewController != nil{
                    self.presentViewController(viewController, animated: true, completion: nil)
                }
            }
            
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    func resetTimerWithSpeed(speed: Double) {
        if timer != nil {timer!.invalidate()}
        
        timer = NSTimer.scheduledTimerWithTimeInterval(speed, target: self, selector: Selector("timerDone"), userInfo: nil, repeats: false)
        timerBar.layer.removeAllAnimations()
        timerBar.frame.size.width = SCREEN_WIDTH
        
        
        UIView.animateWithDuration(speed, delay: 0, options: .CurveLinear, animations: { () -> Void in
            self.timerBar.frame.size.width = 0
            }) { (succeeded: Bool) -> Void in
        }
    }
    
        func timerDone() {
            submitScore()
            println("Game Over")
        }
        func buttonTapped(button: UIButton){
            println(button.tag)
            if buttonToTap == button.tag
            {
                currentScore++
                checkAchievement()
                runLevel()
                
            }else{
                
                submitScore()
                currentScore = 0
                println("Fail")
                var time = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
                
                dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
                    self.runLevel()
                    
                
                    
                }
               
            }
        }
        func runLevel() {
            buttonToTap = Int(arc4random_uniform(3))
            var button = buttons[buttonToTap]
            button.alpha = 1.0
            
            UIView.animateWithDuration(1.0, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                button.alpha = 0.6
                }) { (succeeded: Bool) -> Void in
            }
               resetTimerWithSpeed(10)
        }
    func authChanged(){
        if player.authenticated == false { return }
        GKLeaderboard.loadLeaderboardsWithCompletionHandler { (leaderboards, error) -> Void in
            for leaderboard in leaderboards as [GKLeaderboard]{
                var identifier = leaderboard.identifier
                self.allLeaderboards[identifier] = leaderboard
            }
        }
    }
    func submitScore() {
        var scoreReporter = GKScore(leaderboardIdentifier: "total_taps")
        scoreReporter.value = Int64(currentScore)
        scoreReporter.context = 0
        
        GKScore.reportScores([scoreReporter], withCompletionHandler: { (error) -> Void in
            println("score reported")
        })
        
        var player = GKPlayer()
    }
    func checkAchievement()
    {
        if currentScore >= 5 {
            var score50 = GKAchievement(identifier: "score_50")
            //GKAchievement(identifier: "score_50")
            score50.percentComplete = 100.0
            score50.showsCompletionBanner = true
            GKAchievement.reportAchievements([score50], withCompletionHandler: { (error) -> Void in
                println("achievement sent")
            })
        }
    }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
}

