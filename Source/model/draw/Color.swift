open class Color: Fill {

    public let val: Int

    public static let white = Color(0xFFFFFF)
    public static let silver = Color(0xC0C0C0)
    public static let gray = Color(0x808080)
    public static let black = Color(0)
    public static let red = Color(0xFF0000)
    public static let maroon = Color(0x800000)
    public static let yellow = Color(0xFFFF00)
    public static let olive = Color(0x808000)
    public static let lime = Color(0x00FF00)
    public static let green = Color(0x008000)
    public static let aqua = Color(0x00FFFF)
    public static let teal = Color(0x008080)
    public static let blue = Color(0x0000FF)
    public static let navy = Color(0x000080)
    public static let fuchsia = Color(0xFF00FF)
    public static let purple = Color(0x800080)

    public static let clear = Color.rgba(r: 0, g: 0, b: 0, a: 0)

    public static let aliceBlue = Color(0xf0f8ff)
    public static let antiqueWhite = Color(0xfaebd7)
    public static let aquamarine = Color(0x7fffd4)
    public static let azure = Color(0xf0ffff)
    public static let beige = Color(0xf5f5dc)
    public static let bisque = Color(0xffe4c4)
    public static let blanchedAlmond = Color(0xffebcd)
    public static let blueViolet = Color(0x8a2be2)
    public static let brown = Color(0xa52a2a)
    public static let burlywood = Color(0xdeb887)
    public static let cadetBlue = Color(0x5f9ea0)
    public static let chartreuse = Color(0x7fff00)
    public static let chocolate = Color(0xd2691e)
    public static let coral = Color(0xff7f50)
    public static let cornflowerBlue = Color(0x6495ed)
    public static let cornsilk = Color(0xfff8dc)
    public static let crimson = Color(0xdc143c)
    public static let cyan = Color(0x00ffff)
    public static let darkBlue = Color(0x00008b)
    public static let darkCyan = Color(0x008b8b)
    public static let darkGoldenrod = Color(0xb8860b)
    public static let darkGray = Color(0xa9a9a9)
    public static let darkGreen = Color(0x006400)
    public static let darkKhaki = Color(0xbdb76b)
    public static let darkMagenta = Color(0x8b008b)
    public static let darkOliveGreen = Color(0x556b2f)
    public static let darkOrange = Color(0xff8c00)
    public static let darkOrchid = Color(0x9932cc)
    public static let darkRed = Color(0x8b0000)
    public static let darkSalmon = Color(0xe9967a)
    public static let darkSeaGreen = Color(0x8fbc8f)
    public static let darkSlateBlue = Color(0x483d8b)
    public static let darkSlateGray = Color(0x2f4f4f)
    public static let darkTurquoise = Color(0x00ced1)
    public static let darkViolet = Color(0x9400d3)
    public static let deepPink = Color(0xff1493)
    public static let deepSkyBlue = Color(0x00bfff)
    public static let dimGray = Color(0x696969)
    public static let dodgerBlue = Color(0x1e90ff)
    public static let firebrick = Color(0xb22222)
    public static let floralWhite = Color(0xfffaf0)
    public static let forestGreen = Color(0x228b22)
    public static let gainsboro = Color(0xdcdcdc)
    public static let ghostWhite = Color(0xf8f8ff)
    public static let gold = Color(0xffd700)
    public static let goldenrod = Color(0xdaa520)
    public static let greenYellow = Color(0xadff2f)
    public static let honeydew = Color(0xf0fff0)
    public static let hotPink = Color(0xff69b4)
    public static let indianRed = Color(0xcd5c5c)
    public static let indigo = Color(0x4b0082)
    public static let ivory = Color(0xfffff0)
    public static let khaki = Color(0xf0e68c)
    public static let lavender = Color(0xe6e6fa)
    public static let lavenderBlush = Color(0xfff0f5)
    public static let lawnGreen = Color(0x7cfc00)
    public static let lemonChiffon = Color(0xfffacd)
    public static let lightBlue = Color(0xadd8e6)
    public static let lightCoral = Color(0xf08080)
    public static let lightCyan = Color(0xe0ffff)
    public static let lightGoldenrodYellow = Color(0xfafad2)
    public static let lightGray = Color(0xd3d3d3)
    public static let lightGreen = Color(0x90ee90)
    public static let lightPink = Color(0xffb6c1)
    public static let lightSalmon = Color(0xffa07a)
    public static let lightSeaGreen = Color(0x20b2aa)
    public static let lightSkyBlue = Color(0x87cefa)
    public static let lightSlateGray = Color(0x778899)
    public static let lightSteelBlue = Color(0xb0c4de)
    public static let lightYellow = Color(0xffffe0)
    public static let limeGreen = Color(0x32cd32)
    public static let linen = Color(0xfaf0e6)
    public static let mediumAquamarine = Color(0x66cdaa)
    public static let mediumBlue = Color(0x0000cd)
    public static let mediumOrchid = Color(0xba55d3)
    public static let mediumPurple = Color(0x9370db)
    public static let mediumSeaGreen = Color(0x3cb371)
    public static let mediumSlateBlue = Color(0x7b68ee)
    public static let mediumSpringGreen = Color(0x00fa9a)
    public static let mediumTurquoise = Color(0x48d1cc)
    public static let mediumVioletRed = Color(0xc71585)
    public static let midnightBlue = Color(0x191970)
    public static let mintCream = Color(0xf5fffa)
    public static let mistyRose = Color(0xffe4e1)
    public static let moccasin = Color(0xffe4b5)
    public static let navajoWhite = Color(0xffdead)
    public static let oldLace = Color(0xfdf5e6)
    public static let oliveDrab = Color(0x6b8e23)
    public static let orange = Color(0xffa500)
    public static let orangeRed = Color(0xff4500)
    public static let orchid = Color(0xda70d6)
    public static let paleGoldenrod = Color(0xeee8aa)
    public static let paleGreen = Color(0x98fb98)
    public static let paleTurquoise = Color(0xafeeee)
    public static let paleVioletRed = Color(0xdb7093)
    public static let papayaWhip = Color(0xffefd5)
    public static let peachPuff = Color(0xffdab9)
    public static let peru = Color(0xcd853f)
    public static let pink = Color(0xffc0cb)
    public static let plum = Color(0xdda0dd)
    public static let powderBlue = Color(0xb0e0e6)
    public static let rebeccaPurple = Color(0x663399)
    public static let rosyBrown = Color(0xbc8f8f)
    public static let royalBlue = Color(0x4169e1)
    public static let saddleBrown = Color(0x8b4513)
    public static let salmon = Color(0xfa8072)
    public static let sandyBrown = Color(0xf4a460)
    public static let seaGreen = Color(0x2e8b57)
    public static let seashell = Color(0xfff5ee)
    public static let sienna = Color(0xa0522d)
    public static let skyBlue = Color(0x87ceeb)
    public static let slateBlue = Color(0x6a5acd)
    public static let slateGray = Color(0x708090)
    public static let snow = Color(0xfffafa)
    public static let springGreen = Color(0x00ff7f)
    public static let steelBlue = Color(0x4682b4)
    public static let tan = Color(0xd2b48c)
    public static let thistle = Color(0xd8bfd8)
    public static let tomato = Color(0xff6347)
    public static let turquoise = Color(0x40e0d0)
    public static let violet = Color(0xee82ee)
    public static let wheat = Color(0xf5deb3)
    public static let whiteSmoke = Color(0xf5f5f5)
    public static let yellowGreen = Color(0x9acd32)

    public init(_ val: Int = 0) {
        self.val = val
    }

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

    override func equals<T>(other: T) -> Bool where T: Fill {
        guard let other = other as? Color else {
            return false
        }
        return val == other.val
    }
}
