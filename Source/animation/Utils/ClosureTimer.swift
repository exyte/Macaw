//
//  ClosureTimer.swift
//  Pods
//
//  Created by Victor Sukochev on 08/08/16.
//
//

import Foundation

class ClosureTimer {

	private let closure: (() -> ())
	private let timeInterval: NSTimeInterval
	private var timer: NSTimer?

	required init(time: NSTimeInterval, closure: () -> ()) {
		self.closure = closure
		self.timeInterval = time
	}

	func start() {
		let currentTimer = NSTimer(fireDate: NSDate().dateByAddingTimeInterval(timeInterval), interval: 0.0, target: self, selector: #selector(launchClosure), userInfo: .None, repeats: false)
		timer = currentTimer
		NSRunLoop.currentRunLoop().addTimer(currentTimer, forMode: NSDefaultRunLoopMode)
	}

	func cancel() {
		timer?.invalidate()
	}

	@objc func launchClosure() {
		closure()
	}
}
