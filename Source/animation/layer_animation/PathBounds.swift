
func pathBounds(path: Path) -> Rect? {

	guard let firstSegment = path.segments.first else {
		return .None
	}

	let firstSegmentInfo = pathSegmenInfo(firstSegment, currentPoint: .None, currentBezierPoint: .None)
	var bounds = firstSegmentInfo.0
	var currentPoint = firstSegmentInfo.1 ?? Point.origin
	var cubicBezierPoint: Point?

	for segment in path.segments {
		let segmentInfo = pathSegmenInfo(segment, currentPoint: currentPoint, currentBezierPoint: cubicBezierPoint)
		if let segmentBounds = segmentInfo.0 {
			if segment.absolute {
				bounds = bounds?.union(segmentBounds)
			} else {
				bounds = bounds?.union(segmentBounds.move(currentPoint))
			}
		}

		if let segmentLastPoint = segmentInfo.1 {
			if segment.absolute {
				currentPoint = segmentLastPoint
			} else {
				currentPoint = segmentLastPoint.add(currentPoint)
			}
		}

		if let segmentBezierPoint = segmentInfo.2 {
			if segment.absolute {
				cubicBezierPoint = segmentBezierPoint
			} else {
				cubicBezierPoint = segmentBezierPoint.add(currentPoint)
			}
		}
	}

	return bounds
}

func pathSegmenInfo(segment: PathSegment, currentPoint: Point?, currentBezierPoint: Point?)
	-> (Rect?, Point?, Point?) { // Bounds, last point, last bezier point TODO: Replace as struct

		if let move = segment as? Move {
			return (moveBounds(move), Point(x: move.x, y: move.y), .None)
		}

		if let cubic = segment as? Cubic {
			return (cubicBounds(cubic), Point(x: cubic.x, y: cubic.y), Point(x: cubic.x2, y: cubic.y2))
		}

		if let sCubic = segment as? SCubic {
			guard let currentPoint = currentPoint else {
				return (.None, .None, .None)
			}

			var p2 = currentPoint
			if let bezierPoint = currentBezierPoint {
				p2 = Point(
					x: 2.0 * currentPoint.x - bezierPoint.x,
					y: 2.0 * currentPoint.y - bezierPoint.y)
			}

			return (sCubicBounds(sCubic, currentPoint: currentPoint, currentBezierPoint: currentBezierPoint),
				Point(x: sCubic.x, y: sCubic.y),
				Point(x: p2.x, y: p2.y))
		}

		if let hLine = segment as? HLine {
			return (hLineBounds(hLine), Point(x: hLine.x, y: 0.0), .None)
		}

		if let vLine = segment as? VLine {
			return (vLineBounds(vLine), Point(x: 0.0, y: vLine.y), .None)
		}

		if let pLine = segment as? PLine {
			return (pLineBounds(pLine), Point(x: pLine.x, y: pLine.y), .None)
		}

		return (.None, .None, .None)
}

private func moveBounds(move: Move) -> Rect {
	return Rect(x: move.x, y: move.y, w: 0.0, h: 0.0)
}

private func cubicBounds(cubic: Cubic) -> Rect {

	let p0 = Point(x: 0, y: 0)
	let p1 = Point(x: cubic.x1, y: cubic.y1)
	let p2 = Point(x: cubic.x2, y: cubic.y2)
	let p3 = Point(x: cubic.x, y: cubic.y)

	let bezier3 = { (t: Double) -> Point in return BezierFunc2D(t, p0: p0, p1: p1, p2: p2, p3: p3) }

	// TODO: Replace with accurate implementation via derivative
	return boundsForFunc(bezier3)
}

private func sCubicBounds(sCubic: SCubic, currentPoint: Point, currentBezierPoint: Point?) -> Rect {

	let p0 = Point(x: 0, y: 0)
	let p1 = Point(x: sCubic.x2, y: sCubic.y2)
	let p3 = Point(x: sCubic.x, y: sCubic.y)
	var p2 = currentPoint
	if let bezierPoint = currentBezierPoint {
		p2 = Point(
			x: 2.0 * currentPoint.x - bezierPoint.x,
			y: 2.0 * currentPoint.y - bezierPoint.y)
	}

	let bezier3 = { (t: Double) -> Point in return BezierFunc2D(t, p0: p0, p1: p1, p2: p2, p3: p3) }

	// TODO: Replace with accurate implementation via derivative
	return boundsForFunc(bezier3)
}

private func hLineBounds(hLine: HLine) -> Rect {
	return Rect(x: 0.0, y: 0.0, w: hLine.x, h: 0.0)
}

private func vLineBounds(vLine: VLine) -> Rect {
	return Rect(x: 0.0, y: 0.0, w: 0.0, h: vLine.y)
}

private func pLineBounds(pLine: PLine) -> Rect {
	return Rect(x: pLine.x, y: pLine.y, w: 0.0, h: 0.0)
}
