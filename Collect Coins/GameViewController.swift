//
//  GameViewController.swift
//  Collect Coins
//
//  Created by Jorge Giannotta on 26/08/2019.
//  Copyright © 2019 Westcostyle. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Firebase
import GoogleMobileAds

class GameViewController: UIViewController {

    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gameArray = ["GameScene", "GameScene2"]
        
        let gameRandom = gameArray[Int(arc4random_uniform(UInt32(gameArray.count)))]
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "\(gameRandom)") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-6509077530171354/7729951095")
        let request = GADRequest()
        interstitial.load(request)
        
        self.interstitial.present(fromRootViewController: self)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func showInterstitialAd() {
        //self.interstitial.present(fromRootViewController: self)
        SmartAdMob.shared.showInterstitialAd(on: self, withFrequency: .preset)
    }
}
