//
//  PlaybackControlView.swift
//  foundsounds
//
//  Created by a7m on 6/3/19.
//  Copyright © 2019 BigBinary. All rights reserved.
//

import UIKit
import AVFoundation

protocol PlaybackControlViewDelegate: NSObject {
	func didTapPlay()
	func didTapPause()
}

class PlaybackControlView: UIView {
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var pauseButton: UIButton!

	var status: AVPlayer.TimeControlStatus = .paused {
		didSet {
			switch status {
			case .playing, .waitingToPlayAtSpecifiedRate:
				UIView.animate(withDuration: 0.2) {
					self.playButton.alpha = 0
					self.pauseButton.alpha = 1
				}
			case .paused:
				UIView.animate(withDuration: 0.2) {
					self.playButton.alpha = 1
					self.pauseButton.alpha = 0
				}
			default:
				return
			}
		}
	}

	weak var delegate: PlaybackControlViewDelegate?

	override func awakeFromNib() {
		playButton.imageView?.contentMode = .scaleAspectFit
		playButton.contentHorizontalAlignment = .fill
		playButton.contentVerticalAlignment = .fill

		pauseButton.imageView?.contentMode = .scaleAspectFit
		pauseButton.contentHorizontalAlignment = .fill
		pauseButton.contentVerticalAlignment = .fill
	}

	@IBAction func play(_ sender: Any) {
		delegate?.didTapPlay()
	}

	@IBAction func pause(_ sender: Any) {
		delegate?.didTapPause()
	}
}
