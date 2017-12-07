public enum Baseline {
    /// The text will be placed at its top
    case top
    /// The text will be placed at the bottom of the characters (expect those like "g", "y", the descending characters)
    case alphabetic
    /// The text will be placed at its bottom
    case bottom
    /// The text will be placed in the middle
    case mid
    /// The text will be placed at its top (but without any additional space coming from the font)
    case perfectTop
    /// The text will be placed at the bottom of the characters (expect those like "g", "y", the descending characters) (but without any additional space coming from the font)
    case perfectAlphabetic
    /// The text will be placed in the middle (but without any additional space coming from the font)
    case perfectMid
}
