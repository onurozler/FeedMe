import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private static var backgroundMusicPlayer: AVAudioPlayer!
    private var levelOver = false
    private var vineCut = false
    
   
    var scoreLabel: SKLabelNode!
    
    private static var score: Int! = 0
    var scoreTemp = 0
    override func didMove(to view: SKView) {

        setUpPhysics()
        setUpScenery()
        setUpPrize()
        setUpVines()
        setUpCrocodile()
        showLives()
        setUpAudio()
        setScoreLabel()

    }
    
    func setScoreLabel()
    {
        scoreTemp = GameScene.score
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(scoreTemp)"
        scoreLabel.fontSize = 25
        scoreLabel.position = CGPoint(x: size.width - 70 , y: size.height - 25)
        scoreLabel.zPosition = Layer.UI
        addChild(scoreLabel)
    }
    
    //MARK: - Level setup
    
    fileprivate func setUpPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsWorld.speed = 1.0
        
    }
    fileprivate func setUpScenery() {
        
        let background = SKSpriteNode(imageNamed: ImageName.Background)
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = Layer.Background
        background.size = CGSize(width: size.width, height: size.height)
        addChild(background)
        
        
        let water = SKSpriteNode(imageNamed: ImageName.Water)
        water.anchorPoint = CGPoint(x: 0, y: 0)
        water.position = CGPoint(x: 0, y: 0)
        water.zPosition = Layer.Water
        water.size = CGSize(width: size.width, height: size.height * 21.39 / 100)
        addChild(water)
    }
    fileprivate func setUpPrize() {
        
        prize = SKSpriteNode(imageNamed: ImageName.Prize)
        prize.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: ImageName.Prize), size: prize.size)
        prize.position = CGPoint(x: size.width * 0.5, y: size.height * 0.7)
        prize.zPosition = Layer.Prize
        prize.physicsBody?.categoryBitMask = PhysicsCategory.Prize
        prize.physicsBody?.collisionBitMask = 0
        prize.physicsBody?.density = 0.5
        prize.physicsBody?.isDynamic = true
        
        addChild(prize)
    }
    
    //MARK: - Vine methods
    
    fileprivate func setUpVines() {
        // 1 load vine data
        let dataFile = Bundle.main.path(forResource: GameConfiguration.VineDataFile, ofType: nil)
        let vines = NSArray(contentsOfFile: dataFile!) as! [NSDictionary]
        
        // 2 add vines
        for i in 0..<vines.count {
            // 3 create vine
            let vineData = vines[i]
            let length = Int(vineData["length"] as! NSNumber)
            let relAnchorPoint = CGPointFromString(vineData["relAnchorPoint"] as! String)
            let anchorPoint = CGPoint(x: relAnchorPoint.x * size.width,
                                      y: relAnchorPoint.y * size.height)
            let vine = VineNode(length: length, anchorPoint: anchorPoint, name: "\(i)")
            
            // 4 add to scene
            vine.addToScene(self)
            
            
            // 5 connect the other end of the vine to the prize
            vine.attachToPrize(prize)
        }
        
    }
    
    //MARK: - Croc methods
    private var crocodile: SKSpriteNode!
    private var prize: SKSpriteNode!
    fileprivate func setUpCrocodile() {
        
        crocodile = SKSpriteNode(imageNamed: ImageName.CrocMouthClosed)
        crocodile.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: ImageName.CrocMask), size: crocodile.size)
        crocodile.position = CGPoint(x: size.width * 0.75, y: size.height * 0.312)
        crocodile.zPosition = Layer.Crocodile
        crocodile.physicsBody?.categoryBitMask = PhysicsCategory.Crocodile
        crocodile.physicsBody?.collisionBitMask = 0
        crocodile.physicsBody?.contactTestBitMask = PhysicsCategory.Prize
        crocodile.physicsBody?.isDynamic = false
        addChild(crocodile)
        
        animateCrocodile()
        
    }
    fileprivate func animateCrocodile() {
        srand48(Int(Date().timeIntervalSince1970))
        let durationOpen = 2.0 + drand48() * 2.0
        let open = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthOpen))
        let waitOpen = SKAction.wait(forDuration: durationOpen)
        
        
        let durationClosed = drand48() + 3
        let close = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthClosed))
        let waitClosed = SKAction.wait(forDuration: durationClosed)
        
        let sequence = SKAction.sequence([waitOpen,open,waitClosed,close])
        let loop = SKAction.repeatForever(sequence)
        
        crocodile.run(loop)
    }
    fileprivate func runNomNomAnimationWithDelay(_ delay: TimeInterval) {
        
        crocodile.removeAllActions()
        
        let closeMouth = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthClosed))
        let wait = SKAction.wait(forDuration: delay)
        let openMouth = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthOpen))
        let sequence = SKAction.sequence([closeMouth, wait, openMouth, wait, closeMouth])
        
        crocodile.run(sequence)

    }
    
    //MARK: - Touch handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        vineCut = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let startPoint = touch.location(in: self)
            let endPoint = touch.previousLocation(in: self)
            
            // check if vine cut
            scene?.physicsWorld.enumerateBodies(alongRayStart: startPoint, end: endPoint,
                                                using: { (body, point, normal, stop) in
                                                    self.checkIfVineCutWithBody(body)
            })
            
            // produce some nice particles
            showMoveParticles(touchPosition: startPoint)
        }
        
        
    }
      private var particles: SKEmitterNode?
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        particles?.removeFromParent()
        particles = nil
        
        
    }
    fileprivate func showMoveParticles(touchPosition: CGPoint) {
        if particles == nil {
            particles = SKEmitterNode(fileNamed: "Particle.sks")
            particles!.zPosition = 1
            particles!.targetNode = self
            addChild(particles!)
        }
        particles!.position = touchPosition
        
        
    }
    
    //MARK: - Game logic
    
    override func update(_ currentTime: TimeInterval) {
        
        if levelOver {
            return
        }
        
        if prize.position.y <= 0 {
            levelOver = true
            run(splashSoundAction)
            switchToNewGameWithTransition(SKTransition.fade(withDuration: 1.0))
            GameScene.numLive = GameScene.numLive - 1
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if levelOver {
            return
        }
        
        
        if (contact.bodyA.node == crocodile && contact.bodyB.node == prize)
            || (contact.bodyA.node == prize && contact.bodyB.node == crocodile) {
            
            levelOver = true
            
            // shrink the pineapple away
            let shrink = SKAction.scale(to: 0, duration: 0.08)
            let removeNode = SKAction.removeFromParent()
            let sequence = SKAction.sequence([shrink, removeNode])
            prize.run(sequence)
            
            run(nomNomSoundAction)
            runNomNomAnimationWithDelay(0.15)
            
            // transition to next level
            switchToNewGameWithTransition(SKTransition.doorway(withDuration: 1.0))
            GameScene.numLive = 3
            
            GameScene.score = GameScene.score + 1
        }
    }
    private static var numLive: Int! = 3
     fileprivate func showLives(){
        
        for i in 0...GameScene.numLive-1{
            let lives = SKSpriteNode(imageNamed: ImageName.Heart)
            lives.anchorPoint = CGPoint(x: 0, y: 0)
            lives.position = CGPoint(x: CGFloat(CGFloat(i)*lives.size.width), y: size.height-lives.size.height)
            lives.zPosition = Layer.UI
           
            addChild(lives)
        }
    }
   
    
    fileprivate func checkIfVineCutWithBody(_ body: SKPhysicsBody) {
        if vineCut && !GameConfiguration.CanCutMultipleVinesAtOnce {
            return
        }
        
        
        let node = body.node!
        
        // if it has a name it must be a vine node
        if let name = node.name {
            
            run(sliceSoundAction)
            
            // snip the vine
            node.removeFromParent()
            
            // fade out all nodes matching name
            enumerateChildNodes(withName: name, using: { (node, stop) in
                let fadeAway = SKAction.fadeOut(withDuration: 0.25)
                let removeNode = SKAction.removeFromParent()
                let sequence = SKAction.sequence([fadeAway, removeNode])
                node.run(sequence)
            })
            
            crocodile.removeAllActions()
            crocodile.texture = SKTexture(imageNamed: ImageName.CrocMouthOpen)
            animateCrocodile()
            
            vineCut = true
        }
        
    }
    fileprivate func switchToNewGameWithTransition(_ transition: SKTransition) {
        
        let delay = SKAction.wait(forDuration: 1)
        let sceneChange = SKAction.run({
            let scene = GameScene(size: self.size)
            self.view?.presentScene(scene, transition: transition)
        })
        
        run(SKAction.sequence([delay, sceneChange]))
        
    }
    
    //MARK: - Audio
   
    private var sliceSoundAction: SKAction!
    private var splashSoundAction: SKAction!
    private var nomNomSoundAction: SKAction!
    fileprivate func setUpAudio() {
        
        if GameScene.backgroundMusicPlayer == nil {
            let backgroundMusicURL = Bundle.main.url(forResource: SoundFile.BackgroundMusic, withExtension: nil)
            
            do {
                let theme = try AVAudioPlayer(contentsOf: backgroundMusicURL!)
                GameScene.backgroundMusicPlayer = theme
                
            } catch {
                // couldn't load file :[
            }
            
            GameScene.backgroundMusicPlayer.numberOfLoops = -1
        }
        
        if !GameScene.backgroundMusicPlayer.isPlaying {
            GameScene.backgroundMusicPlayer.play()
        }
        
        sliceSoundAction = SKAction.playSoundFileNamed(SoundFile.Slice, waitForCompletion: false)
        splashSoundAction = SKAction.playSoundFileNamed(SoundFile.Splash, waitForCompletion: false)
        nomNomSoundAction = SKAction.playSoundFileNamed(SoundFile.NomNom, waitForCompletion: false)
    }

}
