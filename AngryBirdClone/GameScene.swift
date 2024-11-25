//
//  GameScene.swift
//  AngryBirdClone
//
//  Created by Andersson on 23/11/24.
//

import SpriteKit
import GameplayKit

enum ColliderType: UInt32 {
    case bullet = 1
    case enemy = 2
}

class GameScene: SKScene {
    private var bullet = SKSpriteNode()
    private var gameStarted = false
    private var originalPosition: CGPoint?
    private var attempts = 0
    private var attemptsLabel = SKLabelNode()
    private var enemies = [SKSpriteNode]()
    
    override func didMove(to view: SKView) {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.scene?.scaleMode = .aspectFit
        self.physicsWorld.contactDelegate = self
        
        bulletConfig()
        enemiesConfig()
        attemptsConfig()
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesActions(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesActions(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesActions(touches: touches, isTouchesEnded: true)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if enemies.isEmpty {
            resetGame()
        }
        updateBulletPosition()
    }
    
    private func resetGame() {
        for enemy in enemies {
            enemy.physicsBody = nil
            enemy.removeFromParent()
        }
        enemies.removeAll()
        enemiesConfig()
        attempts = 0
        gameStarted = false
    }
    
    private func bulletConfig() {
        let bulletTexture = SKTexture(imageNamed: "bullet")
        bullet = childNode(withName: "bullet") as! SKSpriteNode
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bulletTexture.size().height / 40)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.mass = 0.10
        originalPosition = bullet.position
        bullet.physicsBody?.contactTestBitMask = ColliderType.bullet.rawValue
        bullet.physicsBody?.categoryBitMask = ColliderType.bullet.rawValue
        bullet.physicsBody?.collisionBitMask = ColliderType.bullet.rawValue
    }
    
    private func enemiesConfig() {
        let enemyTexture = SKTexture(imageNamed: "enemy")
        let minX = -self.size.width / 2 + 400
        let maxX = self.size.width / 2 - 50
        let minY = -self.size.height / 2 + 200
        let maxY = self.size.height / 2 - 50
        for _ in 1...7 {
            let enemy = SKSpriteNode(texture: enemyTexture)
            enemy.name = "enemy"
            enemy.size = CGSize(width: 50, height: 50)
            let randomX = CGFloat(arc4random_uniform(UInt32(maxX - minX))) + minX
            let randomY = CGFloat(arc4random_uniform(UInt32(maxY - minY))) + minY
            enemy.position = CGPoint(x: randomX, y: randomY)
            enemy.zPosition = 1
            enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemyTexture.size().height / 35)
            enemy.physicsBody?.isDynamic = true
            enemy.physicsBody?.affectedByGravity = false
            enemy.physicsBody?.allowsRotation = true
            enemy.physicsBody?.mass = 0.4
            enemy.physicsBody?.collisionBitMask = ColliderType.enemy.rawValue
            self.addChild(enemy)
            enemies.append(enemy)
        }
    }
    
    private func attemptsConfig() {
        attemptsLabel.fontName = "comingSoon-Bold"
        attemptsLabel.fontColor = .red
        attemptsLabel.fontSize = 30
        attemptsLabel.text = "Attempts: 0"
        attemptsLabel.position = CGPoint(x: 0, y: self.frame.height / 2.5)
        attemptsLabel.zPosition = 2
        self.addChild(attemptsLabel)
    }
    
    private func updateBulletPosition() {
        if let bulletPhysicsBody = bullet.physicsBody {
            if bulletPhysicsBody.velocity.dx <= 1
                && bulletPhysicsBody.velocity.dy <= 1
                && bulletPhysicsBody.angularVelocity <= 1
                && gameStarted == true {
                updateBulletParameters(bulletPhysicsBody: bulletPhysicsBody)
                updateAttemptsParameters()
                gameStarted = false
            }
        }
    }
    
    private func updateBulletParameters(bulletPhysicsBody: SKPhysicsBody) {
        bulletPhysicsBody.affectedByGravity = false
        bulletPhysicsBody.velocity = CGVector(dx: 0, dy: 0)
        bulletPhysicsBody.angularVelocity = 0
        bullet.zPosition = 1
        bullet.zRotation = 0.6
        bullet.position = originalPosition!
    }
    
    private func updateAttemptsParameters() {
        attempts += 1
        attemptsLabel.text = "Attempts: \(attempts)"
    }
    
    private func touchesActions(touches: Set<UITouch>, isTouchesEnded: Bool = false) {
        if !gameStarted {
            if let touch = touches.first {
                let location = touch.location(in: self)
                let nodes = nodes(at: location)
                if !nodes.isEmpty {
                    for node in nodes {
                        if let sprite = node as? SKSpriteNode {
                            if sprite == bullet {
                                if isTouchesEnded {
                                    let dx = -(location.x - originalPosition!.x)
                                    let dy = -(location.y - originalPosition!.y)
                                    let impulse = CGVector(dx: dx, dy: dy)
                                    bullet.physicsBody?.applyImpulse(impulse)
                                    bullet.physicsBody?.affectedByGravity = true
                                    gameStarted = true
                                    return
                                }
                                bullet.position = location
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func deleteEnemy(enemyNode: SKSpriteNode, enemyBody: SKPhysicsBody) {
        enemyNode.physicsBody?.affectedByGravity = true
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            if let index = self.enemies.firstIndex(of: enemyNode) {
                self.enemies.remove(at: index)
            }
            enemyNode.physicsBody = nil
            enemyNode.removeFromParent()
            enemyNode.isHidden = true
            enemyBody.isDynamic = false
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let isBulletCollision =
        contact.bodyA.collisionBitMask == ColliderType.bullet.rawValue ||
        contact.bodyB.collisionBitMask == ColliderType.bullet.rawValue
        if isBulletCollision {
            let bulletBody = contact.bodyA.collisionBitMask == ColliderType.bullet.rawValue
            ? contact.bodyA : contact.bodyB
            let enemyBody = bulletBody == contact.bodyA ? contact.bodyB : contact.bodyA
            if let enemyNode = enemyBody.node as? SKSpriteNode {
                deleteEnemy(enemyNode: enemyNode, enemyBody: enemyBody)
            }
        }
    }
}
