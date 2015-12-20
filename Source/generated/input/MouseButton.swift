import Foundation

public class MouseButton {

	var pressed: Bool = false
	var onPress: Signal? = nil
	var onRelease: Signal? = nil
	var onClick: Signal? = nil
	var onDoubleClick: Signal? = nil

	public init(pressed: Bool = false, onPress: Signal? = nil, onRelease: Signal? = nil, onClick: Signal? = nil, onDoubleClick: Signal? = nil) {
		self.pressed = pressed	
		self.onPress = onPress	
		self.onRelease = onRelease	
		self.onClick = onClick	
		self.onDoubleClick = onDoubleClick	
	}

}
