import Foundation

class Color: Fill  {

	var val: Int = 0

	static var white: Color = Color( val: 16777215 )
	static var silver: Color = Color( val: 12632256 )
	static var gray: Color = Color( val: 8421504 )
	static var black: Color = Color( val: 0 )
	static var red: Color = Color( val: 16711680 )
	static var maroon: Color = Color( val: 8388608 )
	static var yellow: Color = Color( val: 16776960 )
	static var olive: Color = Color( val: 8421376 )
	static var lime: Color = Color( val: 65280 )
	static var green: Color = Color( val: 32768 )
	static var aqua: Color = Color( val: 65535 )
	static var teal: Color = Color( val: 32896 )
	static var blue: Color = Color( val: 255 )
	static var navy: Color = Color( val: 128 )
	static var fuchsia: Color = Color( val: 16711935 )
	static var purple: Color = Color( val: 8388736 )

	init(val: Int = 0) {
		self.val = val	
	}

	// GENERATED
	func r() -> Int {
		return ( ( val >> 16 ) & 255 )
	}
	// GENERATED
	func g() -> Int {
		return ( ( val >> 8 ) & 255 )
	}
	// GENERATED
	func b() -> Int {
		return ( val & 255 )
	}
	// GENERATED
	func a() -> Int {
		return ( 255 - ( ( val >> 24 ) & 255 ) )
	}

	// GENERATED
	class func rgbt(r: Int, g: Int, b: Int, t: Int) -> Color {
		return Color(val: ( ( ( ( ( t & 255 ) << 24 ) | ( ( r & 255 ) << 16 ) ) | ( ( g & 255 ) << 8 ) ) | ( b & 255 ) ))
	}

	// GENERATED
	class func rgba(r: Int, g: Int, b: Int, a: Float) -> Color {
		return rgbt( r, g: g, b: b, t: Int( ( ( 1 - a ) * 255 ) ) )
	}

	// GENERATED
	class func rgb(r: Int, g: Int, b: Int) -> Color {
		return rgbt( r, g: g, b: b, t: 0 )
	}

}
