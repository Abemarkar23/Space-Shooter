//
//  Enemy.swift
//  Rocket Game
//
//  Created by Arjun Bemarkar on 7/19/18.
//  Copyright © 2018 Arjun. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion
import UIKit
import GameplayKit

var satelliteSpeed : TimeInterval = 4
var satelliteProductionRate : TimeInterval = 4
let possibleSatelliteImage : [String] = ["yellowSatellite", "blueSatellite"]
var satelliteTimer : Timer!
let sateliteScoreThreshold : Int = 0
var satelliteScore : Int = 10

var asteroidSpeed : TimeInterval = 6
var asteroidProductionRate : TimeInterval = 0.75
let possibleAsteroidImage : [String] = ["spaceMeteors_001", "spaceMeteors_002", "spaceMeteors_003", "spaceMeteors_004"]
var asteroidTimer : Timer!
var asteroidScore : Int = 5

extension SKSpriteNode {
    func SatelliteEnemySettings(screenHeight : CGFloat, screenWidth : CGFloat) {
            self.position = setEnemyOrigin(screenHeight: screenHeight, screenWidth: screenWidth, enemySprite: self)
        
            let satelliteDestination : CGPoint = setEnemyDestination(screenHeight: screenHeight, screenWidth: screenWidth, enemySprite: self)
            let moveSatelliteToTop : SKAction = SKAction.move(to: satelliteDestination, duration: satelliteSpeed)
            var actionArray = [SKAction]()
            
            actionArray.append(moveSatelliteToTop)
            actionArray.append(SKAction.run {GameScene().RemoveOneLife()})
            actionArray.append(SKAction.removeFromParent())
            
            self.run(SKAction.rotate(byAngle: CGFloat(arc4random_uniform(2)), duration: satelliteSpeed))
            self.run(SKAction.sequence(actionArray))
            
            self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
            self.physicsBody?.affectedByGravity = false
            self.physicsBody?.isDynamic = false
            self.physicsBody?.allowsRotation = false
            
            self.physicsBody?.categoryBitMask = satelliteCategory
            self.physicsBody?.contactTestBitMask = bulletCategory
            self.physicsBody?.collisionBitMask = 0
        }
    
    func AsteroidEnemySettings(screenHeight : CGFloat, screenWidth : CGFloat, player : SKSpriteNode){
        self.scale(to: CGSize(width: player.size.height, height: player.size.height))
        self.position = setEnemyOrigin(screenHeight: screenHeight, screenWidth: screenWidth, enemySprite: self)
        
        let asteroidDestination : CGPoint = setEnemyDestination(screenHeight: screenHeight, screenWidth: screenWidth, enemySprite: self)
        let moveAsteroidToBottom : SKAction = SKAction.move(to: asteroidDestination, duration: asteroidSpeed)
        
        var actionArray = [SKAction]()
        
        actionArray.append(moveAsteroidToBottom)
        actionArray.append(SKAction.removeFromParent())
        actionArray.append(SKAction.run {GameScene().RemoveOneLife()})
        actionArray.append(SKAction.run {print("Life count : \(LivesArray.count)")})
        
        self.run(SKAction.repeatForever(SKAction.rotate(byAngle: 25, duration: 5)))
        self.run(SKAction.sequence(actionArray))
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height/2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.allowsRotation = false
        
        self.physicsBody?.categoryBitMask = asteroidCategory
        self.physicsBody?.contactTestBitMask = bulletCategory
        self.physicsBody?.collisionBitMask = 0
    }
}

func setEnemyOrigin(screenHeight : CGFloat, screenWidth : CGFloat, enemySprite : SKSpriteNode) -> CGPoint {
    let randomStartNumber = GKRandomDistribution(lowestValue: Int(-1 * screenWidth/2), highestValue: Int(screenWidth/2))
    let randomXPos = CGFloat(randomStartNumber.nextInt())
    let startPos : CGPoint = CGPoint(x: randomXPos, y: screenHeight/2 + enemySprite.size.height)
    return startPos
}
    
func setEnemyDestination(screenHeight : CGFloat, screenWidth : CGFloat, enemySprite : SKSpriteNode) -> CGPoint {
    let randomEndNumber = GKRandomDistribution(lowestValue: Int(-1 * screenWidth/2), highestValue: Int(screenWidth/2))
    let randomXPos = CGFloat(randomEndNumber.nextInt())
    let endPos : CGPoint = CGPoint(x: randomXPos, y: -1 * screenHeight/2 - enemySprite.size.height)
    return endPos
}



























//class Enemy: SKSpriteNode {
//    init(imageName : String) {
//        super.init(texture: SKTexture(imageNamed: imageName), color:  UIColor.white , size: #imageLiteral(resourceName: "spaceShipImage").size)
//    }
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func CreateEnemy(screenHeight : CGFloat, screenWidth : CGFloat) {
//        let randomSatellitePosition = GKRandomDistribution(lowestValue: Int(-1 * screenHeight/2), highestValue: Int(screenWidth/2))
//        let position = CGFloat(randomSatellitePosition.nextInt())
//
//        self.position = CGPoint(x: position, y: (screenHeight + self.size.height)/2 + 200)
//
//        let moveSatelliteToTop : SKAction = SKAction.move(to: CGPoint(x: position, y: -1 * screenHeight/2 - self.size.height), duration: satelliteSpeed)
//        var actionArray = [SKAction]()
//
//        actionArray.append(moveSatelliteToTop)
//        actionArray.append(SKAction.removeFromParent())
//
//        self.run(SKAction.rotate(byAngle: CGFloat(arc4random_uniform(2)), duration: satelliteSpeed))
//        self.run(SKAction.sequence(actionArray))
//
//        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
//        self.physicsBody?.affectedByGravity = false
//        self.physicsBody?.isDynamic = false
//        self.physicsBody?.allowsRotation = false
//
//        self.physicsBody?.categoryBitMask = satelliteCategory
//        self.physicsBody?.contactTestBitMask = bulletCategory
//        self.physicsBody?.collisionBitMask = 0
//    }
//
//
//    func CreateAsteroid() {
//        asteroid = SKSpriteNode(imageNamed: possibleAsteroidImage[Int(arc4random_uniform(4))])
//        asteroid.scale(to: CGSize(width: player.size.height, height: player.size.height))
//
//        let randomAsteroidPosition = GKRandomDistribution(lowestValue: Int(-1 * self.size.width/2), highestValue: Int(self.size.width/2))
//        let position = CGFloat(randomAsteroidPosition.nextInt())
//
//        asteroid.position = CGPoint(x: position, y: (self.frame.height + asteroid.size.height)/2)
//
//        let moveAsteroidToBottom : SKAction = SKAction.move(to: CGPoint(x: position, y: -1 * self.size.height/2 - asteroid.size.height), duration: asteroidSpeed)
//        var actionArray = [SKAction]()
//
//        actionArray.append(moveAsteroidToBottom)
//        actionArray.append(SKAction.removeFromParent())
//        actionArray.append(SKAction.run {self.RemoveOneLife()})
//
//        asteroid.run(SKAction.repeatForever(SKAction.rotate(byAngle: 25, duration: 5)))
//        asteroid.run(SKAction.sequence(actionArray))
//
//        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: asteroid.size.height/2)
//        asteroid.physicsBody?.affectedByGravity = false
//        asteroid.physicsBody?.isDynamic = false
//        asteroid.physicsBody?.allowsRotation = false
//
//        asteroid.physicsBody?.categoryBitMask = asteroidCategory
//        asteroid.physicsBody?.contactTestBitMask = bulletCategory
//        asteroid.physicsBody?.collisionBitMask = 0
//
//        self.addChild(asteroid)
//    }
//
//
//
//}



























