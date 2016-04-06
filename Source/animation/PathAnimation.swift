import Foundation

public struct AnimationPathFrame<T: Interpolable> {

	let value: T
	let position: Double
}

public func AnimationPathFrameMake<T>(value: T, position: Double) -> AnimationPathFrame<T> {
	return AnimationPathFrame(value: value, position: position)
}

public struct AnimationPathSegment<T: Interpolable> {
	let start: AnimationPathFrame<T>
	let end: AnimationPathFrame<T>

	func contains(position: Double) -> Bool {
		return position > start.position && position <= end.position
	}
}

public class PathAnimation<T: Interpolable>: Animatable {

	let value: ObservableValue<T>
	let pathSegments: [AnimationPathSegment<T>]
	let duration: Double

	var cachedSegment: AnimationPathSegment<T>?

	public required init(observableValue: ObservableValue<T>, path: [AnimationPathFrame<T>], animationDuration: Double) {
		value = observableValue
		duration = animationDuration

		var prevFrame: AnimationPathFrame<T>?
		var segments = [AnimationPathSegment<T>]()
		for frame in path {
			if let prevFrame = prevFrame {
				let segment = AnimationPathSegment(start: prevFrame, end: frame)
				segments.append(segment)
			}

			prevFrame = frame
		}

		pathSegments = segments
	}

	public convenience init(observableValue: ObservableValue<T>, function: (Double) -> T, animationDuration: Double) {

		var path = [AnimationPathFrame<T>]()
		// 60 fps
		let fps = 60.0
		let n = fps * animationDuration
		let dt = 1.0 / n
		for i in 0 ... Int(n) {
			let position = dt * Double(i)
			let value = function(position)
			path.append(AnimationPathFrame(value: value, position: position))
		}

		self.init(observableValue: observableValue, path: path, animationDuration: animationDuration)
	}

	public override func animate(progress: Double) {

		// Cache
		if let cachedSegment = cachedSegment {
			if cachedSegment.contains(progress) {
				value.set(iterpolate(cachedSegment, position: progress))
				return
			}
		}

		// Changing segment
		for segment in pathSegments {
			if segment.contains(progress) {
				cachedSegment = segment
				value.set(iterpolate(segment, position: progress))
				return
			}
		}
	}

	public override func getDuration() -> Double {
		return duration
	}

	private func iterpolate(segment: AnimationPathSegment<T>, position: Double) -> T {
		let relativePosition = (position - segment.start.position) / (segment.end.position - segment.start.position)
		return segment.start.value.interpolate(segment.end.value, progress: relativePosition)
	}
}
