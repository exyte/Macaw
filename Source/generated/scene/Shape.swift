import Foundation

class Shape: Node  {

	var form: Locus
	var fill: Fill
	var stroke: Stroke


	init(form: Locus, fill: Fill, stroke: Stroke) {
		self.form = form	
		self.fill = fill	
		self.stroke = stroke	
	}

}
