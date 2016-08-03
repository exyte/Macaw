import Foundation
import RxSwift

public class Mouse {

	public let hoverVar: Variable<Bool>
	public var hover: Bool {
		get { return hoverVar.value }
		set(val) { hoverVar.value = val }
	}

	public let posVar: Variable<Point>
	public var pos: Point {
		get { return posVar.value }
		set(val) { posVar.value = val }
	}

	public let onEnterVar: Variable<Signal>
	public var onEnter: Signal {
		get { return onEnterVar.value }
		set(val) { onEnterVar.value = val }
	}

	public let onExitVar: Variable<Signal>
	public var onExit: Signal {
		get { return onExitVar.value }
		set(val) { onExitVar.value = val }
	}

	public let onWheelVar: Variable<Signal>
	public var onWheel: Signal {
		get { return onWheelVar.value }
		set(val) { onWheelVar.value = val }
	}

	public init(hover: Bool = false, pos: Point, onEnter: Signal, onExit: Signal, onWheel: Signal) {
		self.hoverVar = Variable<Bool>(hover)
		self.posVar = Variable<Point>(pos)
		self.onEnterVar = Variable<Signal>(onEnter)
		self.onExitVar = Variable<Signal>(onExit)
		self.onWheelVar = Variable<Signal>(onWheel)
	}

	// GENERATED NOT
	public func left() -> MouseButton {
		return MouseButton(onPress: Signal(), onRelease: Signal(), onClick: Signal(), onDoubleClick: Signal())
	}
	// GENERATED NOT
	public func middle() -> MouseButton {
        return MouseButton(onPress: Signal(), onRelease: Signal(), onClick: Signal(), onDoubleClick: Signal())
	}
	// GENERATED NOT
	public func right() -> MouseButton {
		return MouseButton(onPress: Signal(), onRelease: Signal(), onClick: Signal(), onDoubleClick: Signal())
	}

}
