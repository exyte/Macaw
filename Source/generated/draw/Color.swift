import Foundation

class Color: Fill  {

	var val: Int = 0
	var white: Color = Color
	var silver: Color = Color
	var gray: Color = Color
	var black: Color = Color
	var red: Color = Color
	var maroon: Color = Color
	var yellow: Color = Color
	var olive: Color = Color
	var lime: Color = Color
	var green: Color = Color
	var aqua: Color = Color
	var teal: Color = Color
	var blue: Color = Color
	var navy: Color = Color
	var fuchsia: Color = Color
	var purple: Color = Color


	init(val: Int = 0, white: Color = Color, silver: Color = Color, gray: Color = Color, black: Color = Color, red: Color = Color, maroon: Color = Color, yellow: Color = Color, olive: Color = Color, lime: Color = Color, green: Color = Color, aqua: Color = Color, teal: Color = Color, blue: Color = Color, navy: Color = Color, fuchsia: Color = Color, purple: Color = Color) {
		self.val = val	
		self.white = white	
		self.silver = silver	
		self.gray = gray	
		self.black = black	
		self.red = red	
		self.maroon = maroon	
		self.yellow = yellow	
		self.olive = olive	
		self.lime = lime	
		self.green = green	
		self.aqua = aqua	
		self.teal = teal	
		self.blue = blue	
		self.navy = navy	
		self.fuchsia = fuchsia	
		self.purple = purple	
	}

	// GENERATED
	func r() -> Int {
		return ( ( val >> 16 ) & 0xff )
	}

	// GENERATED
	func g() -> Int {
		return ( ( val >> 8 ) & 0xff )
	}

	// GENERATED
	func b() -> Int {
		return ( val & 0xff )
	}

	// GENERATED
	func a() -> Int {
		return ( 255 - ( ( val >> 24 ) & 0xff ) )
	}

	// GENERATED
	func rgbt(r: Int, g: Int, b: Int, t: Int) -> Color {
		return Color(val: ( ( ( ( ( t & 0xff ) << 24 ) | ( ( r & 0xff ) << 16 ) ) | ( ( g & 0xff ) << 8 ) ) | ( b & 0xff ) ))
	}

	// GENERATED
	func rgba(r: Int, g: Int, b: Int, a: Float) -> NSNumber {
		return rgbt( r, g, b, Int( ( ( 1 - a ) * 255 ) ) )
	}

	// GENERATED
	func rgb(r: Int, g: Int, b: Int) -> NSNumber {
		return rgbt( r, g, b, 0 )
	}

}
