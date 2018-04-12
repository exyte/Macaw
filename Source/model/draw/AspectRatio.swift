open class AspectRatio {

    public static let none: AspectRatio = NoneAspectRatio()
    public static let meet: AspectRatio = MeetAspectRatio()
    public static let slice: AspectRatio = SliceAspectRatio()

    open func fit(rect: Rect, into rectToFitIn: Rect) -> Size {
        return Size(w: 0, h: 0)
    }

    open func fit(size: Size, into rectToFitIn: Rect) -> Size {
        return fit(rect: Rect(x: 0, y: 0, w: size.w, h: size.h), into: rectToFitIn)
    }

    open func fit(size: Size, into sizeToFitIn: Size) -> Size {
        return fit(size: size, into: Rect(x: 0, y: 0, w: sizeToFitIn.w, h: sizeToFitIn.h))
    }

}

private class NoneAspectRatio: AspectRatio {

    override func fit(rect: Rect, into rectToFitIn: Rect) -> Size {
        return Size(w: rectToFitIn.w, h: rectToFitIn.h)
    }
}

private class MeetAspectRatio: AspectRatio {

    override func fit(rect: Rect, into rectToFitIn: Rect) -> Size {
        let widthRatio = rectToFitIn.w / rect.w
        let heightRatio = rectToFitIn.h / rect.h

        var newWidth = rectToFitIn.w
        var newHeight = rectToFitIn.h

        if heightRatio < widthRatio {
            newWidth = rect.w * heightRatio
        } else {
            newHeight = rect.h * widthRatio
        }
        return Size(w: newWidth, h: newHeight)
    }
}

private class SliceAspectRatio: AspectRatio {

    override func fit(rect: Rect, into rectToFitIn: Rect) -> Size {
        let widthRatio = rectToFitIn.w / rect.w
        let heightRatio = rectToFitIn.h / rect.h

        var newWidth = rectToFitIn.w
        var newHeight = rectToFitIn.h

        if heightRatio > widthRatio {
            newWidth = rect.w * heightRatio
        } else {
            newHeight = rect.h * widthRatio
        }
        return Size(w: newWidth, h: newHeight)
    }
}
