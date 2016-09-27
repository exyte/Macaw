
func pathBounds(_ path: Path) -> Rect? {

	guard let firstSegment = path.segments.first else {
		return .none
	}

	let firstSegmentInfo = pathSegmenInfo(firstSegment, currentPoint: .none, currentBezierPoint: .none)
	var bounds = firstSegmentInfo.0
	var currentPoint = firstSegmentInfo.1 ?? Point.origin
	var cubicBezierPoint: Point?

	for segment in path.segments {
		let segmentInfo = pathSegmenInfo(segment, currentPoint: currentPoint, currentBezierPoint: cubicBezierPoint)
		if let segmentBounds = segmentInfo.0 {
			if segment.isAbsolute() {
				bounds = bounds?.union(rect: segmentBounds)
			} else {
				bounds = bounds?.union(rect: segmentBounds.move(offset: currentPoint))
			}
		}

		if let segmentLastPoint = segmentInfo.1 {
			if segment.isAbsolute() {
				currentPoint = segmentLastPoint
			} else {
				currentPoint = segmentLastPoint.add(currentPoint)
			}
		}

		if let segmentBezierPoint = segmentInfo.2 {
			if segment.isAbsolute() {
				cubicBezierPoint = segmentBezierPoint
			} else {
				cubicBezierPoint = segmentBezierPoint.add(currentPoint)
			}
		}
	}

	return bounds
}

func pathSegmenInfo(_ segment: PathSegment, currentPoint: Point?, currentBezierPoint: Point?)
	-> (Rect?, Point?, Point?) { // Bounds, last point, last bezier point TODO: Replace as struct

        let data = segment.data
        switch segment.type {
        case .m, .M:
            let point = Point(x: data[0], y: data[1])
            return (Rect(x: point.x, y: point.y, w: 0.0, h: 0.0), point, .none)
        case .c, .C:
            return (cubicBounds(data), Point(x: data[4], y: data[5]), Point(x: data[2], y: data[3]))
        case .s, .S:
            guard let currentPoint = currentPoint else {
                return (.none, .none, .none)
            }
            
            var p2 = currentPoint
            if let bezierPoint = currentBezierPoint {
                p2 = Point(
                    x: 2.0 * currentPoint.x - bezierPoint.x,
                    y: 2.0 * currentPoint.y - bezierPoint.y)
            }
            
            return (sCubicBounds(data, currentPoint: currentPoint, currentBezierPoint: currentBezierPoint),
                    Point(x: data[2], y: data[3]),
                    Point(x: p2.x, y: p2.y))
        case .h, .H:
            return (Rect(x: 0.0, y: 0.0, w: data[0], h: 0.0), Point(x: data[0], y: 0.0), .none)
        case .v, .V:
            return (Rect(x: 0.0, y: 0.0, w: 0.0, h: data[0]), Point(x: 0.0, y: data[0]), .none)
        case .l, .L:
            return (Rect(x: data[0], y: data[1], w: 0.0, h: 0.0), Point(x: data[0], y: data[1]), .none)
        default:
            return (.none, .none, .none)
        }
}

private func cubicBounds(_ data: [Double]) -> Rect {
	let p0 = Point(x: 0, y: 0)
	let p1 = Point(x: data[0], y: data[1])
	let p2 = Point(x: data[2], y: data[3])
	let p3 = Point(x: data[3], y: data[4])

	let bezier3 = { (t: Double) -> Point in return BezierFunc2D(t, p0: p0, p1: p1, p2: p2, p3: p3) }

	// TODO: Replace with accurate implementation via derivative
	return boundsForFunc(bezier3)
}

private func sCubicBounds(_ data: [Double], currentPoint: Point, currentBezierPoint: Point?) -> Rect {

	let p0 = Point(x: 0, y: 0)
	let p1 = Point(x: data[0], y: data[1])
	let p3 = Point(x: data[2], y: data[3])
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
