

func boundsForFunc(_ func2d: func2D) -> Rect {

	var p = func2d(0.0)
	var minX = p.x
	var minY = p.y
	var maxX = minX
	var maxY = minY

	for t in stride(from: 0.0, to: 1.0, by: 0.01) {
		p = func2d(t)

		if minX > p.x {
			minX = p.x
		}

		if minY > p.y {
			minY = p.y
		}

		if maxX < p.x {
			maxX = p.x
		}

		if maxY < p.y {
			maxY = p.y
		}
	}

	return Rect(x: minX, y: minY, w: maxX - minX, h: maxY - minY)
}
