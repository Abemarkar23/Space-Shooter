//
//  Formating.swift
//  Rocket Game
//
//  Created by Arjun Bemarkar on 7/18/18.
//  Copyright © 2018 Arjun. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

extension UIButton {
    func applyAdditionalButtonDesign(){
        self.layer.cornerRadius = self.frame.height/2
        self.layer.shadowColor = self.backgroundColor?.cgColor
        self.layer.shadowRadius = 6
        self.layer.shadowOpacity = 0.50
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}

extension SKLabelNode {
    func applyAdditionalSKLabelDesign(labelSize : CGFloat, labelPosition : CGPoint, layoutWidth : CGFloat){

        self.fontName = "AvenirNext-DemiBold"
        self.fontSize = labelSize
        self.zPosition = 2
        self.fontColor = .white
        self.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        self.position = labelPosition
        self.lineBreakMode = .byWordWrapping
        self.numberOfLines = 2
        self.preferredMaxLayoutWidth = layoutWidth
        self.numberOfLines = 2
        self.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
    }
}


