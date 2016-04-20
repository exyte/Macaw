import Foundation

public class Shape: Node {

	public let formProperty: ObservableValue<Locus>
	public var form: Locus {
		get { return formProperty.get() }
		set(val) { formProperty.set(val) }
	}

	public let fillProperty: ObservableValue<Fill?>
	public var fill: Fill? {
		get { return fillProperty.get() }
		set(val) { fillProperty.set(val) }
	}

	public let strokeProperty: ObservableValue<Stroke?>
	public var stroke: Stroke? {
		get { return strokeProperty.get() }
		set(val) { strokeProperty.set(val) }
	}

	public init(form: Locus, fill: Fill? = nil, stroke: Stroke? = nil, pos: Transform = Transform(), opaque: NSObject = true, visible: NSObject = true, clip: Locus? = nil, tag: [String] = []) {
		self.formProperty = ObservableValue<Locus>(value: form)
		self.fillProperty = ObservableValue<Fill?>(value: fill)
		self.strokeProperty = ObservableValue<Stroke?>(value: stroke)
		super.init(
			pos: pos,
			opaque: opaque,
			visible: visible,
			clip: clip,
			tag: tag
		)
	}
}
