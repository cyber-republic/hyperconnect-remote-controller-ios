
public enum EventType : Int16 {
    case LOCAL = 0
    case GLOBAL = 1
    
    internal static func stringFormat(_ type: EventType) -> String {
        var value : String
        
        switch type {
            case LOCAL:
                value = "Local"
            case GLOBAL:
                value = "Global"
        }
        return value
    }
    
    public var description: String {
        return EventType.stringFormat(self)
    }
    
    internal static func intFormat(_ type: EventType) -> Int16 {
        var value : Int16
        
        switch type {
            case LOCAL:
                value = 0
            case GLOBAL:
                value = 1
        }
        return value
    }
    
    public var value: Int16 {
        return EventType.intFormat(self)
    }
}

internal func convertCEventTypeToEventType(_ cstatus: Int16) -> EventType {
    return EventType(rawValue: Int16(cstatus))!
}
