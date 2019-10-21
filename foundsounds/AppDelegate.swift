//
//  AppDelegate.swift
//  foundsounds
//
//  Created by a7m on 5/23/19.
//  Copyright © 2019 BigBinary. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		do {
			try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
			try AVAudioSession.sharedInstance().setActive(true)
		}	catch {
			// todo: handle errors maybe?
		}

		application.beginReceivingRemoteControlEvents()
		return true
	}
}

