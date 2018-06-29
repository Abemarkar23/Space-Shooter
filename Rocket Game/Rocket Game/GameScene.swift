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


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var motionManager: CMMotionManager!
    
    var player : SKSpriteNode!
    var playerPos : CGPoint!
    
    var bulletsArray = [SKSpriteNode]()
    var bulletTimer : Timer!
    var asteroidTimer : Timer!
    
    let numberOfAsteroid : UInt8 = 30 // Default = 30
    let  possibleAsteroidImage : [String] = ["spaceMeteors_001", "spaceMeteors_002", "spaceMeteors_003", "spaceMeteors_004"]
    
    let bulletSpeed : TimeInterval = 6
    let bulletProductionRate : TimeInterval = 0.5
    
    let asteroidSpeed : TimeInterval = 6
    let asteroidProductionRate : TimeInterval = 0.75
    
    var scoreLabel : SKLabelNode!
    var score : Int = 0 {
        didSet {
            scoreLabel.text = "Score : \(score)"
        }
    }
    let asteroidCategory:UInt32 = 0x1 << 1
    let bulletCategory:UInt32 = 0x1 << 0
    
    func MovePlayer(direction: Bool) {
        
        if direction {
            // Move Right
            let move = SKAction.moveBy(x: 3, y: 0, duration: 0.01)
            let repeatMove = SKAction.repeatForever(move)
            player?.run(repeatMove)
        }
        else {
            // Move Left
            let move = SKAction.moveBy(x: -3, y: 0, duration: 0.01)
            let repeatMove = SKAction.repeatForever(move)
            player?.run(repeatMove)
        }
    }
    
    func CreatePlayer(){
        let playerPositionY : CGFloat = -0.4122938531 * self.frame.size.height
        player = SKSpriteNode(imageNamed: "spaceShipImage")
        player.position = CGPoint(x: 0 , y:  playerPositionY)
        
        self.addChild(player)
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
        bullet.physicsBody?.contactTestBitMask = asteroidCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        bullet.physicsBody?.isDynamic = true
        bullet.zPosition = 1
        
        bulletsArray.append(bullet)
        self.addChild(bullet)
    }
    
    func CreateScoreBoard() {
        scoreLabel =  SKLabelNode(text : "Score : 0")
        scoreLabel.position = CGPoint(x: 0 , y : 560)
        scoreLabel.fontName = "AvenirNext-DemiBold"
        scoreLabel.fontSize = 50
        scoreLabel.color = .white
        scoreLabel.zPosition = 2
        
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
    
    func  bulletDidCollideWithAsteroid(bulletNode:SKSpriteNode, asteroidNode:SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = asteroidNode.position
        self.addChild(explosion)
        
        bulletNode.removeFromParent()
        asteroidNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        
        score += 5
        
        
    }
    
    override func didMove(to view: SKView) {
        setUpPhysics()
        CreatePlayer()
        CreateScoreBoard()
        bulletTimer = Timer.scheduledTimer(timeInterval: bulletProductionRate, target: self, selector: #selector(CreateNewBullet) , userInfo: nil, repeats: true)
        asteroidTimer = Timer.scheduledTimer(timeInterval: asteroidProductionRate, target: self, selector: #selector(CreateNewAsteroid) , userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first{
            let touchLocation = touch.previousLocation(in: self)
            
            
            if touchLocation.x > 0 {
                MovePlayer(direction: true)
            }
                
            else if touchLocation.x < 0 {
                MovePlayer(direction: false)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        player?.removeAllActions()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player?.removeAllActions()
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        CheckPlayerBoundry()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA 
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & bulletCategory) != 0 && (secondBody.categoryBitMask & asteroidCategory) != 0 {
            bulletDidCollideWithAsteroid(bulletNode: firstBody.node as! SKSpriteNode, asteroidNode: secondBody.node as! SKSpriteNode)
            
        }
    }


}
