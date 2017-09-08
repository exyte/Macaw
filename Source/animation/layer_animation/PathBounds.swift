
func pathBounds(_ path: Path) -> Rect? {
    let rect = RenderUtils.toCGPath(path).boundingBox
    return Rect(cgRect: rect)
}
