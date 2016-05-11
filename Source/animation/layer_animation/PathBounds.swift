
func pathBounds(path: Path) -> Rect? {

	guard let firstSegment = path.segments.first else {
		return .None
	}

	let firstSegmentInfo = pathSegmenInfo(firstSegment)
	var bounds = firstSegmentInfo.0
	var currentPoint = firstSegmentInfo.1 ?? Point.zero()

	print("New path - \(path.segments.count) segments")
	print("Initial bounds \(bounds!.description())")
	print("Initial point  \(currentPoint.description())")

	for segment in path.segments {
		let segmentInfo = pathSegmenInfo(segment)
		if let segmentBounds = segmentInfo.0 {
			if segment.absolute {
				print("Absolute segment")
				bounds = bounds?.union(segmentBounds)
			} else {
				bounds = bounds?.union(segmentBounds.move(currentPoint))
			}
		}

		print("Total bounds \(bounds!.description())")

		if let segmentLastPoint = segmentInfo.1 {
			if segment.absolute {
				currentPoint = segmentLastPoint
			} else {
				currentPoint = currentPoint.add(segmentLastPoint)
			}
		}

		print("Updated point  \(currentPoint.description())")
	}

	return bounds
}

func pathSegmenInfo(segment: PathSegment) -> (Rect?, Point?) {

	if let move = segment as? Move {
		return (moveBounds(move), Point(x: move.x, y: move.y))
	}

	if let cubic = segment as? Cubic {
		return (cubicBounds(cubic), Point(x: cubic.x, y: cubic.y))
	}

//	if let sCubic = segment as? SCubic {
//		return sCubicBounds(sCubic)
//	}

	if let hLine = segment as? HLine {
		return (hLineBounds(hLine), Point(x: hLine.x, y: 0.0))
	}

	if let vLine = segment as? VLine {
		return (vLineBounds(vLine), Point(x: 0.0, y: vLine.y))
	}

	if let pLine = segment as? PLine {
		return (pLineBounds(pLine), Point(x: pLine.x, y: pLine.y))
	}

	return (.None, .None)
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

private func sCubicBounds(sCubic: SCubic) -> Rect {
	return Rect.zero()
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
