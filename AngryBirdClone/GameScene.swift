//
//  GameScene.swift
//  AngryBirdClone
//
//  Created by Andersson on 23/11/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var bullet = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        let bulletTexture = SKTexture(imageNamed: "bullet")
        bullet = childNode(withName: "bullet") as! SKSpriteNode
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bulletTexture.size().height / 10)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.mass = 0.3
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
