private var animatingVar = false

extension Node {
	var animating: Bool {
		get {
			return animatingVar
		}
		set(newValue) {
			animatingVar = newValue
		}
	}
}