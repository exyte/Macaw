import Foundation
import RxSwift

public class MouseButton {

	public let pressedVar: Variable<Bool>
	public var pressed: Bool {
		get { return pressedVar.value }
		set(val) { pressedVar.value = val }
	}

	public let onPressVar: Variable<Signal>
	public var onPress: Signal {
		get { return onPressVar.value }
		set(val) { onPressVar.value = val }
	}

	public let onReleaseVar: Variable<Signal>
	public var onRelease: Signal {
		get { return onReleaseVar.value }
		set(val) { onReleaseVar.value = val }
	}

	public let onClickVar: Variable<Signal>
	public var onClick: Signal {
		get { return onClickVar.value }
		set(val) { onClickVar.value = val }
	}

	public let onDoubleClickVar: Variable<Signal>
	public var onDoubleClick: Signal {
		get { return onDoubleClickVar.value }
		set(val) { onDoubleClickVar.value = val }
	}

	public init(pressed: Bool = false, onPress: Signal, onRelease: Signal, onClick: Signal, onDoubleClick: Signal) {
		self.pressedVar = Variable<Bool>(pressed)	
		self.onPressVar = Variable<Signal>(onPress)	
		self.onReleaseVar = Variable<Signal>(onRelease)	
		self.onClickVar = Variable<Signal>(onClick)	
		self.onDoubleClickVar = Variable<Signal>(onDoubleClick)	
	}

}
