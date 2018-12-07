import SpriteKit

class StartScene: SKScene, SKPhysicsContactDelegate {
    
    var gameNameLabel: SKLabelNode!
    var playbutton: SKSpriteNode!
    var optionsButton: SKSpriteNode!
    var optionsButtonLabel: SKLabelNode!
    
    var musicLabel: SKLabelNode!
    var effectsLabel: SKLabelNode!
    
    
    public static var effects: String! = "On"
    public static var musics: String! = "On"
    
    override func didMove(to view: SKView) {
 
        createOptions()

        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            let objects = nodes(at: location)
            
            if objects.contains(playbutton)
            {
                //self.scene?.view?.presentScene(GameScene(size:self.size))
                let gameSceneTemp = GameScene(size: self.size)
                self.scene?.view?.presentScene(gameSceneTemp, transition: SKTransition.doorsCloseHorizontal(withDuration: 1.0))
            }
            else if objects.contains(optionsButton){
              optionMenu()
            }
            else if(objects.contains(musicLabel)){
                if(StartScene.musics == "On")
                {
                    StartScene.musics = "Off"
                }
                else
                {
                    StartScene.musics = "On"
                }
                checkMusic()
            }
            else if(objects.contains(effectsLabel)){
                if(StartScene.effects == "On")
                {
                    StartScene.effects = "Off"
                }
                else
                {
                    StartScene.effects = "On"
                }
                checkEffect()
            }
        }
    }
    
    func createOptions(){
        
        let background = SKSpriteNode(imageNamed: ImageName.Background)
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = Layer.Background
        background.size = CGSize(width: size.width, height: size.height)
        addChild(background)
        
        gameNameLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")
        gameNameLabel.text = "Feed Me!"
        gameNameLabel.fontSize = 40.0
        gameNameLabel.position = CGPoint(x: frame.midX, y: frame.midY+180)
        gameNameLabel.zPosition = 1
        addChild(gameNameLabel)
        
        playbutton = SKSpriteNode(imageNamed: ImageName.ButtonRestart)
        playbutton.position = CGPoint(x: frame.midX, y: frame.midY+100)
        playbutton.zPosition = 1
        addChild(playbutton)
        
        optionsButton = SKSpriteNode(imageNamed: ImageName.Button)
        optionsButton.position = CGPoint(x: frame.midX, y: frame.midY)
        optionsButton.zPosition = 1
        addChild(optionsButton)
        
        optionsButtonLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")
        optionsButtonLabel.text = "Options"
        optionsButtonLabel.fontSize = 40.0
        optionsButtonLabel.position = CGPoint(x: frame.midX, y: frame.midY-10)
        optionsButtonLabel.zPosition = 2
        addChild(optionsButtonLabel)
    }
    var eff = "on"
    var snd = "on"
    func optionMenu(){
        playbutton.removeFromParent()
        optionsButton.removeFromParent()
        optionsButtonLabel.removeFromParent()
        gameNameLabel.text = "Options"
        
        musicLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")
        snd = StartScene.musics
        musicLabel.text = "Music : \(snd)"
        musicLabel.fontSize = 25.0
        musicLabel.position = CGPoint(x: frame.midX, y: frame.midY+120)
        musicLabel.zPosition = 2
        addChild(musicLabel)
        
        effectsLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")
        eff = StartScene.effects
        effectsLabel.text = "Effects : \(eff)"
        effectsLabel.fontSize = 25.0
        effectsLabel.position = CGPoint(x: frame.midX, y: frame.midY+70)
        effectsLabel.zPosition = 2
        addChild(effectsLabel)
        
        
        optionsButton = SKSpriteNode(imageNamed: ImageName.Button)
        optionsButton.position = CGPoint(x: frame.midX, y: frame.midY-120)
        optionsButton.zPosition = 1
        addChild(optionsButton)
        
        optionsButtonLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")
        optionsButtonLabel.text = "Save"
        optionsButtonLabel.fontSize = 40.0
        optionsButtonLabel.position = CGPoint(x: frame.midX, y: frame.midY-130)
        optionsButtonLabel.zPosition = 2
        addChild(optionsButtonLabel)
    }
    
    func checkMusic(){
        musicLabel.removeFromParent()
        
        musicLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")
        snd = StartScene.musics
        musicLabel.text = "Music : \(snd)"
        musicLabel.fontSize = 25.0
        musicLabel.position = CGPoint(x: frame.midX, y: frame.midY+120)
        musicLabel.zPosition = 2
        addChild(musicLabel)
    }
    
    func checkEffect(){
        effectsLabel.removeFromParent()
        
        effectsLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")
        eff = StartScene.effects
        effectsLabel.text = "Effects : \(eff)"
        effectsLabel.fontSize = 25.0
        effectsLabel.position = CGPoint(x: frame.midX, y: frame.midY+70)
        effectsLabel.zPosition = 2
        addChild(effectsLabel)
    }
}
