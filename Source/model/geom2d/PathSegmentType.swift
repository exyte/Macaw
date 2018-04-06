public enum PathSegmentType: String {
    case M = "M"
    case L = "L"
    case C = "C"
    case Q = "Q"
    case A = "A"
    case z = "z"
    case H = "H"
    case V = "V"
    case S = "S"
    case T = "T"
    case m = "m"
    case l = "l"
    case c = "c"
    case q = "q"
    case a = "a"
    case h = "h"
    case v = "v"
    case s = "s"
    case t = "t"
    case E = "E"
    case e = "e"

    init?(c: Unicode.Scalar) {
        switch c {
        case "z", "Z":
            self = .z
        default:
            self.init(rawValue: String(c))
        }
    }
}
