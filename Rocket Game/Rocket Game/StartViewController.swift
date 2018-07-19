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

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels()
        StartButton.applyAdditionalButtonDesign()
        Hard.applyAdditionalButtonDesign()
        Medium.applyAdditionalButtonDesign()
        Easy.applyAdditionalButtonDesign()
        ViewScoreButton.applyAdditionalButtonDesign()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var HighScoreLabel: UILabel!
    
    @IBOutlet weak var PreviousScoreLabel: UILabel!
    
    @IBOutlet var DifficultyButtons: [UIButton]!
    
    @IBOutlet weak var AverageLabel: UILabel!
    
    @IBOutlet weak var StartButton: UIButton!
    
    @IBOutlet weak var Hard: UIButton!
    
    @IBOutlet weak var Medium: UIButton!
    
    @IBOutlet weak var Easy: UIButton!
    
    @IBOutlet weak var ViewScoreButton: UIButton!
    
    
    
    @IBAction func SelectDifficulty(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.DifficultyButtons.forEach { (button) in
                button.isHidden = !button.isHidden
                }})
        ViewScoreButton.isHidden = !ViewScoreButton.isHidden
        }
    
    @IBAction func DifficultyChoosen(_ sender: UIButton) {
        if sender.tag == 2 {
            gameDifficulty = Difficulty.medium
        }
        if sender.tag == 3 {
            gameDifficulty = Difficulty.easy
        }
        if sender.tag == 1 {
            gameDifficulty = Difficulty.hard
        }
    
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
        
        AverageLabel.text = "Average: \(average)"
    }
}



    






















