import Foundation

open class Font {

    open let name: String
    open let size: Int
    open let weight: String

    public init(name: String = "Serif", size: Int = 12, weight: String = "normal") {
        self.name = name
        self.size = size
        self.weight = weight
    }
    
    internal func toDictionary() -> [String:Any] {
        return ["name": name, "size": size, "weight": weight]
    }
    
    internal convenience init(dictionary: [String:Any]) {
        self.init(name: dictionary["name"] as? String ?? "Serif",
                  size: parse(dictionary["size"]),
                  weight: dictionary["weight"] as? String ?? "normal")
    }
}
