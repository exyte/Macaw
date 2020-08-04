//
//  TransformedLocus.swift
//  Macaw
//
//  Created by Yuri Strot on 5/21/18.
//

open class TransformedLocus: Locus {

    public let locus: Locus
    public let transform: Transform

    public init(locus: Locus, transform: Transform) {
        self.locus = locus
        self.transform = transform
    }

    open override func bounds() -> Rect {
        return locus.bounds().applying(transform)
    }

    override func equals<T>(other: T) -> Bool where T: Locus {
        guard let other = other as? TransformedLocus else {
            return false
        }
        return locus == other.locus
            && transform == other.transform
    }
}
