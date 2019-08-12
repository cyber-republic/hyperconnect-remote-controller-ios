
public enum EventCondition : Int16 {
    case EQUAL_TO = 0
    case NOT_EQUAL_TO = 1
    case GREATER_THAN = 2
    case LESS_THAN = 3
    
    internal static func stringFormat(_ condition: EventCondition) -> String {
        var value : String
        
        switch condition {
            case EQUAL_TO:
                value = "equal to"
            case NOT_EQUAL_TO:
                value = "not equal to"
            case GREATER_THAN:
                value = "greater than"
            case LESS_THAN:
                value = "less than"
        }
        return value
    }
    
    public var description: String {
        return EventCondition.stringFormat(self)
    }
    
    internal static func intFormat(_ condition: EventCondition) -> Int16 {
        var value : Int16
        
        switch condition {
            case EQUAL_TO:
                value = 0
            case NOT_EQUAL_TO:
                value = 1
            case GREATER_THAN:
                value = 2
            case LESS_THAN:
                value = 3
        }
        return value
    }
    
    public var value: Int16 {
        return EventCondition.intFormat(self)
    }
}

internal func convertCEventConditionToEventCondition(_ cstatus: Int16) -> EventCondition {
    return EventCondition(rawValue: Int16(cstatus))!
}
