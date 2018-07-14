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

var latestScore : Int!
var highScore : Int!
var average : UInt32 = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player : SKSpriteNode!
    var LivesArray = [SKSpriteNode]()
    
    let bulletSpeed : TimeInterval = 1
    let bulletProductionRate : TimeInterval = 0.50
    var bulletTimer : Timer!
    
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
    
    var GamePauseLabel : SKLabelNode = SKLabelNode(text: "Game Paused, tap to unpause")
    var GameOverLabel : SKLabelNode = SKLabelNode(text: "Game Over")
    var GameOverLabelAdded : Bool = false
    
    let bulletCategory:UInt32 =     0x1 << 0
    let asteroidCategory:UInt32 =   0x1 << 1
    let satelliteCategory:UInt32 =  0x1 << 2
    let playerCategory:UInt32 =     0x1 << 3
    
    var gameState : Bool = true
    
    var numberOfGames : UInt32 = 0
    var cumulativeScore : Int = 0
    
    func setToDifficulty() {
        if gameDifficulty == Difficulty.hard {
            asteroidSpeed = 4
            asteroidProductionRate = 0.50
            satelliteSpeed = 3
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
    
    func UpdateAverage () {
        numberOfGames += 1
        cumulativeScore += score
        
    }
    
    func CreatePlayer(){
        let playerPositionY : CGFloat = -0.4122938531 * self.frame.size.height
        player = SKSpriteNode(imageNamed: "spaceShipImage")
        player.position = CGPoint(x: 0 , y:  playerPositionY)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = satelliteCategory + asteroidCategory
        player.physicsBody?.collisionBitMask = 0
        
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
        
        let moveAsteroidToBottom : SKAction = SKAction.move(to: CGPoint(x: position, y: -1 * self.size.height/2 - asteroid.size.height), duration: asteroidSpeed)
        var actionArray = [SKAction]()
        
        actionArray.append(moveAsteroidToBottom)
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
        print(LivesArray.count)
        if LivesArray.count != 0 {
            LivesArray.last?.removeFromParent()
            LivesArray.removeLast()
        }
        if LivesArray.count <= 0 {
            GameOver()
        }
    }
    
    func setupLabel(Label : inout SKLabelNode, fontSize : CGFloat) {
        Label.fontName = "AvenirNext-DemiBold"
        Label.fontSize = fontSize
        Label.color = .white
        Label.zPosition = 2
        Label.lineBreakMode = .byWordWrapping
        Label.numberOfLines = 2
        Label.preferredMaxLayoutWidth = self.frame.size.width-30
        Label.numberOfLines = 2
        Label.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func GameOver(){
        gameState = false
        self.removeAllChildren()
        setupLabel(Label: &GameOverLabel, fontSize: 100)
        GameOverLabel.isHidden = false
        if satelliteTimer != nil{
            satelliteTimer.invalidate()
        }
        if latestScore != nil && score >= latestScore{
            highScore = score
        }
        latestScore = score
        score = 0
        satelliteTimer.invalidate()
        asteroidTimer.invalidate()
        bulletTimer.invalidate()
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
            satelliteTimer = Timer.scheduledTimer(timeInterval: satelliteProductionRate, target: self, selector: #selector(CreateNewSatellite) , userInfo: nil, repeats: true)
        }
        
    }
    
    func startTimers() {
        asteroidTimer = Timer.scheduledTimer(timeInterval: asteroidProductionRate, target: self, selector: #selector(CreateNewAsteroid) , userInfo: nil, repeats: true)
        bulletTimer = Timer.scheduledTimer(timeInterval: bulletProductionRate, target: self, selector: #selector(CreateNewBullet), userInfo: nil, repeats: true)
    }
    
    func StartNewGame() {
        setUpPhysics()
        CreatePlayer()
        CreateScoreBoard()
        CreateLives()
        setToDifficulty()
        startTimers()
        GameOverLabel.isHidden = true
        gameState = true
        setupLabel(Label: &GamePauseLabel, fontSize: 100)
        GamePauseLabel.isHidden = true
        self.addChild(GamePauseLabel)
    }
    
    override func didMove(to view: SKView) {
        StartNewGame()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        player?.removeAllActions()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player?.removeAllActions()
        GamePauseLabel.isHidden = false
        
        bulletTimer.invalidate()
        satelliteTimer.invalidate()
        asteroidTimer.invalidate()
        
        self.isPaused = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isPaused = false
        if gameState == false{
            StartNewGame()
        }
        GamePauseLabel.isHidden = true
        if let touch = touches.first {
            player.position = (touches.first?.location(in: self))!
        }
        if bulletTimer.isValid == false && satelliteTimer.isValid == false && asteroidTimer.isValid == false {
            startTimers()
            satelliteTimer = Timer.scheduledTimer(timeInterval: satelliteProductionRate, target: self, selector: #selector(CreateNewSatellite) , userInfo: nil, repeats: true)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        GamePauseLabel.isHidden = true
        self.isPaused = false
        if self.isPaused == false{
            for touch in touches {
                player.position = touch.location(in: self)
            }
        }
        if bulletTimer.isValid == false && satelliteTimer.isValid == false && asteroidTimer.isValid == false {
            startTimers()
            satelliteTimer = Timer.scheduledTimer(timeInterval: satelliteProductionRate, target: self, selector: #selector(CreateNewSatellite) , userInfo: nil, repeats: true)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA 
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if contact.bodyA.categoryBitMask == playerCategory  {
            GameOver()
        }
        
        if (firstBody.categoryBitMask & bulletCategory) != 0 && (secondBody.categoryBitMask & asteroidCategory) != 0 {
            bulletDidCollide(bulletNode: firstBody.node as! SKSpriteNode, EnemyNode: secondBody.node as! SKSpriteNode, addScore: 5)
        }
        
        if (firstBody.categoryBitMask & bulletCategory) != 0 && (secondBody.categoryBitMask & satelliteCategory) != 0 {
            bulletDidCollide(bulletNode: firstBody.node as! SKSpriteNode, EnemyNode: secondBody.node as! SKSpriteNode, addScore: 10)
        }
        
    }
    
    
}
