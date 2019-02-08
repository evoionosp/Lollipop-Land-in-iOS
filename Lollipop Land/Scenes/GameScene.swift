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
    
    var score = Int(-1)
    var scoreLabel = SKLabelNode()
    var highscoreLbl = SKLabelNode()
    var taptoplayLbl = SKLabelNode()
    var restartBtn = SKSpriteNode()
    var pauseBtn = SKSpriteNode()
    var logoImg = SKSpriteNode()
    var popPair = SKNode()
     var moveAndRemove = SKAction()
    
    //CREATE THE BIRD ATLAS FOR ANIMATION
    let birdAtlas = SKTextureAtlas(named:"player")
    var birdSprites = Array<SKTexture>()
    var bird = SKSpriteNode()
    var repeatActionBird = SKAction()
    
    override func sceneDidLoad() {

    }
    
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == false{
            gameStarted =  true
            bird.physicsBody?.affectedByGravity = true
            createPauseBtn()
            logoImg.run(SKAction.scale(to: 0.5, duration: 0.3), completion: {
                self.logoImg.removeFromParent()
            })
            taptoplayLbl.removeFromParent()
            self.bird.run(repeatActionBird)
            SKAction.wait(forDuration: 3.5)
            let spawn = SKAction.run({
                () in
                self.popPair = self.createLollipops()
                self.popPair.run(SKAction.fadeIn(withDuration: 1))
                self.addChild(self.popPair)
                self.increaseScore()
            })
            
            let delay = SKAction.wait(forDuration: 2.2)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            let topPop = SKSpriteNode(imageNamed: "pop_1")
            let distance = CGFloat(self.frame.width + topPop.frame.width)
            let movePops = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.008 * distance))
            let removePops = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePops, removePops])
            
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: UIScreen.main.bounds.height/14))
            self.run(SKAction.playSoundFileNamed("jump", waitForCompletion: false))
        } else {
            if died == false {
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: UIScreen.main.bounds.height/14))
                self.run(SKAction.playSoundFileNamed("jump", waitForCompletion: false))
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
        
        
        birdSprites.append(birdAtlas.textureNamed("bird1"))
        birdSprites.append(birdAtlas.textureNamed("bird2"))
        birdSprites.append(birdAtlas.textureNamed("bird3"))
        birdSprites.append(birdAtlas.textureNamed("bird4"))
        
        self.bird = createBird()
        bird.zPosition = ZPositions.bird
        self.addChild(bird)
        
        
        let animatebird = SKAction.animate(with: self.birdSprites, timePerFrame: 0.1)
        self.repeatActionBird = SKAction.repeatForever(animatebird)
        
        scoreLabel = createScoreLabel()
        self.addChild(scoreLabel)
        
        highscoreLbl = createHighscoreLabel()
        self.addChild(highscoreLbl)
        
        createLogo()
        
        taptoplayLbl = createTaptoplayLabel()
        self.addChild(taptoplayLbl)
    }
    
    func increaseScore() {
        print("Height: \(UIScreen.main.bounds.height), Width: \(UIScreen.main.bounds.width)")
        score += 1
        scoreLabel.text = "\(score)"
    }
    
    
    func gameOver() {
        print("Game Over !")
        UserDefaults.standard.set(score, forKey: "RecentScore")
        if score > UserDefaults.standard.integer(forKey: "HighScore"){
            UserDefaults.standard.set(score, forKey: "HighScore")
        }
        enumerateChildNodes(withName: "popPair", using: ({
            (node, error) in
            node.speed = 0
            self.removeAllActions()
        }))
        if died == false{
            died = true
            self.run(SKAction.playSoundFileNamed("hit", waitForCompletion: true))
            createRestartBtn()
            pauseBtn.removeFromParent()
            self.bird.removeAllActions()
        }
       // let gameoverScene = GameoverScene(size: view!.bounds.size)
       // view!.presentScene(gameoverScene)
    }
    
    func createBird() -> SKSpriteNode {
        let bird = SKSpriteNode(texture: SKTextureAtlas(named:"player").textureNamed("bird1"))
        bird.size = CGSize(width: UIScreen.main.bounds.height / 13, height: UIScreen.main.bounds.height / 13)
        bird.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2)
        bird.physicsBody?.linearDamping = 1.1
        bird.physicsBody?.restitution = 0
        bird.physicsBody?.categoryBitMask = PhysicsCategories.birdCategory
        bird.physicsBody?.collisionBitMask = PhysicsCategories.lollipopCategory | PhysicsCategories.groundCategory
        bird.physicsBody?.contactTestBitMask = PhysicsCategories.lollipopCategory | PhysicsCategories.flowerCategory | PhysicsCategories.groundCategory
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true
        
        return bird
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
    
    func createLollipops() -> SKNode  {
        
        popPair = SKNode()
        popPair.name = "popPair"
        
        let topStick = SKSpriteNode(imageNamed: "stick")
        let bottomStick = SKSpriteNode(imageNamed: "stick")
        
        let currentPopTheme = Int(arc4random_uniform(UInt32(7)))
        let topPop = SKSpriteNode(imageNamed: "pop_\(currentPopTheme)") //pink
        let bottomPop = SKSpriteNode(imageNamed: "pop_\(currentPopTheme)") //green,
        
        let animatePop = SKAction.rotate(byAngle: 360, duration: 100)
        topPop.run(animatePop)
        bottomPop.run(animatePop)
        
        topStick.setScale(0.3)
        bottomStick.setScale(0.3)
        topPop.setScale(1)
        bottomPop.setScale(1)
        
        topStick.position = CGPoint(x: self.frame.width + UIScreen.main.bounds.height/10, y: UIScreen.main.bounds.height)  //+420
        bottomStick.position = CGPoint(x: self.frame.width + UIScreen.main.bounds.height/10, y: 0)  //-420
    
        //topStick.zRotation = CGFloat(Double.pi)
        
        topPop.position = CGPoint(x: topStick.position.x, y: topStick.position.y - topStick.frame.height/2 + UIScreen.main.bounds.height/16)
        bottomPop.position = CGPoint(x: bottomStick.position.x, y: -bottomStick.position.y + bottomStick.frame.height/2 - UIScreen.main.bounds.height/16)
        
        topStick.physicsBody = SKPhysicsBody(rectangleOf: topStick.size)
        topStick.physicsBody?.categoryBitMask = PhysicsCategories.lollipopCategory
        topStick.physicsBody?.collisionBitMask = PhysicsCategories.birdCategory
        topStick.physicsBody?.contactTestBitMask = PhysicsCategories.birdCategory
        topStick.physicsBody?.isDynamic = false
        topStick.physicsBody?.affectedByGravity = false
        
        bottomStick.physicsBody = SKPhysicsBody(rectangleOf: bottomStick.size)
        bottomStick.physicsBody?.categoryBitMask = PhysicsCategories.lollipopCategory
        bottomStick.physicsBody?.collisionBitMask = PhysicsCategories.birdCategory
        bottomStick.physicsBody?.contactTestBitMask = PhysicsCategories.birdCategory
        bottomStick.physicsBody?.isDynamic = false
        bottomStick.physicsBody?.affectedByGravity = false
        
        
        topPop.physicsBody = SKPhysicsBody(circleOfRadius: topPop.size.height/2)
        topPop.physicsBody?.categoryBitMask = PhysicsCategories.lollipopCategory
        topPop.physicsBody?.collisionBitMask = PhysicsCategories.birdCategory
        topPop.physicsBody?.contactTestBitMask = PhysicsCategories.birdCategory
        topPop.physicsBody?.isDynamic = false
        topPop.physicsBody?.affectedByGravity = false
    
        
        bottomPop.physicsBody = SKPhysicsBody(circleOfRadius: bottomPop.size.height/2)
        bottomPop.physicsBody?.categoryBitMask = PhysicsCategories.lollipopCategory
        bottomPop.physicsBody?.collisionBitMask = PhysicsCategories.birdCategory
        bottomPop.physicsBody?.contactTestBitMask = PhysicsCategories.birdCategory
        bottomPop.physicsBody?.isDynamic = false
        bottomPop.physicsBody?.affectedByGravity = false
    
        
        popPair.addChild(topStick)
        popPair.addChild(topPop)
        popPair.addChild(bottomStick)
        popPair.addChild(bottomPop)
        
        bottomStick.zPosition = ZPositions.stick
        topStick.zPosition = ZPositions.stick
        bottomPop.zPosition = ZPositions.pop
        topPop.zPosition = ZPositions.pop
        
        let randomPosition = random(min: -UIScreen.main.bounds.height/4, max: UIScreen.main.bounds.height/4)
        popPair.position.y += randomPosition
        
        popPair.run(moveAndRemove)
        
        return popPair
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min : CGFloat, max : CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategories.birdCategory && secondBody.categoryBitMask == PhysicsCategories.lollipopCategory || firstBody.categoryBitMask == PhysicsCategories.lollipopCategory && secondBody.categoryBitMask == PhysicsCategories.birdCategory || firstBody.categoryBitMask == PhysicsCategories.birdCategory && secondBody.categoryBitMask == PhysicsCategories.groundCategory || firstBody.categoryBitMask == PhysicsCategories.groundCategory && secondBody.categoryBitMask == PhysicsCategories.birdCategory{
            gameOver()
        } else if firstBody.categoryBitMask == PhysicsCategories.birdCategory && secondBody.categoryBitMask == PhysicsCategories.flowerCategory {
            increaseScore()
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == PhysicsCategories.flowerCategory && secondBody.categoryBitMask == PhysicsCategories.birdCategory {
            increaseScore()
            firstBody.node?.removeFromParent()
        }
    }
}



