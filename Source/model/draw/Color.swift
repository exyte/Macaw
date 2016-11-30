import Foundation

open class Color: Fill {

	open let val: Int

	open static let white: Color = Color( val: 0xFFFFFF )
	open static let silver: Color = Color( val: 0xC0C0C0 )
	open static let gray: Color = Color( val: 0x808080 )
	open static let black: Color = Color( val: 0 )
	open static let red: Color = Color( val: 0xFF0000 )
	open static let maroon: Color = Color( val: 0x800000 )
	open static let yellow: Color = Color( val: 0xFFFF00 )
	open static let olive: Color = Color( val: 0x808000 )
	open static let lime: Color = Color( val: 0x00FF00 )
	open static let green: Color = Color( val: 0x008000 )
	open static let aqua: Color = Color( val: 0x00FFFF )
	open static let teal: Color = Color( val: 0x008080 )
	open static let blue: Color = Color( val: 0x0000FF )
	open static let navy: Color = Color( val: 0x000080 )
	open static let fuchsia: Color = Color( val: 0xFF00FF )
	open static let purple: Color = Color( val: 0x800080 )

	public init(val: Int = 0) {
		self.val = val
	}

	// GENERATED
	open func r() -> Int {
		return ( ( val >> 16 ) & 0xff )
	}

	// GENERATED
	open func g() -> Int {
		return ( ( val >> 8 ) & 0xff )
	}

	// GENERATED
	open func b() -> Int {
		return ( val & 0xff )
	}

	// GENERATED
	open func a() -> Int {
		return ( 255 - ( ( val >> 24 ) & 0xff ) )
	}

    // GENERATED
    public func with(a a: Double) -> Color {
        return Color.rgba(r: r(), g: g(), b: b(), a: a)
    }

	// GENERATED
	open class func rgbt(r: Int, g: Int, b: Int, t: Int) -> Color {
		return Color( val: ( ( ( ( ( t & 0xff ) << 24 ) | ( ( r & 0xff ) << 16 ) ) | ( ( g & 0xff ) << 8 ) ) | ( b & 0xff ) ) )
	}

	// GENERATED
	open class func rgba(r: Int, g: Int, b: Int, a: Double) -> Color {
		return rgbt( r: r, g: g, b: b, t: Int( ( ( 1 - a ) * 255 ) ) )
	}

	// GENERATED
	open class func rgb(r: Int, g: Int, b: Int) -> Color {
		return rgbt( r: r, g: g, b: b, t: 0 )
	}

}
