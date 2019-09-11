//
//  SmartAdMob.swift
//  SmartAdMob
//
//  Created by Alex Nagy on 28/05/2017.
//  Copyright © 2017 Rebeloper. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
import Firebase

enum SmartAdMobBannerPosition {
  case top
  case topWithStatusBar
  case bottom
}

enum SmartAdMobAdFrequency {
  case always
  case preset
}

// Is a reward based video ad being loaded.
var rewardBasedVideoAdRequestInProgress = false

let kAreSmartAdMobAdsRemoved = "kAreSmartAdMobAdsRemoved"
let kSkipFirstAd = "kSkipFirstAd"

final class SmartAdMob {
  
  let smartAdMobPortraitBannerView: GADBannerView = {
    let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    bannerView.adUnitID = adMobBannerAdUnitId
    return bannerView
  }()
  
  let smartAdMobLandscapeBannerView: GADBannerView = {
    let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerLandscape)
    bannerView.adUnitID = adMobBannerAdUnitId
    return bannerView
  }()
  
  fileprivate var smartAdMobInterstitial: GADInterstitial!
  fileprivate var smartAdMobRewardBasedVideo: GADRewardBasedVideoAd?
  
  fileprivate var smartAdMobInterstitialCount: Int = 1
  fileprivate var smartAdMobRewardBasedVideoCount: Int = 1
  
  fileprivate var smartAdMobBannerAnimationTimer = Timer()
  
  // Can't init is singleton
  private init() { }
  
  static let shared = SmartAdMob()
  
  public func launch(andSkipFirstAd shouldSkipFirstAd: Bool) {
    
    guard adMobApplicationId != "" else {
      print("[SmartAdMob] The 'adMobApplicationId' is not set up. Please, make sure it is set up in 'SmartAdMobConstants.swift'")
      return
    }
    
    if smartAdMobInterstitialFrequency > 0 && smartAdMobRewardBasedVideoFrequency > 0 {
      
      if shouldSkipFirstAd {
        smartAdMobInterstitialCount = 1
        smartAdMobRewardBasedVideoCount = 1
      } else {
        smartAdMobInterstitialCount = 0
        smartAdMobRewardBasedVideoCount = 0
      }
      
      // Use Firebase library to configure APIs
      FirebaseApp.configure()
      // Initialize Google Mobile Ads SDK
      GADMobileAds.configure(withApplicationID: adMobApplicationId)
      
      // fetching interstitial
      fetchInterstitialAd()
      
    } else {
      print("[SmartAdMob] Unable to launch SmartAdMob. Invalid 'ad frequency' found in SmartAdMobConstants.swift. Please use a value greater than or equal to 1.")
    }
    
  }
  
  // MARK: Banner
  
  public func showBannerAd(at position: SmartAdMobBannerPosition, on viewController: UIViewController, withPadding: CGFloat? = nil, animated: Bool? = nil) {
    if !areSmartAdMobAdsRemoved() {
      if UIDevice.current.orientation.isLandscape {
        showLandscapeBannerAd(at: position, padding: withPadding ?? 0, on: viewController, animated: animated)
      } else {
        showPortraitBannerAd(at: position, padding: withPadding ?? 0, on: viewController, animated: animated)
      }
    }
  }
  
  fileprivate func showLandscapeBannerAd(at position: SmartAdMobBannerPosition, padding: CGFloat, on viewController: UIViewController, animated: Bool? = nil) {
    
    guard adMobBannerAdUnitId != "" else {
      print("[SmartAdMob] The 'adMobBannerAdUnitId' is not set up. Please, make sure it is set up in 'SmartAdMobConstants.swift'")
      return
    }
    
    print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
    smartAdMobLandscapeBannerView.rootViewController = viewController
    let request = GADRequest()
    if adMobMyDeviceUUID == "" {
      request.testDevices = [ kGADSimulatorID ]
    } else {
      request.testDevices = [ kGADSimulatorID, adMobMyDeviceUUID ]
    }
    smartAdMobLandscapeBannerView.load(request)
    
    viewController.view.addSubview(smartAdMobLandscapeBannerView)
    
    switch position {
    case .top:
      smartAdMobLandscapeBannerView.anchor(top: viewController.view.topAnchor, left: viewController.view.leftAnchor, bottom: nil, right: viewController.view.rightAnchor, paddingTop: padding, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    case .topWithStatusBar:
      smartAdMobLandscapeBannerView.anchor(top: viewController.view.topAnchor, left: viewController.view.leftAnchor, bottom: nil, right: viewController.view.rightAnchor, paddingTop: padding + 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    case .bottom:
      smartAdMobLandscapeBannerView.anchor(top: nil, left: viewController.view.leftAnchor, bottom: viewController.view.bottomAnchor, right: viewController.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: padding, paddingRight: 0, width: 0, height: 0)
    }
    
    if animated ?? false {
      if smartAdMobBannerAnimationDelay > 0 {
        smartAdMobBannerAnimationTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(smartAdMobBannerAnimationDelay), repeats: true, block: { (timer) in
          self.smartAdMobPortraitBannerView.shake(count: 6, for: 0.5, withTranslation: 5.0)
        })
      } else {
        print("[SmartAdMob] Invalid 'smartAdMobBannerAnimationDelay' found in SmartAdMobConstants.swift. Please use a value greater than or equal to 1.")
      }
      
    }
    
  }
  
  fileprivate func showPortraitBannerAd(at position: SmartAdMobBannerPosition, padding: CGFloat, on viewController: UIViewController, animated: Bool? = nil) {
    
    guard adMobBannerAdUnitId != "" else {
      print("[SmartAdMob] The 'adMobBannerAdUnitId' is not set up. Please, make sure it is set up in 'SmartAdMobConstants.swift'")
      return
    }
    
    print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
    smartAdMobPortraitBannerView.rootViewController = viewController
    let request = GADRequest()
    if adMobMyDeviceUUID == "" {
      request.testDevices = [ kGADSimulatorID ]
    } else {
      request.testDevices = [ kGADSimulatorID, adMobMyDeviceUUID ]
    }
    smartAdMobPortraitBannerView.load(request)
    
    viewController.view.addSubview(smartAdMobPortraitBannerView)
    switch position {
    case .top:
      smartAdMobPortraitBannerView.anchor(top: viewController.view.topAnchor, left: viewController.view.leftAnchor, bottom: nil, right: viewController.view.rightAnchor, paddingTop: padding, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    case .topWithStatusBar:
      smartAdMobPortraitBannerView.anchor(top: viewController.view.topAnchor, left: viewController.view.leftAnchor, bottom: nil, right: viewController.view.rightAnchor, paddingTop: padding + 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    case .bottom:
      smartAdMobPortraitBannerView.anchor(top: nil, left: viewController.view.leftAnchor, bottom: viewController.view.bottomAnchor, right: viewController.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: padding, paddingRight: 0, width: 0, height: 0)
    }
    
    if animated ?? false {
      
      if smartAdMobBannerAnimationDelay > 0 {
        smartAdMobBannerAnimationTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(smartAdMobBannerAnimationDelay), repeats: true, block: { (timer) in
          self.smartAdMobPortraitBannerView.shake(count: 6, for: 0.5, withTranslation: 5.0)
        })
      } else {
        print("[SmartAdMob] Invalid 'smartAdMobBannerAnimationDelay' found in SmartAdMobConstants.swift. Please use a value greater than or equal to 1.")
      }
      
    }
    
  }
  
  // MARK: Interstitial
  
  fileprivate func fetchInterstitialAd() {
    
    guard adMobInterstitialAdUnitId != "" else {
      print("[SmartAdMob] The 'adMobInterstitialAdUnitId' is not set up. Please, make sure it is set up in 'SmartAdMobConstants.swift'")
      return
    }
    
    smartAdMobInterstitial = GADInterstitial(adUnitID: adMobInterstitialAdUnitId)
    let request = GADRequest()
    // Request test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made.
    if adMobMyDeviceUUID == "" {
      request.testDevices = [ kGADSimulatorID ]
    } else {
      request.testDevices = [ kGADSimulatorID, adMobMyDeviceUUID ]
    }
    smartAdMobInterstitial.load(request)
  }
  
  func showInterstitialAd(on viewController: UIViewController, withFrequency: SmartAdMobAdFrequency) {
    
    if smartAdMobInterstitialFrequency > 0 {
      switch withFrequency {
      case .always:
        presentInterstitial(on: viewController)
      case .preset:
        if !areSmartAdMobAdsRemoved() {
          if smartAdMobInterstitialCount % smartAdMobInterstitialFrequency == 0 {
            presentInterstitial(on: viewController)
          } else {
            print("[SmartAdMob] Not showing an interstitial ad at this time because ad frequency is set to: \(smartAdMobInterstitialFrequency) and ads count is: \(smartAdMobInterstitialCount)")
          }
          
          smartAdMobInterstitialCount += 1
        } else {
          print("[SmartAdMob] Not showing an interstitial ad because ads are removed by the user.")
        }
      }
    } else {
      print("[SmartAdMob] Invalid 'smartAdMobInterstitialFrequency' found in SmartAdMobConstants.swift. Please use a value greater than or equal to 1.")
    }
    
  }
  
  fileprivate func presentInterstitial(on viewController: UIViewController) {
    if smartAdMobInterstitial.isReady {
      smartAdMobInterstitial.present(fromRootViewController: viewController)
    } else {
      print("[SmartAdMob] Interstitial ad wasn't ready")
    }
    fetchInterstitialAd()
  }
  
  // MARK: Reward Based Video Ad
  
  func fetchRewardBasedVideoAd(on viewController: UIViewController) {
    
    guard adMobRewardBasedVideoAdUnitId != "" else {
      print("[SmartAdMob] The 'adMobRewardBasedVideoAdUnitId' is not set up. Please, make sure it is set up in 'SmartAdMobConstants.swift'")
      return
    }
    
    if !areSmartAdMobAdsRemoved() {
      smartAdMobRewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
      smartAdMobRewardBasedVideo?.delegate = viewController as? GADRewardBasedVideoAdDelegate
      if !rewardBasedVideoAdRequestInProgress && smartAdMobRewardBasedVideo?.isReady == false {
        smartAdMobRewardBasedVideo?.load(GADRequest(),
                                         withAdUnitID: adMobRewardBasedVideoAdUnitId)
        rewardBasedVideoAdRequestInProgress = true
      }
    }
  }
  
  func showRewardBasedVideoAd(on viewController: UIViewController, withFrequency: SmartAdMobAdFrequency) {
    
    if smartAdMobRewardBasedVideoFrequency > 0 {
      switch withFrequency {
      case .always:
        presentRewardBasedVideoAd(on: viewController)
      case .preset:
        if !areSmartAdMobAdsRemoved() {
          if smartAdMobRewardBasedVideoCount % smartAdMobRewardBasedVideoFrequency == 0 {
            presentRewardBasedVideoAd(on: viewController)
          } else {
            print("[SmartAdMob] Not showing a reward based video ad at this time because ad frequency is set to: \(smartAdMobRewardBasedVideoFrequency) and ads count is: \(smartAdMobRewardBasedVideoCount)")
          }
          
          smartAdMobRewardBasedVideoCount += 1
        } else {
          print("[SmartAdMob] Not showing a reward based video ad because ads are removed by the user.")
        }
      }
    } else {
      print("[SmartAdMob] Invalid 'smartAdMobRewardBasedVideoFrequency' found in SmartAdMobConstants.swift. Please use a value greater than or equal to 1.")
    }
    
  }
  
  fileprivate func presentRewardBasedVideoAd(on viewController: UIViewController) {
    if smartAdMobRewardBasedVideo?.isReady == true {
      smartAdMobRewardBasedVideo?.present(fromRootViewController: viewController)
    } else {
      print("[SmartAdMob] Reward Based Video Ad wasn't ready")
    }
    fetchRewardBasedVideoAd(on: viewController)
  }
  
  // MARK: Remove Ads
  
  public func removeSmartAdMobAds() {
    UserDefaults.standard.set(true, forKey: kAreSmartAdMobAdsRemoved)
    UserDefaults.standard.synchronize()
    hideSmartAdMobBanner()
  }
  
  public func areSmartAdMobAdsRemoved() -> Bool {
    return UserDefaults.standard.bool(forKey: kAreSmartAdMobAdsRemoved)
  }
  
  fileprivate func hideSmartAdMobBanner() {
    smartAdMobPortraitBannerView.alpha = 0.0
    smartAdMobLandscapeBannerView.alpha = 0.0
  }
  
}

// MARK: Extensions

extension UIView {
  
  func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
    
    translatesAutoresizingMaskIntoConstraints = false
    
    if let top = top {
      self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
    }
    
    if let left = left {
      self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
    }
    
    if let bottom = bottom {
      bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
    }
    
    if let right = right {
      rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
    }
    
    if width != 0 {
      widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    if height != 0 {
      heightAnchor.constraint(equalToConstant: height).isActive = true
    }
  }
  
}

extension UIView {
  
  func shake(count : Float? = nil,for duration : TimeInterval? = nil,withTranslation translation : Float? = nil) {
    let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.y")
    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    
    animation.repeatCount = count ?? 2
    animation.duration = (duration ?? 0.5)/TimeInterval(animation.repeatCount)
    animation.autoreverses = true
    animation.byValue = translation ?? -5
    layer.add(animation, forKey: "shake")
  }
}

