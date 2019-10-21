open class AspectRatio {

    public static let none: AspectRatio = AspectRatio()
    public static let meet: AspectRatio = MeetAspectRatio()
    public static let slice: AspectRatio = SliceAspectRatio()
    internal static let doNothing: AspectRatio = DoNothingAspectRatio()

    open func fit(size: Size, into sizeToFitIn: Size) -> Size {
        return Size(w: sizeToFitIn.w, h: sizeToFitIn.h)
    }

    open func fit(rect: Rect, into rectToFitIn: Rect) -> Size {
        return fit(size: rect.size(), into: rectToFitIn.size())
    }

    open func fit(size: Size, into rectToFitIn: Rect) -> Size {
        return fit(size: size, into: rectToFitIn.size())
    }

}

internal class DoNothingAspectRatio: AspectRatio {

    override func fit(size: Size, into sizeToFitIn: Size) -> Size {
        return size
    }
}

private class MeetAspectRatio: AspectRatio {

    override func fit(size: Size, into sizeToFitIn: Size) -> Size {
        let widthRatio = sizeToFitIn.w / size.w
        let heightRatio = sizeToFitIn.h / size.h

        if heightRatio < widthRatio {
            return Size(w: size.w * heightRatio, h: sizeToFitIn.h)
        } else {
            return Size(w: sizeToFitIn.w, h: size.h * widthRatio)
        }
    }
}

private class SliceAspectRatio: AspectRatio {

    override func fit(size: Size, into sizeToFitIn: Size) -> Size {
        let widthRatio = sizeToFitIn.w / size.w
        let heightRatio = sizeToFitIn.h / size.h

        if heightRatio > widthRatio {
            return Size(w: size.w * heightRatio, h: sizeToFitIn.h)
        } else {
            return Size(w: sizeToFitIn.w, h: size.h * widthRatio)
        }
    }
}
