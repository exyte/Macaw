
func pathBounds(path: Path) -> Rect? {

	guard let firstSegment = path.segments.first else {
		return .None
	}

	var bounds = pathSegmentBounds(firstSegment)
	for segment in path.segments {
		if let segmentBounds = pathSegmentBounds(segment) {
			bounds = bounds?.union(segmentBounds)
		}
	}

	return bounds
}

func pathSegmentBounds(segment: PathSegment) -> Rect? {

	if let move = segment as? Move {
		return moveBounds(move)
	}

	if let cubic = segment as? Cubic {
		return cubicBounds(cubic)
	}

	if let sCubic = segment as? SCubic {
		return sCubicBounds(sCubic)
	}

	if let hLine = segment as? HLine {
		return hLineBounds(hLine)
	}

	if let pLine = segment as? PLine {
		return pLineBounds(pLine)
	}

	return .None
}

private func moveBounds(move: Move) -> Rect {
	return Rect.zero()
}

private func cubicBounds(cubic: Cubic) -> Rect {

	let p0 = Point(x: 0, y: 0)
	let p1 = Point(x: cubic.x1, y: cubic.y1)
	let p2 = Point(x: cubic.x2, y: cubic.y2)
	let p3 = Point(x: cubic.x, y: cubic.y)

	let bezier3 = { (t: Double) -> Point in return BezierFunc2D(t, p0: p0, p1: p1, p2: p2, p3: p3) }
	return boundsForFunc(bezier3)
}

private func sCubicBounds(sCubic: SCubic) -> Rect {
	return Rect.zero()
}

private func hLineBounds(hLine: HLine) -> Rect {
	return Rect.zero()
}

private func pLineBounds(pLine: PLine) -> Rect {
	return Rect.zero()
}
