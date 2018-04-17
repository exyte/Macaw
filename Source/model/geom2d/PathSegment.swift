import Foundation

open class PathSegment {

    open let type: PathSegmentType
    open let data: [Double]

    public init(type: PathSegmentType = .M, data: [Double] = []) {
        self.type = type
        self.data = data
    }

    // GENERATED NOT
    open func isAbsolute() -> Bool {
        switch type {
        case .M, .L, .H, .V, .C, .S, .Q, .T, .A, .E:
            return true
        default:
            return false
        }
    }
    
    internal func toDictionary() -> [String:Any] {
        return ["type": "\(type)", "data": data]
    }
    
    internal convenience init(dictionary: [String:Any]) {
        guard let typeString = dictionary["type"] as? String, let array = dictionary["data"] as? [Double] else { self.init(); return }
        
        self.init(type: typeForString(typeString),
                  data: array)
    }
}

fileprivate func typeForString(_ string: String) -> PathSegmentType {
    switch(string) {
    case "M": return .M
    case "m": return .m
    case "L": return .L
    case "l": return .l
    case "C": return .C
    case "c": return .c
    case "Q": return .Q
    case "q": return .q
    case "A": return .A
    case "a": return .a
    case "z", "Z": return .z
    case "H": return .H
    case "h": return .h
    case "V": return .V
    case "v": return .v
    case "S": return .S
    case "s": return .s
    case "T": return .T
    case "t": return .t
    default: return .M
    }
}
