
public enum EventState : Int16 {
    case ACTIVE = 0
    case DEACTIVATED = 1
    
    internal static func stringFormat(_ state: EventState) -> String {
        var value : String
        
        switch state {
            case ACTIVE:
                value = "Active"
            case DEACTIVATED:
                value = "Deactivated"
        }
        return value
    }
    
    public var description: String {
        return EventState.stringFormat(self)
    }
    
    internal static func intFormat(_ state: EventState) -> Int16 {
        var value : Int16
        
        switch state {
            case ACTIVE:
                value = 0
            case DEACTIVATED:
                value = 1
        }
        return value
    }
    
    public var value: Int16 {
        return EventState.intFormat(self)
    }
}

internal func convertCEventStateToEventState(_ cstatus: Int16) -> EventState {
    return EventState(rawValue: Int16(cstatus))!
}
