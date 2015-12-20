import Foundation

public class MouseButton {

	var pressed: Bool
	var onPress: Signal
	var onRelease: Signal
	var onClick: Signal
	var onDoubleClick: Signal

	init(pressed: Bool, onPress: Signal, onRelease: Signal, onClick: Signal, onDoubleClick: Signal) {
		self.pressed = pressed	
		self.onPress = onPress	
		self.onRelease = onRelease	
		self.onClick = onClick	
		self.onDoubleClick = onDoubleClick	
	}

}
