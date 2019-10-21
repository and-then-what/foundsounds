//
//  FSPushButton.swift
//  foundsounds
//
//  Created by a7m on 6/3/19.
//  Copyright © 2019 BigBinary. All rights reserved.
//

import UIKit

class FSPushButton: UIButton {
	private let animationDuration = 0.15

	override func awakeFromNib() {
		addTarget(self, action: #selector(scaleUp), for: .touchDown)
		addTarget(self, action: #selector(scaleDown), for: .touchUpInside)
		addTarget(self, action: #selector(scaleDown), for: .touchUpOutside)
		addTarget(self, action: #selector(scaleDown), for: .touchCancel)
	}

	@objc private func scaleUp() {
		UIView.animate(withDuration: animationDuration) {
			self.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
		}
	}

	@objc private func scaleDown() {
		UIView.animate(withDuration: animationDuration) {
			self.transform = .identity
		}
	}
}
