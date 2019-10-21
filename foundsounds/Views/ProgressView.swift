//
//  ProgressView.swift
//  foundsounds
//
//  Created by a7m on 5/23/19.
//  Copyright © 2019 BigBinary. All rights reserved.
//

import UIKit

protocol ProgressViewDelegate: NSObject {
	func didChangeProgress(progress: Double)
}

@IBDesignable
class ProgressView: UIControl {
	private var progressArcLayer = CAShapeLayer()
	private var progressCircleLayer = CAShapeLayer()

	weak var delegate: ProgressViewDelegate?
	
	@IBInspectable
	var progress: Double = 0.01 {
		didSet {
			if (progress < 0 || progress > 100)	{
				progress = 0.01
			}

			progressArcLayer.strokeEnd = CGFloat(progress / 100)
		}
	}

	@IBInspectable
	var progressWidth: CGFloat = 5.0 {
		didSet {
			progressArcLayer.lineWidth = progressWidth
			progressCircleLayer.lineWidth = progressWidth
		}
	}

	@IBInspectable var circleColor: UIColor? {
		didSet {
			progressCircleLayer.strokeColor = circleColor?.cgColor
		}
	}

	@IBInspectable var arcColor: UIColor? {
		didSet {
			progressArcLayer.strokeColor = arcColor?.cgColor
		}
	}

	override func awakeFromNib() {
		prepareLayers()
	}

	private func prepareLayers() {
		layer.addSublayer(progressCircleLayer)
		layer.addSublayer(progressArcLayer)
		progressArcLayer.setAffineTransform(CGAffineTransform(rotationAngle: -.pi / 2.0))
	}

	private func layoutArc() {
		progressArcLayer.frame = bounds
		progressCircleLayer.frame = progressArcLayer.frame

		progressArcLayer.lineWidth = progressWidth
		progressCircleLayer.lineWidth = progressWidth

		progressArcLayer.fillColor = nil
		progressCircleLayer.fillColor = nil

		let arcCenter = progressArcLayer.position
		let radius = bounds.height / 2
		let startAngle = CGFloat(0.0)
		let endAngle = CGFloat(2.0 * .pi)

		let progressArcPath = UIBezierPath(arcCenter: arcCenter,
																			 radius: radius,
																			 startAngle: startAngle,
																			 endAngle: endAngle,
																			 clockwise: true)

		progressArcLayer.path = progressArcPath.cgPath

		let progressCirclePath = UIBezierPath(arcCenter: arcCenter,
																					radius: radius,
																					startAngle: startAngle,
																					endAngle: endAngle,
																					clockwise: true)

		progressCircleLayer.path = progressCirclePath.cgPath

		progressArcLayer.strokeStart = 0.0
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		layoutArc()
	}

	override func prepareForInterfaceBuilder() {
		prepareLayers()
	}

	override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		super.beginTracking(touch, with: event)
		calculateProgressAndNotify(touch: touch)
		return true
	}

	override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		super.continueTracking(touch, with: event)
		calculateProgressAndNotify(touch: touch)
		return true
	}

	private func calculateProgressAndNotify(touch: UITouch) {
		let angle = angleFromNorth(center: CGPoint(x: bounds.midX, y: bounds.midY), point: touch.location(in: self))
		delegate?.didChangeProgress(progress: Double(angle / 360) * 100)
	}

	// some trigonometry magic
	private func angleFromNorth(center: CGPoint, point: CGPoint) -> CGFloat {
		var v = CGPoint(x: point.x - center.x, y: point.y - center.y)
		let vmag = sqrt(v.x * v.x + v.y * v.y)
		var result = CGFloat(0)
		v.x /= vmag
		v.y /= vmag
		let radians = atan2(v.y, v.x) + .pi / 2
		result = (180.0 * radians) / .pi
		return (result >= 0 ? result : result + 360.0);
	}
}
