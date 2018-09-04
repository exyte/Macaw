open class Color: Fill {

    public let val: Int

    public static let white: Color = Color( val: 0xFFFFFF )
    public static let silver: Color = Color( val: 0xC0C0C0 )
    public static let gray: Color = Color( val: 0x808080 )
    public static let black: Color = Color( val: 0 )
    public static let red: Color = Color( val: 0xFF0000 )
    public static let maroon: Color = Color( val: 0x800000 )
    public static let yellow: Color = Color( val: 0xFFFF00 )
    public static let olive: Color = Color( val: 0x808000 )
    public static let lime: Color = Color( val: 0x00FF00 )
    public static let green: Color = Color( val: 0x008000 )
    public static let aqua: Color = Color( val: 0x00FFFF )
    public static let teal: Color = Color( val: 0x008080 )
    public static let blue: Color = Color( val: 0x0000FF )
    public static let navy: Color = Color( val: 0x000080 )
    public static let fuchsia: Color = Color( val: 0xFF00FF )
    public static let purple: Color = Color( val: 0x800080 )
    public static let clear: Color = Color.rgba(r: 0, g: 0, b: 0, a: 0)

    public init(val: Int = 0) {
        self.val = val
    }

    open func r() -> Int {
        return ( ( val >> 16 ) & 0xff )
    }

    open func g() -> Int {
        return ( ( val >> 8 ) & 0xff )
    }

    open func b() -> Int {
        return ( val & 0xff )
    }

    open func a() -> Int {
        return ( 255 - ( ( val >> 24 ) & 0xff ) )
    }

    public func with(a: Double) -> Color {
        return Color.rgba(r: r(), g: g(), b: b(), a: a)
    }

    open class func rgbt(r: Int, g: Int, b: Int, t: Int) -> Color {
        let x = ( ( t & 0xff ) << 24 )
        let y = ( ( r & 0xff ) << 16 )
        let z = ( ( g & 0xff ) << 8 )
        let q = b & 0xff
        return Color( val: ( ( ( x | y ) | z ) | q ) )
    }

    open class func rgba(r: Int, g: Int, b: Int, a: Double) -> Color {
        return rgbt( r: r, g: g, b: b, t: Int( ( ( 1 - a ) * 255 ) ) )
    }

    open class func rgb(r: Int, g: Int, b: Int) -> Color {
        return rgbt( r: r, g: g, b: b, t: 0 )
    }

    override func equals<T>(other: T) -> Bool where T: Color {
        return val == other.val
    }
}
