//
//  GameScene.swift
//  Rocket Game
//
//  Created by Arjun Bemarkar on 6/11/18.
//  Copyright © 2018 Arjun. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var motionManager: CMMotionManager!
    
    var player : SKSpriteNode!
    var LivesArray = [SKSpriteNode]()
    
    let bulletSpeed : TimeInterval = 1
    
    var asteroidSpeed : TimeInterval = 6
    var asteroidProductionRate : TimeInterval = 0.75
    let possibleAsteroidImage : [String] = ["spaceMeteors_001", "spaceMeteors_002", "spaceMeteors_003", "spaceMeteors_004"]
    var asteroidTimer : Timer!
    
    var satelliteSpeed : TimeInterval = 4
    var satelliteProductionRate : TimeInterval = 4
    let possibleSatelliteImage : [String] = ["yellowSatellite", "blueSatellite"]
    var satelliteTimer : Timer!
    let sateliteScoreThreshold : Int = 0
    
    
    var scoreLabel : SKLabelNode!
    var score : Int = 0
    
    var GameOverLabel : SKLabelNode!
    
    let bulletCategory:UInt32 =     0x1 << 0
    let asteroidCategory:UInt32 =   0x1 << 1
    let satelliteCategory:UInt32 =  0x1 << 2
    
    let motionManger = CMMotionManager()
    var xAcceleration:CGFloat = 0
    
    var gameState : Bool = true
    
    func setToDifficulty() {
        if gameDifficulty == Difficulty.hard {
            asteroidSpeed = 5
            asteroidProductionRate = 0.50
            satelliteSpeed = 3.5
            satelliteProductionRate = 3
        }
        if gameDifficulty == Difficulty.medium {
            asteroidSpeed = 7
            asteroidProductionRate = 1
            satelliteSpeed = 5.5
            satelliteProductionRate = 5
        }
        if gameDifficulty == Difficulty.easy {
            asteroidSpeed = 6
            asteroidProductionRate = 0.75
            satelliteSpeed  = 4
            satelliteProductionRate  = 4
        }
    }
    
    func CreatePlayer(){
        let playerPositionY : CGFloat = -0.4122938531 * self.frame.size.height
        player = SKSpriteNode(imageNamed: "spaceShipImage")
        player.position = CGPoint(x: 0 , y:  playerPositionY)
        
        self.addChild(player)
    }
    
    @objc func CreateNewSatellite() {
        let satellite : SKSpriteNode = SKSpriteNode(imageNamed: possibleSatelliteImage[Int(arc4random_uniform(2))])
        
        let randomSatellitePosition = GKRandomDistribution(lowestValue: Int(-1 * self.size.width/2), highestValue: Int(self.size.width/2))
        let position = CGFloat(randomSatellitePosition.nextInt())
        
        satellite.position = CGPoint(x: position, y: (self.frame.height + satellite.size.height)/2 + 200)
        
        let moveSatelliteToTop : SKAction = SKAction.move(to: CGPoint(x: position, y: -1 * self.size.height/2 - satellite.size.height), duration: satelliteSpeed)
        var actionArray = [SKAction]()
        
        actionArray.append(moveSatelliteToTop)
        actionArray.append(SKAction.removeFromParent())
        
        satellite.run(SKAction.rotate(byAngle: CGFloat(arc4random_uniform(2)), duration: satelliteSpeed))
        satellite.run(SKAction.sequence(actionArray))
        
        satellite.physicsBody = SKPhysicsBody(rectangleOf: satellite.size)
        satellite.physicsBody?.affectedByGravity = false
        satellite.physicsBody?.isDynamic = false
        satellite.physicsBody?.allowsRotation = false
        
        satellite.physicsBody?.categoryBitMask = satelliteCategory
        satellite.physicsBody?.contactTestBitMask = bulletCategory
        satellite.physicsBody?.collisionBitMask = 0
        
        self.addChild(satellite)
        
    }
    
    @objc func CreateNewAsteroid() {
        var asteroid : SKSpriteNode
        asteroid = SKSpriteNode(imageNamed: possibleAsteroidImage[Int(arc4random_uniform(4))])
        asteroid.scale(to: CGSize(width: player.size.height, height: player.size.height))
        
        let randomAsteroidPosition = GKRandomDistribution(lowestValue: Int(-1 * self.size.width/2), highestValue: Int(self.size.width/2))
        let position = CGFloat(randomAsteroidPosition.nextInt())
        
        asteroid.position = CGPoint(x: position, y: (self.frame.height + asteroid.size.height)/2)
        
        let moveAsteroidToTop : SKAction = SKAction.move(to: CGPoint(x: position, y: -1 * self.size.height/2 - asteroid.size.height), duration: asteroidSpeed)
        var actionArray = [SKAction]()
        
        actionArray.append(moveAsteroidToTop)
        actionArray.append(SKAction.removeFromParent())
        actionArray.append(SKAction.run {self.RemoveOneLife()})
        
        asteroid.run(SKAction.repeatForever(SKAction.rotate(byAngle: 25, duration: 5)))
        asteroid.run(SKAction.sequence(actionArray))
        
        
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: asteroid.size.height/2)
        asteroid.physicsBody?.affectedByGravity = false
        asteroid.physicsBody?.isDynamic = false
        asteroid.physicsBody?.allowsRotation = false
        
        asteroid.physicsBody?.categoryBitMask = asteroidCategory
        asteroid.physicsBody?.contactTestBitMask = bulletCategory
        asteroid.physicsBody?.collisionBitMask = 0
        
        self.addChild(asteroid)
    }
    
    @objc func CreateNewBullet() {
        
        let bulletOrigin : CGPoint = CGPoint(x: player.position.x, y: player.position.y+player.size.height/2)
        let moveBulletUp : SKAction = SKAction.move(to: CGPoint(x: bulletOrigin.x, y: self.size.height/2), duration: bulletSpeed)
        
        var actionArray = [SKAction]()
        
        actionArray.append(moveBulletUp)
        actionArray.append(SKAction.removeFromParent())
        
        var bullet : SKSpriteNode
        bullet = SKSpriteNode(imageNamed: "bulletImage")
        bullet.position = bulletOrigin
        bullet.run(SKAction.sequence(actionArray))
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = asteroidCategory + satelliteCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        bullet.physicsBody?.isDynamic = true
        bullet.zPosition = 1

        self.addChild(bullet)
    }
    
    func CreateLives() {
        
        for life in 1...3 {
            let newLife = SKSpriteNode(imageNamed: "spaceShipImage")
            
            newLife.run(SKAction.scale(by: 2/3, duration: 0.1))
            newLife.position = CGPoint(x: self.frame.size.width/2 - (CGFloat(life) * newLife.size.width), y: scoreLabel.position.y)
            
            LivesArray.append(newLife)
            self.addChild(newLife)
        }
    }
    
    func RemoveOneLife() {
        if LivesArray.count != 0 {
            LivesArray.last?.removeFromParent()
            LivesArray.removeLast()
        }
        if LivesArray.count == 0 {
            gameState = false
            GameOver()
        }
    }
    
    func GameOver(){
        self.removeAllChildren()
        if GameOverLabel == nil {
            GameOverLabel = SKLabelNode(text: "Game Over")
            GameOverLabel.fontName = "AvenirNext-DemiBold"
            GameOverLabel.fontSize = 100
            GameOverLabel.color = .white
            GameOverLabel.zPosition = 2
            GameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        }
        else {
            GameOverLabel.isHidden = false
        }
        if satelliteTimer != nil{
            satelliteTimer.invalidate()
        }
        asteroidTimer.invalidate()
        self.addChild(GameOverLabel)
    }
    
    
    func CreateScoreBoard() {
        scoreLabel =  SKLabelNode(text : "Score : 0")
        scoreLabel.fontName = "AvenirNext-DemiBold"
        scoreLabel.fontSize = 50
        scoreLabel.color = .white
        scoreLabel.zPosition = 2
        
        scoreLabel.position =  CGPoint(x: frame.minX, y: frame.maxY-50)
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        self.addChild(scoreLabel)
    }
    
    func CheckPlayerBoundry() {
        let playerYPosition : CGFloat = -0.4122938531 * self.frame.size.height
        let playerBoundryRight : CGFloat = (self.frame.width/2  - player.size.width/2)
        let playerBoundryLeft : CGFloat = -1*(playerBoundryRight)
        
        
        if player.position.x >= playerBoundryRight {
            player?.position = CGPoint(x: playerBoundryRight, y: playerYPosition)
        }
        
        if player.position.x <= playerBoundryLeft {
            player?.position = CGPoint(x: playerBoundryLeft, y: playerYPosition)
        }
    }
    
    func randomNum(high: CGFloat, low: CGFloat) -> CGFloat{
        let distribution = GKRandomDistribution(lowestValue: Int(low), highestValue: Int(high))
        let randomNumber = CGFloat(distribution.nextInt())
        return randomNumber
    }
    
    func setUpPhysics() {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
    }
    
    func  bulletDidCollide(bulletNode: SKSpriteNode, EnemyNode: SKSpriteNode, addScore: Int) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = EnemyNode.position
        self.addChild(explosion)
        
        bulletNode.removeFromParent()
        EnemyNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        
        score += addScore
        scoreLabel.text = "Score : \(score)"
        if gameState == true && satelliteTimer == nil && score >= sateliteScoreThreshold{
                print("Started Satellite Timer.")
                satelliteTimer = Timer.scheduledTimer(timeInterval: satelliteProductionRate, target: self, selector: #selector(CreateNewSatellite) , userInfo: nil, repeats: true)
        }
        
    }
    
    
    func setupPlayerControl() {
        motionManger.accelerometerUpdateInterval = 0.2
        motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
    }
    
    func StartNewGame() {
        setUpPhysics()
        CreatePlayer()
        setupPlayerControl()
        CreateScoreBoard()
        CreateLives()
        setToDifficulty()
        asteroidTimer = Timer.scheduledTimer(timeInterval: asteroidProductionRate, target: self, selector: #selector(CreateNewAsteroid) , userInfo: nil, repeats: true)
        if GameOverLabel != nil {
            GameOverLabel.isHidden = true
            gameOverButton.isHidden = true
        }
        gameState = true
    }
    
    override func didMove(to view: SKView) {
        StartNewGame()
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAcceleration * 25
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        player?.removeAllActions()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player?.removeAllActions()
        CreateNewBullet()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == false{
           StartNewGame()
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        CheckPlayerBoundry()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
//        if contact.bodyA.categoryBitMask == satelliteCategory {
//            firstBody = contact.bodyA
//            secondBody = contact.bodyB
//        }
//
//        else if contact.bodyB.categoryBitMask == satelliteCategory {
//            firstBody = contact.bodyB
//            secondBody = contact.bodyA
//        }
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA 
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & bulletCategory) != 0 && (secondBody.categoryBitMask & asteroidCategory) != 0 {
            bulletDidCollide(bulletNode: firstBody.node as! SKSpriteNode, EnemyNode: secondBody.node as! SKSpriteNode, addScore: 5)
        }
        
        if (firstBody.categoryBitMask & bulletCategory) != 0 && (secondBody.categoryBitMask & satelliteCategory) != 0 {
            bulletDidCollide(bulletNode: firstBody.node as! SKSpriteNode, EnemyNode: secondBody.node as! SKSpriteNode, addScore: 10)
        }
        
    }


}
