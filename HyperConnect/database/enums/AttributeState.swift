
public enum AttributeState : Int16 {
    case ACTIVE = 0
    case DEACTIVATED = 1
    
    internal static func stringFormat(_ state: AttributeState) -> String {
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
        return AttributeState.stringFormat(self)
    }
    
    internal static func intFormat(_ state: AttributeState) -> Int16 {
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
        return AttributeState.intFormat(self)
    }
}

internal func convertCAttributeStateToAttributeState(_ cstatus: Int16) -> AttributeState {
    return AttributeState(rawValue: Int16(cstatus))!
}
