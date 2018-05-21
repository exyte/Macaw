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
}
