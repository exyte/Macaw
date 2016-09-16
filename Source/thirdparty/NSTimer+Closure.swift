
import Foundation

extension NSTimer {
	/**
	 Creates and schedules a one-time `NSTimer` instance.

	 - Parameters:
	 - delay: The delay before execution.
	 - handler: A closure to execute after `delay`.

	 - Returns: The newly-created `NSTimer` instance.
	 */
	class func schedule(delay delay: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
		let fireDate = delay + CFAbsoluteTimeGetCurrent()
		let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, handler)
		CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
		return timer
	}

	/**
	 Creates and schedules a repeating `NSTimer` instance.

	 - Parameters:
	 - repeatInterval: The interval (in seconds) between each execution of
	 `handler`. Note that individual calls may be delayed; subsequent calls
	 to `handler` will be based on the time the timer was created.
	 - handler: A closure to execute at each `repeatInterval`.

	 - Returns: The newly-created `NSTimer` instance.
	 */
	class func schedule(repeatInterval interval: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
		let fireDate = interval + CFAbsoluteTimeGetCurrent()
		let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, handler)
		CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
		return timer
	}
}
