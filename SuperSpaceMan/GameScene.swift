import SpriteKit

class GameScene: SKScene {
    
    var backgroundNode : SKSpriteNode?
    var playerNode : SKSpriteNode?

    required init?(coder aDecoder: NSCoder) {
    
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
    
        super.init(size: size)
    
        println("Size : \(size)")
        backgroundColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    
        // adding the background
        backgroundNode = SKSpriteNode(imageNamed: "Background")
        backgroundNode!.size.width = self.frame.size.width
        backgroundNode!.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundNode!.position = CGPoint(x: size.width / 2.0, y: 0.0)
        addChild(backgroundNode!)
        
        // add the player
        playerNode = SKSpriteNode(imageNamed: "Player")
        playerNode!.position = CGPoint(x: size.width / 2.0, y: 80.0)
        addChild(playerNode!)
        
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
}
