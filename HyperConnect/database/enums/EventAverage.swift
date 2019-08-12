
public enum EventAverage : Int16 {
    case REAL_TIME = 0
    case ONE_MINUTE = 1
    case FIVE_MINUTES = 2
    case FIFTEEN_MINUTES = 3
    case ONE_HOUR = 4
    case THREE_HOURS = 5
    case SIX_HOURS = 6
    case ONE_DAY = 7
    
    
    internal static func stringFormat(_ average: EventAverage) -> String {
        var value : String
        
        switch average {
            case REAL_TIME:
                value = "Real-Time"
            case ONE_MINUTE:
                value = "1 Minute"
            case FIVE_MINUTES:
                value = "5 Minutes"
            case FIFTEEN_MINUTES:
                value = "15 Minutes"
            case ONE_HOUR:
                value = "1 Hour"
            case THREE_HOURS:
                value = "3 Hours"
            case SIX_HOURS:
                value = "6 Hours"
            case ONE_DAY:
                value = "1 Day"
            
        }
        return value
    }
    
    public var description: String {
        return EventAverage.stringFormat(self)
    }
    
    internal static func shortFilenameFormat(_ average: EventAverage) -> String {
        var value : String
        
        switch average {
        case REAL_TIME:
            value = ""
        case ONE_MINUTE:
            value = "1m"
        case FIVE_MINUTES:
            value = "5m"
        case FIFTEEN_MINUTES:
            value = "15m"
        case ONE_HOUR:
            value = "1h"
        case THREE_HOURS:
            value = "3h"
        case SIX_HOURS:
            value = "6h"
        case ONE_DAY:
            value = "1d"
            
        }
        return value
    }
    
    public var shortFilename: String {
        return EventAverage.shortFilenameFormat(self)
    }
    
    internal static func intFormat(_ average: EventAverage) -> Int16 {
        var value : Int16
        
        switch average {
            case REAL_TIME:
                value = 0
            case ONE_MINUTE:
                value = 1
            case FIVE_MINUTES:
                value = 2
            case FIFTEEN_MINUTES:
                value = 3
            case ONE_HOUR:
                value = 4
            case THREE_HOURS:
                value = 5
            case SIX_HOURS:
                value = 6
            case ONE_DAY:
                value = 7
        }
        return value
    }
    
    public var value: Int16 {
        return EventAverage.intFormat(self)
    }
}

internal func convertCEventAverageToEventAverage(_ cstatus: Int16) -> EventAverage {
    return EventAverage(rawValue: Int16(cstatus))!
}
