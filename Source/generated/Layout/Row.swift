import Foundation

class Row: Layout  {

	var spacing: NSNumber = 0
	var wrap: Bool = true
	var pack_x: Bool = true
	var pack_y: Bool = true
	var fill: Bool = false
	var center: Bool = false
	var justify: Bool = false

	init(spacing: NSNumber = 0, wrap: Bool = true, pack_x: Bool = true, pack_y: Bool = true, fill: Bool = false, center: Bool = false, justify: Bool = false) {
		self.spacing = spacing	
		self.wrap = wrap	
		self.pack_x = pack_x	
		self.pack_y = pack_y	
		self.fill = fill	
		self.center = center	
		self.justify = justify	
	}

}
