//
//  GameScene.swift
//  VuelingGame


import SpriteKit

enum GameState {
	case showingLogo
	case playing
	case dead
}

class GameScene: SKScene, SKPhysicsContactDelegate {
	var player: SKSpriteNode!
    var loseRingCollision: SKSpriteNode!
	var backgroundMusic: SKAudioNode!

	var logo: SKSpriteNode!
	var gameOver: SKSpriteNode!
	var gameState = GameState.showingLogo

	var scoreLabel: SKLabelNode!

	var score = 0 {
		didSet {
			scoreLabel.text = "SCORE: \(score)"
		}
	}

    override func didMove(to view: SKView) {
		createPlayer()
		createSky()
		createBackground()
		createGround()
		createScore()
		createLogos()

        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
		physicsWorld.contactDelegate = self

		if let musicURL = Bundle.main.url(forResource: "music", withExtension: "m4a") {
			backgroundMusic = SKAudioNode(url: musicURL)
			addChild(backgroundMusic)
		}
    }

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		switch gameState {
		case .showingLogo:
			gameState = .playing

			let fadeOut = SKAction.fadeOut(withDuration: 0.5)
			let remove = SKAction.removeFromParent()
			let wait = SKAction.wait(forDuration: 0.5)
			let activatePlayer = SKAction.run { [unowned self] in
				self.player.physicsBody?.isDynamic = true
				self.startRocks()
			}

			let sequence = SKAction.sequence([fadeOut, wait, activatePlayer, remove])
			logo.run(sequence)

		case .playing:
			player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
			player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            
            // Apply boost animation
            let playerTexture = SKTexture(imageNamed: "player-1")
            let frame2 = SKTexture(imageNamed: "player-2")
            let frame3 = SKTexture(imageNamed: "player-3")
            let animation = SKAction.animate(with: [playerTexture, frame2, frame3, playerTexture], timePerFrame: 0.08)
            let runBoost = SKAction.repeat(animation, count: 1)

            player.run(runBoost)

		case .dead:
			let scene = GameScene(fileNamed: "GameScene")!
			let transition = SKTransition.moveIn(with: SKTransitionDirection.right, duration: 1)
			self.view?.presentScene(scene, transition: transition)
		}
	}

	func createPlayer() {
		let playerTexture = SKTexture(imageNamed: "player-1")
        
		player = SKSpriteNode(texture: playerTexture)
		player.zPosition = 10
		player.position = CGPoint(x: frame.width / 6, y: frame.height * 0.75)

		addChild(player)

		player.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "planePhys"), size: playerTexture.size())
        player.physicsBody!.contactTestBitMask = 0x00001111
		player.physicsBody?.isDynamic = false
        
        player.physicsBody!.collisionBitMask = 0
        
        
        loseRingCollision = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 32, height: frame.height - 200))
        loseRingCollision.zPosition = 10
        loseRingCollision.position = CGPoint(x: 200, y: loseRingCollision.size.height / 2 + 150)
        
        addChild(loseRingCollision)
        
        loseRingCollision.physicsBody = SKPhysicsBody(rectangleOf: loseRingCollision.size)
       
        loseRingCollision.physicsBody?.isDynamic = false
        loseRingCollision.name = "loseGame"
        	}

	func createSky() {
		let topSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.97, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.67))
		topSky.anchorPoint = CGPoint(x: 0.5, y: 1)

		let bottomSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.16, brightness: 0.96, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.33))
		bottomSky.anchorPoint = CGPoint(x: 0.5, y: 1)

		topSky.position = CGPoint(x: frame.midX, y: frame.height)
		bottomSky.position = CGPoint(x: frame.midX, y: bottomSky.frame.height)

		addChild(topSky)
		addChild(bottomSky)

		bottomSky.zPosition = -40
		topSky.zPosition = -40
	}

	func createBackground() {
		let image = UIImage(named: "background")
        let scale = image!.size.height / self.view!.frame.height + 1
        let scaledImage = resizeImage(image: image!, targetSize: CGSize(width: image!.size.width / scale, height: image!.size.height / scale))
        
        let backgroundTexture = SKTexture(image: scaledImage)

		for i in 0 ... 1 {
			let background = SKSpriteNode(texture: backgroundTexture)
			background.zPosition = -30
			background.anchorPoint = CGPoint.zero
			background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat(1 * i), y: 100)
			addChild(background)

			let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 20)
			let moveReset = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
			let moveLoop = SKAction.sequence([moveLeft, moveReset])
			let moveForever = SKAction.repeatForever(moveLoop)

			background.run(moveForever)
		}
	}

	func createGround() {
		let groundTexture = SKTexture(imageNamed: "ground")

		for i in 0 ... 1 {
			let ground = SKSpriteNode(texture: groundTexture)
			ground.zPosition = -1
			ground.position = CGPoint(x: (groundTexture.size().width / 2.0 + (groundTexture.size().width * CGFloat(i))), y: groundTexture.size().height / 2)

			ground.physicsBody = SKPhysicsBody(texture: ground.texture!, size: CGSize(width: 1305, height: 10))
			ground.physicsBody?.isDynamic = false

			addChild(ground)

			let moveLeft = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 8)
			let moveReset = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
			let moveLoop = SKAction.sequence([moveLeft, moveReset])
			let moveForever = SKAction.repeatForever(moveLoop)

			ground.run(moveForever)
		}
	}

	func createScore() {
		scoreLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
		scoreLabel.fontSize = 24

		scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 60)
		scoreLabel.text = "SCORE: 0"
		scoreLabel.fontColor = UIColor.black

		addChild(scoreLabel)
	}

	func createLogos() {
		logo = SKSpriteNode(imageNamed: "logo")
		logo.position = CGPoint(x: frame.midX, y: frame.midY)
		addChild(logo)

		gameOver = SKSpriteNode(imageNamed: "gameover")
		gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
		gameOver.alpha = 0
		addChild(gameOver)
	}

	func createRocks() {
		// 2
        let ringTexture = SKTexture(imageNamed: "ring1")
		let ringCollision = SKSpriteNode(texture: ringTexture)
		ringCollision.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 24, height: 64))
        ringCollision.physicsBody!.contactTestBitMask = 4294967295
        ringCollision.physicsBody!.collisionBitMask = 0
        
        loseRingCollision.physicsBody!.contactTestBitMask = 0x00001111
        
        
		ringCollision.physicsBody?.isDynamic = false
		ringCollision.name = "scoreDetect"
                
        let ringFrame2 = SKTexture(imageNamed: "ring2")
        let ringFrame3 = SKTexture(imageNamed: "ring3")
        let ringFrame4 = SKTexture(imageNamed: "ring4")
        let ringFrame5 = SKTexture(imageNamed: "ring5")
        let ringFrame6 = SKTexture(imageNamed: "ring6")
        let ringFrame7 = SKTexture(imageNamed: "ring7")
        let ringFrame8 = SKTexture(imageNamed: "ring8")
        let ringFrame9 = SKTexture(imageNamed: "ring9")
        let ringFrame10 = SKTexture(imageNamed: "ring10")
        let ringFrame11 = SKTexture(imageNamed: "ring11")
        let ringFrame12 = SKTexture(imageNamed: "ring12")
        let ringFrame13 = SKTexture(imageNamed: "ring13")
        let ringFrame14 = SKTexture(imageNamed: "ring14")
        let ringFrame15 = SKTexture(imageNamed: "ring15")
        let ringFrame16 = SKTexture(imageNamed: "ring16")
        
        let animation = SKAction.animate(with: [ringTexture, ringFrame2, ringFrame3, ringFrame4, ringFrame5, ringFrame6, ringFrame7, ringFrame8, ringFrame9, ringFrame10, ringFrame11, ringFrame12, ringFrame13, ringFrame14, ringFrame15, ringFrame16, ringTexture], timePerFrame: 0.03)
        let runBoost = SKAction.repeatForever(animation)

        ringCollision.run(runBoost)

		addChild(ringCollision)

		// 3
		let xPosition = frame.width + ringCollision.frame.width
        let yPosition: CGFloat = CGFloat.random(in: 125...self.view!.frame.height - 250)

		// 4
		ringCollision.position = CGPoint(x: xPosition + (ringCollision.size.width / 4), y: yPosition)

		let endPosition = frame.width + (ringCollision.frame.width * 2)

		let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 6.2)
		let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])

		ringCollision.run(moveSequence)
	}

	func startRocks() {
		let create = SKAction.run { [unowned self] in
			self.createRocks()
		}

		let wait = SKAction.wait(forDuration: 3)
		let sequence = SKAction.sequence([create, wait])
		let repeatForever = SKAction.repeatForever(sequence)

		run(repeatForever)
	}

	override func update(_ currentTime: TimeInterval) {
		guard player != nil else { return }

		let value = player.physicsBody!.velocity.dy * 0.001
		let rotate = SKAction.rotate(toAngle: value, duration: 0.1)

		player.run(rotate)
	}

    
	func didBegin(_ contact: SKPhysicsContact) {
		if contact.bodyA.node?.name == "scoreDetect" || contact.bodyB.node?.name == "scoreDetect" {
			if contact.bodyA.node == player {
				contact.bodyB.node?.removeFromParent()
			} else {
				contact.bodyA.node?.removeFromParent()
			}

			let sound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
			run(sound)

			score += 1

			return
		}
        
        if contact.bodyA.node == loseRingCollision && contact.bodyB.node?.name == "scoreDetect" ||
            contact.bodyB.node == loseRingCollision && contact.bodyA.node?.name == "scoreDetect" {
            endGame()
        }

        if contact.bodyA.node == player && contact.bodyB.node?.name != "loseGame" || contact.bodyB.node == player && contact.bodyA.node?.name != "loseGame" {
			endGame()
		}
	}
    
    func endGame() {
        if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") {
                        explosion.position = player.position
                        addChild(explosion)
                    }

                    let sound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
                    run(sound)

                    gameOver.alpha = 1
                    gameState = .dead
                    backgroundMusic.run(SKAction.stop())

                    player.removeFromParent()
                    speed = 0
    }
}

extension GameScene {
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
