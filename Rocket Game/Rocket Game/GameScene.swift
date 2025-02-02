//  test
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
var highScore : Int = 0
var average : UInt32 = 0

let bulletCategory : UInt32 =     0x1 << 0
let asteroidCategory : UInt32 =   0x1 << 1
let satelliteCategory : UInt32 =  0x1 << 2
let playerCategory : UInt32 =     0x1 << 3



var LivesArray = [SKSpriteNode]();

let bulletSpeed : TimeInterval = 1

class GameScene : SKScene, SKPhysicsContactDelegate {
    
    var locationDict : [String : CGFloat] = [:]
    
    let shipFlame : SKEmitterNode = SKEmitterNode(fileNamed: "ShipFlame")!
    let tutorialTextArray : [String] = ["Drag Ship Around the screen", "Hitting Enemies is Game Over", "Ending touch with screen pauses the game", "If Enemy Passes your view, you lose one life indicated in the top left corner"]

    let starField : SKEmitterNode = SKEmitterNode(fileNamed: "StarBackground")!
    
    var gameState : Bool = true
    
    var player : Player!
    let playerSpeed : Double = 0.2
    
    var bulletProductionRate : TimeInterval = 0.50
    
    var scoreLabel : SKLabelNode!
    var score : Int = 0
    
    var GamePauseLabel : SKLabelNode = SKLabelNode(text: "Paused")
    var GameOverLabel : SKLabelNode = SKLabelNode(text: "Game Over")
    var PressQuitLabel : SKLabelNode  = SKLabelNode(text: "Press home to go to main menu")
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
    
    func setConstraints() {
        locationDict["Top"] = self.frame.maxY
        locationDict["Middle"] = (view?.frame.minY)! // works for X value as well
        locationDict["Bottom"] = locationDict["Top"]! * -1
        
        locationDict["Right"] = (view?.frame.maxX)! - 5
        locationDict["Left"] = locationDict["Right"]! * -1
    }
    
    func UpdateAverage() {
        numberOfGames += 1
        cumulativeScore += UInt32(score)
        
        average = cumulativeScore/numberOfGames
    }
    
    func CreatePlayer(){
        player = Player()
        player.createPlayer(playerYPosition: Int(self.frame.minY - player.size.height - 10), intendedPosition: CGPoint(x: locationDict["Middle"]!, y: locationDict["Bottom"]! + 50))
        shipFlame.position = CGPoint(x: player.frame.midX, y: player.frame.minY)
        self.addChild(shipFlame)
        self.addChild(player)
    }
    
    func SpawnSatellite() {
        let satellite : SKSpriteNode = SKSpriteNode(imageNamed: possibleSatelliteImage[Int(arc4random_uniform(2))])
        satellite.SatelliteEnemySettings(screenMaxX: locationDict["Right"]!, screenMinX: locationDict["Left"]!, screenMaxY: locationDict["Top"]!, screenMinY: locationDict["Bottom"]!)
        self.addChild(satellite)
    }
    
    func SpawnAsteroid() {
        let asteroid : SKSpriteNode = SKSpriteNode(imageNamed: possibleAsteroidImage[Int(arc4random_uniform(4))])
        asteroid.AsteroidEnemySettings(screenMaxX: locationDict["Right"]!, screenMinX: locationDict["Left"]!, screenMaxY: locationDict["Top"]!, screenMinY: locationDict["Bottom"]!, player: player)
        self.addChild(asteroid)
    }
    
    func SpawnBullet() {
        let bullet = Bullet()
        bullet.createBullet(player: player, topYCoor: locationDict["Top"]!)
        self.addChild(bullet)
    }
    
    func startTimers() {
        
        if self.action(forKey: "asteroid") != nil {
            self.removeAction(forKey: "asteroid")
            self.removeAction(forKey: "satellite")
            self.removeAction(forKey: "Bullet")
        }
        
        var createNewAsteroid : SKAction = SKAction.run {self.SpawnAsteroid()}
        var createNewSatellite : SKAction = SKAction.run {self.SpawnSatellite()}
        var createNewBullet : SKAction = SKAction.run {self.SpawnBullet()}

        createNewAsteroid = SKAction.sequence([createNewAsteroid, SKAction.wait(forDuration: asteroidProductionRate)])
        createNewSatellite = SKAction.sequence([createNewSatellite, SKAction.wait(forDuration: satelliteProductionRate)])
        createNewBullet = SKAction.sequence([createNewBullet, SKAction.wait(forDuration: bulletProductionRate)])

        self.run(SKAction.repeatForever(createNewSatellite), withKey: "satellite")
        self.run(SKAction.repeatForever(createNewAsteroid), withKey: "asteroid")
        self.run(SKAction.repeatForever(createNewBullet), withKey: "Bullet")
    }
    

    
    func CreateLives() {
        
        for life in 0...2 {
            let newLife = SKSpriteNode(imageNamed: "spaceShipImage")
            newLife.position = CGPoint(x: self.frame.maxX - (CGFloat(life) * (newLife.size.width/10 * 7)) - newLife.size.height, y: locationDict["Top"]! - 20) // self.frame.maxY-newLife.size.height/2
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
//                case 1136:
//                  iPhone 5 or 5S or 5C
//                case 1334:
//                  iPhone 6/6S/7/8
//                case 2208:
//                  iPhone 6+/6S+/7+/8+
                case 2436:
//                  iPhone X
                    newLife.position = CGPoint(x: self.frame.maxX - newLife.size.width - 10, y: self.frame.maxY - (CGFloat(life) * (newLife.size.width/10 * 7)) - newLife.size.width/2)
                default:
                    print("unknown")
                }
            }
            newLife.run(SKAction.scale(by: 2/3, duration: 0.1))
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
        self.removeAllChildren() // hi
        GameOverLabel.applyAdditionalSKLabelDesign(labelSize: 70, labelPosition: CGPoint(x: self.frame.midX, y: frame.midY), layoutWidth: self.frame.size.width)
        PressQuitLabel.applyAdditionalSKLabelDesign(labelSize: 40, labelPosition: CGPoint(x: self.frame.midX, y: locationDict["Bottom"]!+110), layoutWidth: self.frame.size.width/2)
        
        scoreLabel.position = GameOverLabel.position
        scoreLabel.position.y -= 35
        
        self.addChild(scoreLabel)
        self.addChild(PressQuitLabel)
        GameOverLabel.text = "Game Over"
        GameOverLabel.isHidden = false
        print(latestScore)
        if latestScore != nil && highScore <= latestScore{
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
        scoreLabel.applyAdditionalSKLabelDesign(labelSize: 50, labelPosition: CGPoint(x: self.frame.midX, y: self.frame.maxY+50) , layoutWidth: self.frame.size.width-30)
        scoreLabel.run(SKAction.move(to: CGPoint(x: self.frame.midX, y: locationDict["Top"]!  - player.size.height - 20), duration: 2))
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
            asteroidSpeed -= 0.6
            asteroidProductionRate -= 0.2
            satelliteSpeed -= 0.6
            satelliteProductionRate -= 0.75
            bulletProductionRate -= 0.05
            startTimers()
        }
    }
    

    
    func StartNewGame() {
        setConstraints()
        setUpPhysics()
        CreatePlayer()
        CreateScoreBoard()
        CreateLives()
        setToDifficulty()
        startTimers()
        GameOverLabel.isHidden = true
        GamePauseLabel.applyAdditionalSKLabelDesign(labelSize: 70, labelPosition: CGPoint(x: self.frame.midX, y: self.frame.midY), layoutWidth: self.frame.size.width/2)
        GamePauseLabel.isHidden = true
        
        starField.position.y += self.frame.height/2 + 30
        starField.zPosition = -4
        starField.advanceSimulationTime(10)
        
        self.addChild(starField)
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
            self.isPaused = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == true{
            self.isPaused = false
            GamePauseLabel.isHidden = true
            var movePlayer = SKAction.move(to: (touches.first?.location(in: self))!, duration: playerSpeed)
            player.run(movePlayer)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == true{
            GamePauseLabel.isHidden = true
            self.isPaused = false
            if self.isPaused == false {
                for touch in touches {
                    if touch.location(in: self).y >= self.frame.minY + 10{
                        var movePlayer = SKAction.move(to: (touches.first?.location(in: self))!, duration: playerSpeed)
                        player.run(movePlayer)
                    }
                }
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
                RemoveOneLife()
                let enemyWithPlayer = (contact.bodyB.node as! SKSpriteNode)
                let explosion = SKEmitterNode(fileNamed: "Explosion")!
                explosion.position = enemyWithPlayer.position
                self.run(SKAction.wait(forDuration: 2)) {
                    explosion.removeFromParent()
                }
                self.addChild(explosion)
                enemyWithPlayer.removeFromParent()
                
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
        if LivesArray.count <= 0 {
            GameOver()
        }
        shipFlame.position = CGPoint(x: player.frame.midX, y: player.frame.minY)
    }

}
