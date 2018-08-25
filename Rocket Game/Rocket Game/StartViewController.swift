//
//  StartViewController.swift
//  Rocket Game
//
//  Created by Arjun Bemarkar on 7/4/18.
//  Copyright © 2018 Arjun. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

enum Difficulty {
    case hard
    case easy
    case medium
}
var topInset : CGFloat!
var bottomInset : CGFloat!

var isDarkMode : Bool = true

var gameDifficulty : Difficulty = Difficulty.hard
let wndow = UIApplication.shared.keyWindow

var topSafeArea: CGFloat = 0
var bottomSafeArea: CGFloat = 0

class StartViewController: UIViewController, GADBannerViewDelegate {
    
    override func viewDidLayoutSubviews() {
        print(view.safeAreaInsets.bottom)
        topInset = view.safeAreaInsets.top
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels()
        StartButton.applyAdditionalButtonDesign()
        if isDarkMode == true {
            view.backgroundColor = .black
        }
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
//        myBanner.adUnitID = "ca-app-pub-6099571360203191/5211532454"
        myBanner.adUnitID = "ca-app-pub-6099571360203191/9767206208"

        myBanner.rootViewController = self
        myBanner.delegate = self
        myBanner.load(request)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var HighScoreLabel: UILabel!
    
    @IBOutlet weak var PreviousScoreLabel: UILabel!
    
    @IBOutlet weak var StartButton: UIButton!
    
    @IBOutlet weak var myBanner: GADBannerView!
    
    @IBAction func SelectDifficulty(_ sender: UIButton) {
        gameDifficulty = Difficulty.easy
        }
    
    func setLabels() {
        if highScore != nil {
            HighScoreLabel.text = "High Score: \(highScore!)"
            print("\(highScore!)")
        }
        
        if latestScore != nil {
            PreviousScoreLabel.text = "Previous Score: \(latestScore!)"
            PreviousScoreLabel.isHidden = false
        }
    }
}



    






















