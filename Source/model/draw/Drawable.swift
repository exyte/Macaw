import Foundation

open class Drawable {

    open var id: String?
	open let visible: Bool
	open let tag: [String]

	public init(visible: Bool = true, tag: [String] = []) {
		self.visible = visible
		self.tag = tag
	}

}
