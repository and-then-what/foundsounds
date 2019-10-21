//
//  AudioPlayer.swift
//  foundsounds
//
//  Created by a7m on 5/23/19.
//  Copyright © 2019 BigBinary. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import MediaPlayer
import Cache

struct Track {
	let title: String
	let urlString: String

	var url: URL {
		return URL(string: urlString)!
	}
}

class Playlist: NSObject {
	private var currentTrackIndex = -1
	private var tracks = [Track]()

	init(tracks: [Track]) {
		self.tracks = tracks
	}

	func nextTrack() -> Track {
		if (currentTrackIndex == tracks.count - 1) {
			currentTrackIndex = 0
		} else {
			currentTrackIndex += 1
		}
		
		return tracks[currentTrackIndex]
	}

	func previousTrack() -> Track {
		if (currentTrackIndex == 0) {
			currentTrackIndex = tracks.count - 1
		} else {
			currentTrackIndex -= 1
		}

		return tracks[currentTrackIndex]
	}

	func currentTrack() -> Track {
		return tracks[currentTrackIndex]
	}
}

protocol AudioPlayerDelegate: NSObject {
	func didFinishPlaying(track: Track)
	func didChangeStatus(to status: AVPlayer.TimeControlStatus)
}

class AudioPlayer: NSObject {
	private var audioPlayer = AVPlayer(playerItem: nil)
	private var item: CachingPlayerItem?
	private var currentTrack: Track?

	lazy var storage: Cache.Storage? = {
		return try? Cache.Storage(
			diskConfig: DiskConfig(name: "DiskCache"),
			memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10),
			transformer: TransformerFactory.forData()
		)
	}()

	weak var delegate: AudioPlayerDelegate?

	override init() {
		super.init()

		NotificationCenter.default.addObserver(self,
																					 selector: #selector(didFinishPlaying),
																					 name: .AVPlayerItemDidPlayToEndTime,
																					 object: nil)
	}

	@objc private func didFinishPlaying() {
		guard let track = currentTrack else { return }

		delegate?.didFinishPlaying(track: track)
	}

	func load(track: Track) {
		currentTrack = track

		storage?.async.entry(forKey: track.url.absoluteString, completion: { result in
			switch result {
			case .error:
				self.item = CachingPlayerItem(url: track.url)
			case .value(let entry):
				self.item = CachingPlayerItem(data: entry.object, mimeType: "audio/mpeg", fileExtension: "mp3")
			}
			self.item?.delegate = self

			DispatchQueue.main.async {
				self.audioPlayer = AVPlayer(playerItem: self.item)
				self.audioPlayer.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
				self.audioPlayer.play()
			}
		})
	}

	func play() {
		audioPlayer.play()
	}

	func pause() {
		audioPlayer.pause()
	}

	func playPause() {
		switch audioPlayer.timeControlStatus {
		case .playing, .waitingToPlayAtSpecifiedRate:
			audioPlayer.pause()
		case .paused:
			audioPlayer.play()
		@unknown default:
			return
		}
	}

	func replay() {
		guard let item = item else { return }

		item.seek(to: CMTime(seconds: 0, preferredTimescale: 100)) { [unowned self] success in
			self.play()
		}
	}

	var currentProgress: Double? {
		guard let item = item else { return nil }
		return item.currentTime().seconds / item.duration.seconds * 100
	}

	func seek(to progress: Double) {
		guard let item = item else { return }

		let seconds = item.duration.seconds * progress / 100
		let time = CMTime(seconds: seconds, preferredTimescale: 100)

		item.seek(to: time) { success in
			
		}
	}
	
	func nowPlayingInfo(nowPlayingInfoCenter: MPNowPlayingInfoCenter) -> [String: Any] {
		var nowPlayingInfo = [String: Any]()

		guard let track = currentTrack, let item = item else { return nowPlayingInfo }

		nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
		nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "found sounds"
		nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = item.duration.seconds
		nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = item.currentTime().seconds

		return nowPlayingInfo
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if object as! AVPlayer === audioPlayer {
			if keyPath == "timeControlStatus" {
				delegate?.didChangeStatus(to: audioPlayer.timeControlStatus)
				print(audioPlayer.timeControlStatus.rawValue)
			}
		}
	}
}

extension AudioPlayer: CachingPlayerItemDelegate {
	func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
		guard let storage = storage, let track = currentTrack else { return }

		storage.async.setObject(data, forKey: track.url.absoluteString, completion: { _ in })
	}
}
