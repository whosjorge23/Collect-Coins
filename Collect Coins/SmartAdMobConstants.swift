//
//  SmartAdMobConstants.swift
//  SmartAdMob
//
//  Created by Alex Nagy on 31/05/2017.
//  Copyright © 2017 Rebeloper. All rights reserved.
//

// SmartAdMobConstants

//----------------------------
// Device UUID
//----------------------------
let adMobMyDeviceUUID = "" // used only for testing; optional for release
//----------------------------

//----------------------------
// AdMob IDs
//----------------------------
// to get started go to: https://apps.admob.com/v2/home

// your application ID
let adMobApplicationId = "ca-app-pub-6509077530171354~2897067440" // required

// at least one AdUnitId is required
// leave as an empty string ("") if you do not want to use the ad type (and you did not set it up in the AdMob Dashboard)

let adMobBannerAdUnitId = ""
let adMobInterstitialAdUnitId = "ca-app-pub-6509077530171354/7729951095"
let adMobRewardBasedVideoAdUnitId = ""

//----------------------------
// Ad Frequencies
//----------------------------
// set the frequency of the 'interstitials' and 'reward based video ads'
// choose a number between 1 (hard value) and 10 (suggested value; could be more if you widh, but not advised)
// the smaller the number you choose the more often will the ads show
// set it to 1 if you want an ad to be shown on every occasion

let smartAdMobInterstitialFrequency = 3 // needs to be a number greater than or equal to 1 (do not set it to 0)
let smartAdMobRewardBasedVideoFrequency = 2 // needs to be a number greater than or equal to 1 (do not set it to 0)

// note: banner ads do not need a frequency as they are always on screen

//----------------------------
// Banner Ad Animation Delay
//----------------------------
// if you choose to animate (shake) the banner periodically than you can set the time (in seconds) between the animations
let smartAdMobBannerAnimationDelay = 30
