
public enum EventEdgeType : Int16 {
    case SOURCE = 0
    case ACTION = 1
    case SOURCE_AND_ACTION = 2
    
    internal static func stringFormat(_ type: EventEdgeType) -> String {
        var value : String
        
        switch type {
            case SOURCE:
                value = "Source"
            case ACTION:
                value = "Action"
            case SOURCE_AND_ACTION:
                value = "Source and Action"
        }
        return value
    }
    
    public var description: String {
        return EventEdgeType.stringFormat(self)
    }
    
    internal static func intFormat(_ type: EventEdgeType) -> Int16 {
        var value : Int16
        
        switch type {
            case SOURCE:
                value = 0
            case ACTION:
                value = 1
            case SOURCE_AND_ACTION:
                value = 2
        }
        return value
    }
    
    public var value: Int16 {
        return EventEdgeType.intFormat(self)
    }
}

internal func convertCEventEdgeTypeToEventEdgeType(_ cstatus: Int16) -> EventEdgeType {
    return EventEdgeType(rawValue: Int16(cstatus))!
}
