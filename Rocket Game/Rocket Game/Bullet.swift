//
//  Bullet.swift
//  Rocket Game
//
//  Created by Arjun Bemarkar on 8/17/18.
//  Copyright © 2018 Arjun. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class Bullet : SKSpriteNode {
    init() {
        super.init(texture: SKTexture(imageNamed: "bulletImage"), color:  UIColor.white , size: #imageLiteral(resourceName: "bulletImage").size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createBullet(player : SKSpriteNode, topYCoor : CGFloat){
        let bulletOrigin : CGPoint = CGPoint(x: player.position.x, y: player.position.y+player.size.height/2)
        let moveBulletUp : SKAction = SKAction.move(to: CGPoint(x: bulletOrigin.x, y: topYCoor), duration: bulletSpeed)
        
        var actionArray = [SKAction]()
        
        actionArray.append(moveBulletUp)
        actionArray.append(SKAction.removeFromParent())
        
        
//        bullet = SKSpriteNode(imageNamed: "bulletImage")
        self.name = "Bullet"
        self.position = bulletOrigin
        self.run(SKAction.sequence(actionArray))
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.categoryBitMask = bulletCategory
        self.physicsBody?.contactTestBitMask = asteroidCategory + satelliteCategory
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.isDynamic = true
        self.zPosition = 1
    }
    
    
}
