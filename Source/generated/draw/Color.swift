import Foundation

public class Color: Fill  {

	var val: Int = 0

	public static var white: Color = Color( val: 0xFFFFFF )
	public static var silver: Color = Color( val: 0xC0C0C0 )
	public static var gray: Color = Color( val: 0x808080 )
	public static var black: Color = Color( val: 0 )
	public static var red: Color = Color( val: 0xFF0000 )
	public static var maroon: Color = Color( val: 0x800000 )
	public static var yellow: Color = Color( val: 0xFFFF00 )
	public static var olive: Color = Color( val: 0x808000 )
	public static var lime: Color = Color( val: 0x00FF00 )
	public static var green: Color = Color( val: 0x008000 )
	public static var aqua: Color = Color( val: 0x00FFFF )
	public static var teal: Color = Color( val: 0x008080 )
	public static var blue: Color = Color( val: 0x0000FF )
	public static var navy: Color = Color( val: 0x000080 )
	public static var fuchsia: Color = Color( val: 0xFF00FF )
	public static var purple: Color = Color( val: 0x800080 )

	init(val: Int = 0) {
		self.val = val	
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
	class func rgbt(r: Int, g: Int, b: Int, t: Int) -> Color {
		return Color(val: ( ( ( ( ( t & 0xff ) << 24 ) | ( ( r & 0xff ) << 16 ) ) | ( ( g & 0xff ) << 8 ) ) | ( b & 0xff ) ))
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
