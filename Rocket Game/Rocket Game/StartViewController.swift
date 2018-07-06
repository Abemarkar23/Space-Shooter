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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet var DifficultyButtons: [UIButton]!
    
    
    @IBAction func SelectDifficulty(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.DifficultyButtons.forEach { (button) in
                button.isHidden = !button.isHidden
                }})
        }
    
    @IBAction func DifficultyChoosen(_ sender: UIButton) {
        if sender.tag == 2 {
            gameDifficulty = Difficulty.medium
        }
        if sender.tag == 3 {
            gameDifficulty = Difficulty.easy
            
        }
        
    }
    
    
    
    
    
        
    }

    

