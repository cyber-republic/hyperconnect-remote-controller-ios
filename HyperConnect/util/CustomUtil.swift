
import Foundation

class CustomUtil {
    static let sharedInstance=CustomUtil()
    
    func getRandomGlobalEventId() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<12).map{ _ in letters.randomElement()! })
    }
}
