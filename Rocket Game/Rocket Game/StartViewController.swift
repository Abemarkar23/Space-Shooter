//
//  StartViewController.swift
//  Rocket Game
//
//  Created by Arjun Bemarkar on 7/4/18.
//  Copyright © 2018 Arjun. All rights reserved.
//

import UIKit

enum Difficulty {
    case hard
    case easy
    case medium
}

var gameDifficulty : Difficulty = Difficulty.hard
let wndow = UIApplication.shared.keyWindow

var topSafeArea: CGFloat = 0
var bottomSafeArea: CGFloat = 0

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels()
        StartButton.applyAdditionalButtonDesign()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var HighScoreLabel: UILabel!
    
    @IBOutlet weak var PreviousScoreLabel: UILabel!
    
    @IBOutlet weak var StartButton: UIButton!
    
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



    






















