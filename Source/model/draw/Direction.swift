import Foundation

public enum Direction {
    case lre
    case rle
    case lro
    case rlo
}

extension Direction {

    var attributedStringValue: NSArray {
        switch self {
        case .lre:
            return [NSNumber(value: 0)]
        case .rle:
            return [NSNumber(value: 1)]
        case .lro:
            return [NSNumber(value: 2)]
        case .rlo:
            return [NSNumber(value: 3)]
        }
    }

    static func from(direction: String?, unicodebidi: String?) -> Direction {
        let direction = direction ?? "ltr"
        let unicodebidi = unicodebidi ?? "normal"

        switch (direction, unicodebidi) {
        case ("ltr", "bidi-override"):
            return .lro
        case ("rtl", "bidi-override"):
            return .rlo
        case ("rtl", "normal"):
            return .rle
        default:
            return .lre
        }
    }
}
