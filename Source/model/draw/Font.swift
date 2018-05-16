open class Font {

    open let name: String
    open let size: Int
    open let weight: String

    public init(name: String = "Serif", size: Int = 12, weight: String = "normal") {
        self.name = name
        self.size = size
        self.weight = weight
    }
}
