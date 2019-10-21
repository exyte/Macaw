open class Font {

    public let name: String
    public let size: Int
    public let weight: String

    public init(name: String = "Serif", size: Int = 12, weight: String = "normal") {
        self.name = name
        self.size = size
        self.weight = weight
    }
}
