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
    
    var enemiesArray = [SKSpriteNode]()
    let numberOfEnemies : UInt8 = 20
    let possibleEnemyImage : [String] = ["spaceMeteors_001", "spaceMeteors_002", "spaceMeteors_003", "spaceMeteors_004"]
    
    var scoreLabel : SKLabelNode!
    var score : Int = 0 {
        didSet {
            scoreLabel.text = "Score : \(score)"
        }
    }
    
    let enemyCategory:    UInt32 = 1 << 1
    let bulletCategory:   UInt32 = 1 << 2
    
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
    
    @objc func CreateNewEnemy() {
        var enemy : SKSpriteNode?
        
        let moveEnemyDown = SKAction.repeatForever(SKAction.moveBy(x: 0, y: -1, duration: 0.01))
        let rotateEnemy = SKAction.repeatForever(SKAction.rotate(byAngle: 25, duration: 5))
        
        let enemyXpos = randomNum(high:  self.frame.size.width/2, low: -1 * self.frame.size.width/2)
        let enemyYpos = randomNum(high:  2.5*self.frame.size.height, low: self.frame.size.height/2)
        let enemyOrigin : CGPoint = CGPoint(x: enemyXpos, y: enemyYpos)
        
        enemy = SKSpriteNode(imageNamed: possibleEnemyImage[Int(arc4random_uniform(4))])
        enemy?.scale(to: CGSize(width: player.size.height, height: player.size.height))
        enemy?.position = enemyOrigin
        enemy?.run(moveEnemyDown)
        enemy?.run(rotateEnemy)
        let enemyRadius : CGFloat = (enemy?.size.width)!/2

        enemy?.physicsBody? = SKPhysicsBody(circleOfRadius: enemyRadius)
        
        enemy?.physicsBody?.categoryBitMask = enemyCategory
        enemy?.physicsBody?.contactTestBitMask = bulletCategory
        enemy?.physicsBody?.collisionBitMask = 0
        enemy?.zPosition = 1
        
        enemiesArray.append(enemy!)
        self.addChild(enemy!)
    }
    
    @objc func CreateNewBullet() {
        let bulletOrigin : CGPoint = CGPoint(x: player.position.x, y: player.position.y+player.size.height/2)
        let moveBulletUp = SKAction.repeatForever(SKAction.moveBy(x: 0, y: 3, duration: 0.01))
        
        var bullet : SKSpriteNode?
        bullet = SKSpriteNode(imageNamed: "bulletImage")
        bullet?.position = bulletOrigin
        bullet?.run(moveBulletUp)
        
        bullet?.physicsBody? = SKPhysicsBody(rectangleOf: (bullet?.size)!)
        bullet?.physicsBody?.categoryBitMask =  bulletCategory
        bullet?.physicsBody?.contactTestBitMask = enemyCategory
        bullet?.physicsBody?.collisionBitMask = 0
        bullet?.physicsBody?.isDynamic = true
        bullet?.physicsBody?.usesPreciseCollisionDetection = true
        bullet?.zPosition = 1
        
        bulletsArray.append(bullet!)
        self.addChild(bullet!)
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
    
    func CheckBoundry(spriteArray : inout [SKSpriteNode], location : CGFloat) {
        var flag : Int = 0
        for item in spriteArray {
            if Int(location) > 0 {
                if item.position.y >= location {
                    item.run(SKAction.removeFromParent())
                    spriteArray.remove(at: flag)
                }
                flag += 1
            }
            else {
                if item.position.y <= location {
                    let randomXpos = randomNum(high:  self.frame.size.width/2, low: -1 * self.frame.size.width/2)
                    let randomYpos = randomNum(high:  2.5*self.frame.size.height, low: self.frame.size.height/2)
                    let randomPoint : CGPoint = CGPoint(x: randomXpos, y: randomYpos)
                    item.position = randomPoint
                    score -= 5
                }
                flag += 1
            }
        }
    }
    
    func SetBackground(image : UIImage){
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = image
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        view?.sendSubview(toBack: backgroundImage)
        view?.addSubview(backgroundImage)
    }
    
    func CreateAllEnemies(amountOfEnemies : UInt8) {
        for _ in 0...amountOfEnemies {
            CreateNewEnemy()
        }
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        CreatePlayer()
        CreateScoreBoard()
        CreateAllEnemies(amountOfEnemies: numberOfEnemies)
        bulletTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(CreateNewBullet) , userInfo: nil, repeats: true)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
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
        CheckBoundry(spriteArray : &bulletsArray, location: self.frame.height/2)
        CheckBoundry(spriteArray: &enemiesArray, location: -1*(self.frame.height/2))
        CheckPlayerBoundry()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("Hello")
    }
}


