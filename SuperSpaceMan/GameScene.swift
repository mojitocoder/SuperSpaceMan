import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate  {
    
    //variables
    var foregroundNode : SKSpriteNode?
    var backgroundNode : SKSpriteNode?
    var playerNode : SKSpriteNode?
    var orbNode : SKSpriteNode?
    var impulseCount : Int32 = 4
    
    //constants
    let gravityPower : CGFloat = -5.0
    let impulsePower : CGFloat = 40.0
    let CollisionCategoryPlayer     : UInt32 = 0x1 << 1
    let CollisionCategoryPowerUpOrbs : UInt32 = 0x1 << 2
    let orbName : String = "powerOrb"

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
        
        // *********************
        // adding foreground
        // *********************
        foregroundNode = SKSpriteNode()
        addChild(foregroundNode!)
        
        // *********************
        // add the player
        // *********************
        playerNode = SKSpriteNode(imageNamed: "Player")
        playerNode!.position = CGPoint(x: self.size.width / 2.0, y: 180.0)
        playerNode!.physicsBody = SKPhysicsBody(circleOfRadius: playerNode!.size.width / 2) //attach an SKPhysicsBody into the SKPriteNode
        playerNode!.physicsBody!.dynamic = false
        playerNode!.physicsBody!.allowsRotation = false //stop the node from spinning upon collision
        playerNode!.physicsBody!.linearDamping = 1.0 //dampen the velocity to simulate air friction
        
        //Listening to the collision events
        playerNode!.physicsBody!.categoryBitMask = CollisionCategoryPlayer
        playerNode!.physicsBody!.contactTestBitMask = CollisionCategoryPowerUpOrbs
        playerNode!.physicsBody!.collisionBitMask = 0 //this line means that you are going to handle the collision yourself, i.e. remove the default behaviour

        foregroundNode!.addChild(playerNode!)
   
        // *********************
        // add the orb into the game
        // *********************
        //addOrbs(19, playerNode!.position.x, playerNode!.position.y + 50.0, 140.0)
        addOrbs(19, positionX: playerNode!.position.x, initialPositionY: playerNode!.position.y + 200, yDistance: 140.0)
        
//        orbNode = SKSpriteNode(imageNamed: "PowerUp")
//        orbNode!.name = orbName
//        orbNode!.position = CGPoint(x: 150.0, y: size.height - 25)
//        orbNode!.physicsBody = SKPhysicsBody(circleOfRadius: orbNode!.size.width / 2)
//        orbNode!.physicsBody!.dynamic = false
//        //addChild(orbNode!)
//        foregroundNode!.addChild(orbNode!)
        
        //extra players
        var extraPlayerName = "extraPlayer"
        var playerNode1 = SKSpriteNode(imageNamed: "Player")
        playerNode1.name = extraPlayerName
        playerNode1.anchorPoint = CGPoint(x: 0.0, y: 0.0) //change the anchorPoint of a SKPriteNode, ranging from (0.0, 0.0) to (1.0, 1.0)
        playerNode1.position = CGPoint(x: 0.0, y: 0.0)
        addChild(playerNode1)
        
        var playerNode2 = SKSpriteNode(imageNamed: "Player")
        playerNode2.name = extraPlayerName
        playerNode2.anchorPoint = CGPoint(x: 1.0, y: 1.0) //change the anchorPoint of a SKPriteNode
        playerNode2.position = CGPoint(x: size.width, y: size.height)
        addChild(playerNode2)
        
        //find a node within a scene
        var x = childNodeWithName(extraPlayerName)
        println("First extra player: \(x?.position)")
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

        //this is to activate the game and start playing
        if !playerNode!.physicsBody!.dynamic {
            playerNode!.physicsBody!.dynamic = true
        }
        
        if (impulseCount > 0) {
            playerNode!.physicsBody!.applyImpulse(CGVectorMake(0.0, impulsePower))
            impulseCount--
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var nodeB = contact.bodyB!.node!
            
        println("Contact happens, nodeB.name = \(nodeB.name)")

        if nodeB.name == orbName {
            nodeB.removeFromParent()
        }
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
}
