//
//  ViewController.swift
//  foundsounds
//
//  Created by a7m on 5/23/19.
//  Copyright © 2019 BigBinary. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Cache

class ViewController: UIViewController {
	@IBOutlet weak var progressView: ProgressView!
	@IBOutlet weak var trackTitleLabel: UILabel!
	@IBOutlet weak var controlView: PlaybackControlView!
	
	private let audioPlayer = AudioPlayer()
	private var playList: Playlist!
	private var displayLink: CADisplayLink!

	override func viewDidLoad() {
		super.viewDidLoad()

		setupDisplayLink()

		progressView.delegate = self
		audioPlayer.delegate = self
		controlView.delegate = self

		playList = Playlist(tracks: [
			Track(title: "wip track 1 very loooooong title", urlString: "https://d2g5vm0vzcews6.cloudfront.net/11.mp3"),
			Track(title: "demo track 2", urlString: "https://d2g5vm0vzcews6.cloudfront.net/11.mp3"),
			Track(title: "track 3", urlString: "https://d2g5vm0vzcews6.cloudfront.net/11.mp3")
		])

		playNextTrack()
	}

	private func setupDisplayLink() {
		displayLink = CADisplayLink(target: self, selector: #selector(onFrameAction))
		displayLink.preferredFramesPerSecond = 10
		displayLink.add(to: .main, forMode: .common)
	}

	@objc private func onFrameAction() {
		guard let progress = audioPlayer.currentProgress else { return }
		progressView.progress = progress
	}

	private func loadTrack(track: Track) {
		trackTitleLabel.text = track.title
		audioPlayer.load(track: track)
	}

	private func playNextTrack() {
		loadTrack(track: playList.nextTrack())
		audioPlayer.play()
	}

	private func playPreviousTrack() {
		loadTrack(track: playList.previousTrack())
		audioPlayer.play()
	}

	// MARK: actions
	@IBAction func logoTap(_ sender: Any) {
		guard let urlString = Bundle.main.object(forInfoDictionaryKey: "FS_HOME_URL") as? String, let url = URL(string: urlString) else { return }
		UIApplication.shared.open(url, options: [:])
	}

	@IBAction func fastForward(_ sender: Any) {
		playNextTrack()
	}

	@IBAction func replay(_ sender: Any) {
		audioPlayer.replay()
	}

	@IBAction func share(_ sender: Any) {
		guard let url = NSURL(string: "https://itunes.apple.com/us/app/myapp/idxxxxxxxx?ls=1&mt=8") else { return }

		let objectsToShare = [playList.currentTrack().title, " in foundsounds.app", url] as [Any]
		let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
		self.present(activityVC, animated: true)
	}

	@IBAction func invite(_ sender: Any) {
		guard let urlString = Bundle.main.object(forInfoDictionaryKey: "FS_INVITE_URL") as? String, let url = URL(string: urlString) else { return }
		UIApplication.shared.open(url, options: [:])
	}

	override func remoteControlReceived(with event: UIEvent?) {
		guard let event = event else { return }

		if (event.type == UIEvent.EventType.remoteControl) {
			switch (event.subtype) {
			case .remoteControlPlay:
				audioPlayer.play()
			case .remoteControlPause:
				audioPlayer.pause()
			case .remoteControlTogglePlayPause:
				audioPlayer.playPause()
			case .remoteControlNextTrack:
				playNextTrack()
			case .remoteControlPreviousTrack:
				playPreviousTrack()
			default:
				return
			}
		}
	}
}

extension ViewController: ProgressViewDelegate {
	func didChangeProgress(progress: Double) {
		audioPlayer.seek(to: progress)
	}
}

extension ViewController: AudioPlayerDelegate {
	func didFinishPlaying(track: Track) {
		playNextTrack()
	}

	func didChangeStatus(to status: AVPlayer.TimeControlStatus) {
		controlView.status = status

		let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
		nowPlayingInfoCenter.nowPlayingInfo = audioPlayer.nowPlayingInfo(nowPlayingInfoCenter: nowPlayingInfoCenter)
	}
}

extension ViewController: PlaybackControlViewDelegate {
	func didTapPlay() {
		audioPlayer.play()
	}

	func didTapPause() {
		audioPlayer.pause()
	}
}

