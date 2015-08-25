import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate  {
    
    //variables
    var foregroundNode : SKSpriteNode?
    var backgroundNode : SKSpriteNode?
    var backgroundStarsNode  : SKSpriteNode?
    var backgroundPlanetNode : SKSpriteNode?
    
    var playerNode : SKSpriteNode?
    var orbNode : SKSpriteNode?
    var impulseCount : Int32 = 4
    
    let coreMotionManager = CMMotionManager()
    var xAxisAcceleration : CGFloat = 0.0
    
    //constants
    let accelerometerUpdateInterval : NSTimeInterval = 0.1
    let gravityPower : CGFloat = -5.0
    let impulsePower : CGFloat = 60.0
    
    let CollisionCategoryPlayer     : UInt32 = 0x1 << 1
    let CollisionCategoryPowerUpOrbs : UInt32 = 0x1 << 2
    let CollisionCategoryBlackHoles: UInt32 = 0x1 << 3
    
    let orbName : String = "powerOrb"
    let BlackHoleName : String = "BLACK_HOLE"

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
    
        super.init(size: size)
        physicsWorld.contactDelegate = self //without this line, the handler will not be attached
    
        userInteractionEnabled = true //to allow user interaction with the game
        
        println("Default gravity dy: \(physicsWorld.gravity.dy)")
        physicsWorld.gravity = CGVectorMake(0.0, gravityPower) //change the gravity of the game scene
        
        println("Size : \(size)")
        backgroundColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    
        // adding the background
        backgroundNode = SKSpriteNode(imageNamed: "Background")
        backgroundNode!.size.width = self.frame.size.width
        backgroundNode!.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundNode!.position = CGPoint(x: size.width / 2.0, y: 0.0)
        addChild(backgroundNode!)
        
        //add star to the background
        backgroundStarsNode = SKSpriteNode(imageNamed: "Stars")
        backgroundStarsNode!.size.width = self.frame.size.width
        backgroundStarsNode!.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundStarsNode!.position = CGPoint(x: size.width / 2.0, y: 0.0)
        addChild(backgroundStarsNode!)
        
        //add planet to the background
        backgroundPlanetNode = SKSpriteNode(imageNamed: "PlanetStart")
        backgroundPlanetNode!.size.width = self.frame.size.width
        backgroundPlanetNode!.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundPlanetNode!.position = CGPoint(x: size.width / 2.0, y: 0.0)
        addChild(backgroundPlanetNode!)
        
        // *********************
        // adding foreground
        // *********************
        foregroundNode = SKSpriteNode()
        addChild(foregroundNode!)
        
        // *********************
        // add the player
        // *********************
        playerNode = SKSpriteNode(imageNamed: "Player")
        playerNode!.position = CGPoint(x: self.size.width / 2.0, y: 220.0)
        playerNode!.physicsBody = SKPhysicsBody(circleOfRadius: playerNode!.size.width / 2) //attach an SKPhysicsBody into the SKPriteNode
        playerNode!.physicsBody!.dynamic = false
        playerNode!.physicsBody!.allowsRotation = false //stop the node from spinning upon collision
        playerNode!.physicsBody!.linearDamping = 1.0 //dampen the velocity to simulate air friction
        
        //Listening to the collision events
        playerNode!.physicsBody!.categoryBitMask = CollisionCategoryPlayer
        playerNode!.physicsBody!.contactTestBitMask = CollisionCategoryPowerUpOrbs | CollisionCategoryBlackHoles
        playerNode!.physicsBody!.collisionBitMask = 0 //this line means that you are going to handle the collision yourself, i.e. remove the default behaviour

        foregroundNode!.addChild(playerNode!)
   
        // *********************
        // add the orb into the game
        // *********************
        //addOrbs(19, playerNode!.position.x, playerNode!.position.y + 50.0, 140.0)
        //addOrbs(19, positionX: playerNode!.position.x, initialPositionY: playerNode!.position.y + 200, yDistance: 140.0)
        
        addOrbs2()
        
        addBlackHolesToForeground()
       
//        orbNode = SKSpriteNode(imageNamed: "PowerUp")
//        orbNode!.name = orbName
//        orbNode!.position = CGPoint(x: 150.0, y: size.height - 25)
//        orbNode!.physicsBody = SKPhysicsBody(circleOfRadius: orbNode!.size.width / 2)
//        orbNode!.physicsBody!.dynamic = false
//        //addChild(orbNode!)
//        foregroundNode!.addChild(orbNode!)
        
        //addExtraPlayers()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

        //this is to activate the game and start playing
        if !playerNode!.physicsBody!.dynamic {
            
            playerNode!.physicsBody!.dynamic = true
            
            //listen to the accelerometer sensor events here
            self.coreMotionManager.accelerometerUpdateInterval = accelerometerUpdateInterval
            coreMotionManager.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: {
                (data: CMAccelerometerData!, error: NSError!) in
                
                if let constVar = error {
                    println("There was an error")
                }
                else {
                    self.xAxisAcceleration = CGFloat(data!.acceleration.x)
                }
                
            })
        }
        
        if (impulseCount > 0) {
            playerNode!.physicsBody!.applyImpulse(CGVectorMake(0.0, impulsePower))
            impulseCount--
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        //Because of the sequence in which the nodes where placed on the foreground,
        // nodeB is going to be the static one, e.g. orb or back hole
        var nodeB = contact.bodyB!.node!
            
        println("Contact happens, nodeB.name = \(nodeB.name)")

        //Collision handler
        if nodeB.name == orbName {
            nodeB.removeFromParent()
            impulseCount++
        }
        else if nodeB.name == BlackHoleName {
            playerNode!.physicsBody!.contactTestBitMask = 0
            impulseCount = 0
            
            //nodeB.removeFromParent()
            
            var colorizeAction = SKAction.colorizeWithColor(UIColor.redColor(),
            colorBlendFactor: 1.0, duration: 1)
            playerNode!.runAction(colorizeAction)
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        
        //scrolling effect
        if playerNode!.position.y >= 180.0 {
            
            self.backgroundNode!.position = CGPointMake(self.backgroundNode!.position.x, -((self.playerNode!.position.y - 180)/8))
        
            backgroundStarsNode!.position = CGPointMake(backgroundStarsNode!.position.x, -((playerNode!.position.y - 180.0)/6))
        
            backgroundPlanetNode!.position = CGPointMake(backgroundPlanetNode!.position.x, -((playerNode!.position.y - 180.0)/8));
            
            foregroundNode!.position = CGPointMake(foregroundNode!.position.x, -(playerNode!.position.y - 180))
        }
    }
    
    override func didSimulatePhysics() {
        
        //move the player left-right based on sensor movement
        playerNode!.physicsBody!.velocity = CGVectorMake(self.xAxisAcceleration * 380.0, playerNode!.physicsBody!.velocity.dy)
                
        if playerNode!.position.x < -(playerNode!.size.width / 2) {
            playerNode!.position = CGPointMake(size.width - playerNode!.size.width / 2, playerNode!.position.y);
        }
        else if self.playerNode!.position.x > self.size.width {
            playerNode!.position = CGPointMake(playerNode!.size.width / 2, playerNode!.position.y);
        }
    }
    
    deinit {
        self.coreMotionManager.stopAccelerometerUpdates()
    }
    
    func addExtraPlayers()
    {
        //extra players
        var extraPlayerName = "extraPlayer"
        var playerNode1 = SKSpriteNode(imageNamed: "Player")
        playerNode1.name = extraPlayerName
        playerNode1.anchorPoint = CGPoint(x: 0.0, y: 0.0) //change the anchorPoint of a SKPriteNode, ranging from (0.0, 0.0) to (1.0, 1.0)
        playerNode1.position = CGPoint(x: 0.0, y: 0.0)
        self.addChild(playerNode1)
        
        var playerNode2 = SKSpriteNode(imageNamed: "Player")
        playerNode2.name = extraPlayerName
        playerNode2.anchorPoint = CGPoint(x: 1.0, y: 1.0) //change the anchorPoint of a SKPriteNode
        playerNode2.position = CGPoint(x: size.width, y: size.height)
        self.addChild(playerNode2)
        
        //find a node within a scene
        var x = self.childNodeWithName(extraPlayerName)
        println("First extra player: \(x?.position)")
    }
    
   
    func addOrbs(orbCount:Int, positionX:CGFloat, initialPositionY:CGFloat, yDistance:CGFloat)
    {
        var orbNodePosition = CGPointMake(positionX, initialPositionY)
        
        for i in 0...orbCount {
            
            var orbNode = SKSpriteNode(imageNamed: "PowerUp")
            
            orbNode.position = orbNodePosition
            
            orbNode.physicsBody = SKPhysicsBody(circleOfRadius: orbNode.size.width / 2)
            orbNode.physicsBody!.dynamic = false
            
            orbNode.physicsBody!.categoryBitMask = CollisionCategoryPowerUpOrbs
            orbNode.physicsBody!.collisionBitMask = 0;
            orbNode.name = orbName
            
            foregroundNode!.addChild(orbNode)

            orbNodePosition.y += yDistance
        }
    }
    
    func addOrbs2()
    {
        var orbNodePosition = CGPoint(x: playerNode!.position.x, y: playerNode!.position.y + 100)
        var orbXShift : CGFloat = -1.0
        
        for _ in 1...50 {
            var orbNode = SKSpriteNode(imageNamed: "PowerUp")
            
            if orbNodePosition.x - (orbNode.size.width * 2) <= 0 {
                orbXShift = 1.0
            }
            
            if orbNodePosition.x + orbNode.size.width >= self.size.width {
                orbXShift = -1.0
            }
            
            orbNodePosition.x += 40.0 * orbXShift
            orbNodePosition.y += 120
            orbNode.position = orbNodePosition
            orbNode.physicsBody = SKPhysicsBody(circleOfRadius: orbNode.size.width / 2)
            orbNode.physicsBody!.dynamic = false
            orbNode.physicsBody!.categoryBitMask = CollisionCategoryPowerUpOrbs
            orbNode.physicsBody!.collisionBitMask = 0
            orbNode.name = orbName
            
            foregroundNode!.addChild(orbNode)
        }
    }
    
    func addBlackHolesToForeground() {
        let textureAtlas = SKTextureAtlas(named: "sprites.atlas")
        let frame0 = textureAtlas.textureNamed("BlackHole0")
        let frame1 = textureAtlas.textureNamed("BlackHole1")
        let frame2 = textureAtlas.textureNamed("BlackHole2")
        let frame3 = textureAtlas.textureNamed("BlackHole3")
        let frame4 = textureAtlas.textureNamed("BlackHole4")
        let blackHoleTextures = [frame0, frame1, frame2, frame3, frame4]
        let animateAction = SKAction.animateWithTextures(blackHoleTextures, timePerFrame: 0.2)
        let rotateAction = SKAction.repeatActionForever(animateAction)
        
        let moveLeftAction = SKAction.moveToX(0.0, duration: 2.0)
        let moveRightAction = SKAction.moveToX(size.width, duration: 2.0)
        let actionSequence = SKAction.sequence([moveLeftAction, moveRightAction])
        let moveAction = SKAction.repeatActionForever(actionSequence)
        
        for i in 1...10 {
                
            var blackHoleNode = SKSpriteNode(imageNamed: "BlackHole0")
            blackHoleNode.position = CGPointMake(self.size.width - 80.0, 600.0 * CGFloat(i))
            blackHoleNode.physicsBody = SKPhysicsBody(circleOfRadius: blackHoleNode.size.width / 2)
            blackHoleNode.physicsBody!.dynamic = false
            blackHoleNode.physicsBody!.categoryBitMask = CollisionCategoryBlackHoles
            blackHoleNode.physicsBody!.collisionBitMask = 0
            blackHoleNode.name = BlackHoleName
            
            blackHoleNode.runAction(moveAction)
            blackHoleNode.runAction(rotateAction)
                
            self.foregroundNode!.addChild(blackHoleNode)
        }
    }
}
