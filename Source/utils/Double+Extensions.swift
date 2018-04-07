import UIKit

extension Double {
    init(string: String) {
        var number: Double = 0
        let scanner = Scanner(string: string)
        scanner.scanDouble(&number)
        self = number
    }
}
