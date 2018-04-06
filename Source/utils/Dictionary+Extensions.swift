import UIKit

extension Dictionary where Value == XMLAttribute {
    func number(for key: Key) -> Double? {
        guard let value = self[key]?.text else {
            return nil
        }

        return Double(string: value)
    }

    func rect(for key: Key) -> Rect? {
        guard let value = self[key]?.text else {
            return nil
        }

        let components = value.components(separatedBy: " ")
        guard components.count == 4 else {
            return nil
        }

        return Rect(
            x: Double(string: components[0]),
            y: Double(string: components[1]),
            w: Double(string: components[2]),
            h: Double(string: components[3])
        )
    }
}
