//
//  player.swift
//  Rocket Game
//
//  Created by Arjun Bemarkar on 7/18/18.
//  Copyright © 2018 Arjun. All rights reserved.
//

import Foundation
import SpriteKit

class Player: SKSpriteNode {
    init() {
        super.init(texture: SKTexture(imageNamed: "spaceShipImage"), color:  UIColor.white , size: #imageLiteral(resourceName: "spaceShipImage").size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createPlayer(playerYPosition: Int, intendedPosition : CGPoint){
        self.name = "Player"
        self.position = CGPoint(x: 0 , y:  playerYPosition)
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        
        self.physicsBody?.categoryBitMask = playerCategory
        self.physicsBody?.contactTestBitMask = satelliteCategory + asteroidCategory
        self.physicsBody?.collisionBitMask = 0
        
        self.run(SKAction.move(to: intendedPosition, duration: 2))
    }
    
}
