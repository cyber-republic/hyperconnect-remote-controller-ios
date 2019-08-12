
import Foundation

class HistoryDataRecord {
    var dateTime:String!
    var value:String!
    
    init(dateTime: String, value: String) {
        self.dateTime=dateTime
        self.value=value
    }
    
    func getDateTime() -> String {
        return dateTime
    }
    
    func getValue() -> String {
        return value
    }
}
