//
//  GameScene.swift
//  SnusToss
//
//  Created by Johannes Bastmark on 2017-12-09.
//  Copyright © 2017 Johannes Bastmark. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameState {
    case playing
    case menu
    static var current = GameState.playing
}

struct pc { // Physics Category
    static let none: UInt32 = 0x1 << 0
    static let snus: UInt32 = 0x1 << 1
    static let rBin: UInt32 = 0x1 << 2
    static let lBin: UInt32 = 0x1 << 3
    static let base: UInt32 = 0x1 << 4
    static let sG: UInt32 = 0x1 << 5
    static let eG: UInt32 = 0x1 << 6
}

struct t { // Start and end touch points
    static var start = CGPoint()
    static var end = CGPoint()
    
}

struct c { // Constants
    static var grav = CGFloat() // Gravity
    static var yVel = CGFloat() // Inital Y velocity
    static var airTime = TimeInterval () // Time the snus is in the air
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Variables
    
    var grids = false
    var bg = SKSpriteNode (imageNamed: "bgImage")
    var bFront = SKSpriteNode (imageNamed: "binFront")
    var bBack = SKSpriteNode (imageNamed: "binBack")
    var pSnus = SKSpriteNode (imageNamed: "snus")
    
    var snus = SKShapeNode()
    var leftWall = SKShapeNode()
    var rightWall = SKShapeNode()
    var base = SKShapeNode()
    var endG = SKShapeNode() // The Ground that the bin will sit on
    var startG = SKShapeNode() // Where the snus will start
    
    var windLbl = SKLabelNode()
    
    var pi = CGFloat (Double.pi)
    var wind = CGFloat()
    var touchingSnus = false
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            c.grav = -6
            c.yVel = self.frame.height / 4
            c.airTime = 2
        }
        else {
            // Ipad Constants
        }
        
        physicsWorld.gravity = CGVector(dx: 0, dy: c.grav)
        
        setUpGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if GameState.current == .playing{
                if snus.contains(location){
                    t.start = location
                    touchingSnus = true
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if GameState.current == .playing && !snus.contains(location) && touchingSnus{
                t.end = location
                touchingSnus = false
                fire()
            }
        }
    }

    func setUpGame() {
        GameState.current = .playing
        
        let bgScale = CGFloat(bg.frame.width / bg.frame.height) //Scale
        bg.size.height = self.frame.height
        bg.size.width = self.frame.height * bgScale
        bg.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        bg.zPosition = 0
        self.addChild(bg)
        
        let binScale = CGFloat(bBack.frame.width / bBack.frame.height)
        bBack.size.height = self.frame.height / 18
        bBack.size.width = bBack.size.height * binScale
        bBack.position = CGPoint(x: self.frame.width / 2.05, y: self.frame.height / 2.7)
        bBack.zPosition = bg.zPosition + 1
        self.addChild(bBack)
        
        let lidScale = CGFloat(bFront.frame.width / bFront.frame.height)
        bFront.size.height = self.frame.height / 15
        bFront.size.width = bFront.size.height * lidScale
        bFront.position = CGPoint(x: self.frame.width / 2 + 27, y: self.frame.height / 2.7)
        bFront.zPosition = bBack.zPosition + 3
        self.addChild(bFront)
        
        startG = SKShapeNode(rectOf: CGSize(width: self.frame.width, height: 5))
        startG.fillColor = .red
        startG.strokeColor = .clear
        startG.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 10)
        startG.zPosition = 10
        startG.alpha = grids ? 1 : 0
        startG.physicsBody = SKPhysicsBody(rectangleOf: startG.frame.size)
        startG.physicsBody?.categoryBitMask = pc.sG
        startG.physicsBody?.collisionBitMask = pc.snus
        startG.physicsBody?.contactTestBitMask = pc.none
        startG.physicsBody?.affectedByGravity = false
        startG.physicsBody?.isDynamic = false
        self.addChild(startG)
        
        endG = SKShapeNode(rectOf: CGSize(width: self.frame.width * 2, height: 5))
        endG.fillColor = .red
        endG.strokeColor = .clear
        endG.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2.7 - bFront.frame.height / 2)
        endG.zPosition = 10
        endG.alpha = grids ? 1 : 0
        endG.physicsBody = SKPhysicsBody(rectangleOf: endG.frame.size)
        endG.physicsBody?.categoryBitMask = pc.eG
        endG.physicsBody?.collisionBitMask = pc.snus
        endG.physicsBody?.contactTestBitMask = pc.none
        endG.physicsBody?.affectedByGravity = false
        endG.physicsBody?.isDynamic = false
        self.addChild(endG)
        
        leftWall = SKShapeNode(rectOf: CGSize(width: 3, height: 25))
        leftWall.fillColor = .red
        leftWall.strokeColor = .clear
        leftWall.position = CGPoint(x: bFront.position.x - bFront.frame.width / 2.2, y: bFront.position.y - bFront.frame.height / 5)
        leftWall.zPosition = 10
        leftWall.alpha = grids ? 1 : 0
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.frame.size)
        leftWall.physicsBody?.categoryBitMask = pc.lBin
        leftWall.physicsBody?.collisionBitMask = pc.snus
        leftWall.physicsBody?.contactTestBitMask = pc.none
        leftWall.physicsBody?.affectedByGravity = false
        leftWall.physicsBody?.isDynamic = false
        leftWall.zRotation = pi / 7
        self.addChild(leftWall)
        
        rightWall = SKShapeNode(rectOf: CGSize(width: 3, height: 25))
        rightWall.fillColor = .red
        rightWall.strokeColor = .clear
        rightWall.position = CGPoint(x: bFront.position.x , y: bFront.position.y - bFront.frame.height / 5)
        rightWall.zPosition = 10
        rightWall.alpha = grids ? 1 : 0
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.frame.size)
        rightWall.physicsBody?.categoryBitMask = pc.rBin
        rightWall.physicsBody?.collisionBitMask = pc.snus
        rightWall.physicsBody?.contactTestBitMask = pc.none
        rightWall.physicsBody?.affectedByGravity = false
        rightWall.physicsBody?.isDynamic = false
        rightWall.zRotation = -pi / 7
        self.addChild(rightWall)
        
        rightWall = SKShapeNode(rectOf: CGSize(width: 3, height: 25))
        rightWall.fillColor = .red
        rightWall.strokeColor = .clear
        rightWall.position = CGPoint(x: bFront.position.x , y: bFront.position.y - bFront.frame.height / 5)
        rightWall.zPosition = 10
        rightWall.alpha = grids ? 1 : 0
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.frame.size)
        rightWall.physicsBody?.categoryBitMask = pc.rBin
        rightWall.physicsBody?.collisionBitMask = pc.snus
        rightWall.physicsBody?.contactTestBitMask = pc.none
        rightWall.physicsBody?.affectedByGravity = false
        rightWall.physicsBody?.isDynamic = false
        rightWall.zRotation = -pi / 7
        self.addChild(rightWall)
        
        base = SKShapeNode(rectOf: CGSize(width: 38, height: 3))
        base.fillColor = .red
        base.strokeColor = .clear
        base.position = CGPoint(x: (leftWall.position.x + rightWall.position.x) / 2 , y: endG.position.y + 4)
        base.zPosition = 10
        base.alpha = grids ? 1 : 0
        base.physicsBody = SKPhysicsBody(rectangleOf: base.frame.size)
        base.physicsBody?.categoryBitMask = pc.base
        base.physicsBody?.collisionBitMask = pc.snus
        base.physicsBody?.contactTestBitMask = pc.snus
        base.physicsBody?.affectedByGravity = false
        base.physicsBody?.isDynamic = false
        self.addChild(base)
        
        windLbl.text = "Wind = 0"
        windLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 9/10)
        windLbl.fontSize = self.frame.width / 10
        windLbl.fontColor = .black
        windLbl.zPosition = bg.zPosition + 1
        self.addChild(windLbl)
        
        setWind()
        setSnus()
 
    }
    
    func setSnus(){
        
        pSnus.removeFromParent()
        snus.removeFromParent()
        
        snus.setScale(1)
        
        snus = SKShapeNode(rectOf: CGSize(width: bBack.frame.width / 1.5, height: 50))
        snus.fillColor = grids ? .blue : .clear
        snus.strokeColor = .clear
        snus.position = CGPoint(x: self.frame.width / 2 , y: startG.position.y + snus.frame.height / 2)
        snus.zPosition = 10
        
        pSnus.size = snus.frame.size
        snus.addChild(pSnus)
        
        snus.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "snus"), size: pSnus.size)
        snus.physicsBody?.categoryBitMask = pc.snus
        snus.physicsBody?.collisionBitMask = pc.sG
        snus.physicsBody?.contactTestBitMask = pc.base
        snus.physicsBody?.affectedByGravity = true
        snus.physicsBody?.isDynamic = true
        snus.zRotation = pi / 4
        self.addChild(snus)
    }
    
    func setWind() {
        let multi = CGFloat(20)
        let rnd = CGFloat(arc4random_uniform(UInt32(10))) - 5
        windLbl.text = "Wind: \(rnd)"
        wind = rnd * multi
    }
    
    func fire () {
        let xChange = t.end.x - t.start.x
        let angle = (atan(xChange / (t.end.y - t.start.y)) * 180 / pi)
        let amendedX = (tan(angle * pi / 180) * c.yVel) * 0.5
        
        // Throw it!
        let throwVec = CGVector(dx: amendedX * 0.25, dy: c.yVel * 0.25)
        snus.physicsBody?.applyImpulse(throwVec, at: t.start)
        
        // Shrink
        snus.run(SKAction.scale(by: 0.3, duration: c.airTime))
        
        // Change Collision Bitmask
        let wait = SKAction.wait(forDuration: c.airTime / 2)
        let changeCollision = SKAction.run({
            self.snus.physicsBody?.collisionBitMask = pc.sG | pc.eG | pc.base | pc.lBin | pc.rBin
            self.snus.zPosition = self.bg.zPosition + 2
        })
        
        // ADD WIND STEVE!
        let windWait = SKAction.wait(forDuration: c.airTime / 4)
        let push = SKAction.applyImpulse(CGVector(dx: wind * 0.3, dy: 0), duration: 1)
        snus.run(SKAction.sequence([windWait, push]))
        self.run(SKAction.sequence([wait,changeCollision]))
        
        // Wait & reset
        let wait4 = SKAction.wait(forDuration: 4)
        let reset = SKAction.run({
            self.setWind()
            self.setSnus()
        })
        self.run(SKAction.sequence([wait4,reset]))
      
    }
    
    
    
    
    
}
