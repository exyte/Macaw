open class Align {

    public static let min: Align = Align()
    public static let mid: Align = MidAlign()
    public static let max: Align = MaxAlign()

    open func align(outer: Double, inner: Double) -> Double {
        0
    }

    open func align(size: Double) -> Double {
        align(outer: size, inner: 0)
    }

}

private class MidAlign: Align {

    override func align(outer: Double, inner: Double) -> Double {
        (outer - inner) / 2
    }
}

private class MaxAlign: Align {

    override func align(outer: Double, inner: Double) -> Double {
        outer - inner
    }
}
