//
//  GameScene.swift
//  Lollipop Land
//
//  Created by Shubh Patel on 2019-01-29.
//  Copyright © 2019 Shubh Patel. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameStarted = Bool(false)
    var died = Bool(false)
    
    var score = Int(0)
    var scoreLabel = SKLabelNode()
    var highscoreLbl = SKLabelNode()
    var taptoplayLbl = SKLabelNode()
    var restartBtn = SKSpriteNode()
    var pauseBtn = SKSpriteNode()
    var logoImg = SKSpriteNode()
    
    override func sceneDidLoad() {

    }
    
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == false{
            gameStarted =  true
            createPauseBtn()
            logoImg.run(SKAction.scale(to: 0.5, duration: 0.3), completion: {
                self.logoImg.removeFromParent()
            })
            taptoplayLbl.removeFromParent()
        } else {
            if died == false {
                //TODO: Move Bird
            }
        }
        
        
        for touch in touches{
            let location = touch.location(in: self)
            if died == true{
                if restartBtn.contains(location){
                    if UserDefaults.standard.object(forKey: "highestScore") != nil {
                        let hscore = UserDefaults.standard.integer(forKey: "highestScore")
                        if hscore < Int(scoreLabel.text!)!{
                            UserDefaults.standard.set(scoreLabel.text, forKey: "highestScore")
                        }
                    } else {
                        UserDefaults.standard.set(0, forKey: "highestScore")
                    }
                    resetScene()
                }
            } else {
                if pauseBtn.contains(location){
                    if self.isPaused == false{
                        self.isPaused = true
                        pauseBtn.texture = SKTexture(imageNamed: "play")
                    } else {
                        self.isPaused = false
                        pauseBtn.texture = SKTexture(imageNamed: "pause")
                    }
                }
            }
        }
    }
    
    
    func resetScene(){
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        setupScene()
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if gameStarted == true{
            if died == false{
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    let bg = node as! SKSpriteNode
                    bg.zPosition = ZPositions.background
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x:bg.position.x + bg.size.width * 2, y:bg.position.y)
                    }
                }))
            }
        }
    }
    
    
    func setupScene(){
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        for i in 0..<2
        {
            let background = SKSpriteNode(imageNamed: "bg_night")
            background.anchorPoint = CGPoint.init(x: 0, y: 0)
            background.position = CGPoint(x:CGFloat(i) * self.frame.width, y:0)
            background.zPosition = ZPositions.background
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        scoreLabel = createScoreLabel()
        self.addChild(scoreLabel)
        
        highscoreLbl = createHighscoreLabel()
        self.addChild(highscoreLbl)
        
        createLogo()
        
        taptoplayLbl = createTaptoplayLabel()
        self.addChild(taptoplayLbl)
    }
    
    func increaseScore() {
        score += 1
        scoreLabel.text = "\(score)"
    }
    
    
    func gameOver() {
        print("Game Over !")
        UserDefaults.standard.set(score, forKey: "RecentScore")
        if score > UserDefaults.standard.integer(forKey: "HighScore"){
            UserDefaults.standard.set(score, forKey: "HighScore")
        }
       // let gameoverScene = GameoverScene(size: view!.bounds.size)
       // view!.presentScene(gameoverScene)
    }
    
    
    
    func createRestartBtn() {
        restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.size = CGSize(width:100, height:100)
        restartBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBtn.zPosition = 6
        restartBtn.setScale(0)
        self.addChild(restartBtn)
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createPauseBtn() {
        pauseBtn = SKSpriteNode(imageNamed: "pause")
        pauseBtn.size = CGSize(width:40, height:40)
        pauseBtn.position = CGPoint(x: self.frame.width - 30, y: 30)
        pauseBtn.zPosition = 6
        self.addChild(pauseBtn)
    }
    
    func createScoreLabel() -> SKLabelNode {
        let scoreLbl = SKLabelNode()
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.6)
        scoreLbl.text = "\(score)"
        scoreLbl.zPosition = 5
        scoreLbl.fontSize = 50
        scoreLbl.fontName = "HelveticaNeue-Bold"
        
        let scoreBg = SKShapeNode()
        scoreBg.position = CGPoint(x: 0, y: 0)
        scoreBg.path = CGPath(roundedRect: CGRect(x: CGFloat(-50), y: CGFloat(-30), width: CGFloat(100), height: CGFloat(100)), cornerWidth: 50, cornerHeight: 50, transform: nil)
        let scoreBgColor = UIColor(red: CGFloat(0.0 / 255.0), green: CGFloat(0.0 / 255.0), blue: CGFloat(0.0 / 255.0), alpha: CGFloat(0.2))
        scoreBg.strokeColor = UIColor.clear
        scoreBg.fillColor = scoreBgColor
        scoreBg.zPosition = ZPositions.background
        scoreLbl.addChild(scoreBg)
        return scoreLbl
    }
    
    func createTaptoplayLabel() -> SKLabelNode {
        let taptoplayLbl = SKLabelNode()
        taptoplayLbl.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 100)
        taptoplayLbl.text = "Tap to play !"
        taptoplayLbl.fontColor = UIColor(red: 63/255, green: 79/255, blue: 145/255, alpha: 1.0)
        taptoplayLbl.zPosition = ZPositions.buttons
        taptoplayLbl.fontSize = 20
        taptoplayLbl.fontName = "HelveticaNeue"
        return taptoplayLbl
    }
    
    func createHighscoreLabel() -> SKLabelNode {
        let highscoreLbl = SKLabelNode()
        highscoreLbl.position = CGPoint(x: self.frame.width - 80, y: self.frame.height - 22)
        if let highestScore = UserDefaults.standard.object(forKey: "highestScore"){
            highscoreLbl.text = "Highest Score: \(highestScore)"
        } else {
            highscoreLbl.text = "Highest Score: 0"
        }
        highscoreLbl.zPosition = ZPositions.background
        highscoreLbl.fontSize = 15
        highscoreLbl.fontName = "Helvetica-Bold"
        return highscoreLbl
    }
    
    func createLogo() {
        logoImg = SKSpriteNode()
        logoImg = SKSpriteNode(imageNamed: "logo_lollipop")
        logoImg.size = CGSize(width: 200, height: 200)
        logoImg.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 100)
        logoImg.setScale(0.5)
        self.addChild(logoImg)
        logoImg.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
    }
}



