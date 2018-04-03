open class Align {
    
    public static let min: Align = MinAlign()
    public static let mid: Align = MidAlign()
    public static let max: Align = MaxAlign()
    
    open func align(x: Double, y: Double) -> Double {
        return 0
    }
    
    open func align(x: Double) -> Double {
        return align(x: x, y: 0)
    }
    
}

private class MinAlign : Align {
    
    override func align(x: Double, y: Double) -> Double {
        return 0
    }
}

private class MidAlign : Align {
    
    override func align(x: Double, y: Double) -> Double {
        return x / 2 - y / 2
    }
}

private class MaxAlign : Align {
    
    override func align(x: Double, y: Double) -> Double {
        return x - y
    }
}
