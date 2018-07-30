// test
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

let bulletCategory : UInt32 =     0x1 << 0
let asteroidCategory : UInt32 =   0x1 << 1
let satelliteCategory : UInt32 =  0x1 << 2
let playerCategory : UInt32 =     0x1 << 3

var LivesArray = [SKSpriteNode]();

class GameScene : SKScene, SKPhysicsContactDelegate {
    var gameState : Bool = true
    
    var player : Player!
    
    let bulletSpeed : TimeInterval = 1
    var bulletProductionRate : TimeInterval = 0.50
    var bulletTimer : Timer!
    
    var scoreLabel : SKLabelNode!
    var score : Int = 0
    
    var GamePauseLabel : SKLabelNode = SKLabelNode(text: "Game Paused, tap to unpause")
    var GameOverLabel : SKLabelNode = SKLabelNode(text: "Game Over")
    var PressQuitLabel : SKLabelNode  = SKLabelNode(text: "Press home to go back to main menu")
    var GameOverLabelAdded : Bool = false
    
    var numberOfGames : UInt32 = 0
    var cumulativeScore : UInt32 = 0
    
    func setToDifficulty() {
        if gameDifficulty == Difficulty.hard {
            asteroidSpeed = 3.5
            asteroidProductionRate = 0.50
            satelliteSpeed = 3
            satelliteProductionRate = 3
            satelliteScore = 20
            asteroidScore = 15
        }
        if gameDifficulty == Difficulty.medium {
            asteroidSpeed = 6
            asteroidProductionRate = 0.75
            satelliteSpeed  = 4
            satelliteProductionRate  = 4
            satelliteScore = 15
            asteroidScore = 10
        }
        if gameDifficulty == Difficulty.easy {
            asteroidSpeed = 7
            asteroidProductionRate = 1
            satelliteSpeed = 5.5
            satelliteProductionRate = 5
            satelliteScore = 10
            asteroidScore = 5
        }
    }
    
    func UpdateAverage() {
        numberOfGames += 1
        cumulativeScore += UInt32(score)
        
        average = cumulativeScore/numberOfGames
    }
    
    func CreatePlayer(){
        player = Player()
        player.createPlayer(playerYPosition: Int(-0.4122938531 * self.frame.size.height))
        self.addChild(player)
    }
    
    @objc func CreateNewSatellite() {
        let satellite : SKSpriteNode = SKSpriteNode(imageNamed: possibleSatelliteImage[Int(arc4random_uniform(2))])
        satellite.SatelliteEnemySettings(screenHeight: self.frame.height, screenWidth: self.frame.width)
        self.addChild(satellite)
        
    }
    
    @objc func CreateNewAsteroid() {
        let asteroid : SKSpriteNode = SKSpriteNode(imageNamed: possibleAsteroidImage[Int(arc4random_uniform(4))])
        asteroid.AsteroidEnemySettings(screenHeight: self.frame.height, screenWidth: self.frame.width, player: player)
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
        bullet.name = "Bullet"
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
        if LivesArray.count >= 1 {
            LivesArray.last?.removeFromParent()
            LivesArray.removeLast()
        }
    }
    
    func GameOver(){
        self.isPaused = true
        gameState = false
        self.removeAllChildren()
        GameOverLabel.applyAdditionalSKLabelDesign(labelSize: 70, labelPosition: CGPoint(x: self.frame.midX - self.frame.maxX/2, y: frame.midY), layoutWidth: self.frame.size.width)
        PressQuitLabel.applyAdditionalSKLabelDesign(labelSize: 40, labelPosition: CGPoint(x: frame.minX, y: frame.minY+20), layoutWidth: self.frame.size.width-30)
        
        scoreLabel.position = GameOverLabel.position
        scoreLabel.position.y -= 35
        
        self.addChild(scoreLabel)
        self.addChild(PressQuitLabel)
        GameOverLabel.text = "Game Over"
        GameOverLabel.isHidden = false
        
        if latestScore != nil && score >= latestScore{
            highScore = score
        }
        else if latestScore == nil {
            highScore = score
        }
        
        latestScore = score
        score = 0
        UpdateAverage()
        
        self.addChild(GameOverLabel)
        
    }
    
    
    func CreateScoreBoard() {
        scoreLabel = SKLabelNode(text: "Score : 0")
        scoreLabel.applyAdditionalSKLabelDesign(labelSize: 50, labelPosition: CGPoint(x: frame.minX, y: frame.minY+50), layoutWidth: self.frame.size.width-30)
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
        
        if score % 1 == 0 {
            increaseDifficulty()
        }
        
        latestScore = score
        
    }
    
    func increaseDifficulty () {
        if asteroidProductionRate > 0.50{
            asteroidSpeed -= 0.5
            asteroidProductionRate -= 0.2
            satelliteSpeed -= 0.6
            satelliteProductionRate -= 0.6
            satelliteScore += 2
            asteroidScore += 1
            bulletProductionRate -= 0.05
            
            satelliteTimer.invalidate()
            bulletTimer.invalidate()
            asteroidTimer.invalidate()
            
            startTimers()
        }
        else {
            print("limit reached")
        }
    }
    
    func startTimers() {
        asteroidTimer = Timer.scheduledTimer(timeInterval: asteroidProductionRate, target: self, selector: #selector(CreateNewAsteroid) , userInfo: nil, repeats: true)
        bulletTimer = Timer.scheduledTimer(timeInterval: bulletProductionRate, target: self, selector: #selector(CreateNewBullet), userInfo: nil, repeats: true)
        satelliteTimer = Timer.scheduledTimer(timeInterval: satelliteProductionRate, target: self, selector: #selector(CreateNewSatellite) , userInfo: nil, repeats: true)
    }
    
    func StartNewGame() {
        setUpPhysics()
        CreatePlayer()
        CreateScoreBoard()
        CreateLives()
        setToDifficulty()
        startTimers()
        GameOverLabel.isHidden = true
        GamePauseLabel.applyAdditionalSKLabelDesign(labelSize: 70, labelPosition: CGPoint(x: frame.minX+10, y: frame.midY), layoutWidth: self.frame.size.width-30)
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
        if self.isPaused == false {
            GamePauseLabel.isHidden = false
            bulletTimer.invalidate()
            if satelliteTimer != nil {
                satelliteTimer.invalidate()
            }
            asteroidTimer.invalidate()
            self.isPaused = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == true{
            self.isPaused = false
            GamePauseLabel.isHidden = true
            player.position = (touches.first?.location(in: self))!
            if bulletTimer.isValid == false && asteroidTimer.isValid == false {
                startTimers()
                if score > sateliteScoreThreshold{
                    satelliteTimer = Timer.scheduledTimer(timeInterval: satelliteProductionRate, target: self, selector:    #selector(CreateNewSatellite) , userInfo: nil, repeats: true)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == true{
            GamePauseLabel.isHidden = true
            self.isPaused = false
            if self.isPaused == false {
                for touch in touches {
                    if touch.location(in: self).y >= self.frame.minY + 10{
                        player.position = touch.location(in: self)
                    }
                }
            }
            if bulletTimer.isValid == false && satelliteTimer?.isValid == false && asteroidTimer.isValid == false {
                startTimers()
                satelliteTimer = Timer.scheduledTimer(timeInterval: satelliteProductionRate, target: self, selector: #selector(CreateNewSatellite) , userInfo: nil, repeats: true)
            }
        }
    }

    
    func didBegin(_ contact: SKPhysicsContact) {
        if self.isPaused == false{
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
                bulletDidCollide(bulletNode: firstBody.node as! SKSpriteNode, EnemyNode: secondBody.node as! SKSpriteNode, addScore: asteroidScore)
            }
            
            if (firstBody.categoryBitMask & bulletCategory) != 0 && (secondBody.categoryBitMask & satelliteCategory) != 0 {
                bulletDidCollide(bulletNode: firstBody.node as! SKSpriteNode, EnemyNode: secondBody.node as! SKSpriteNode, addScore: satelliteScore)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if LivesArray.count == 0 {
            GameOver()
        }
        print(self.children.count)
    }
}
