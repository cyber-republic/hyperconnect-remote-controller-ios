
public enum AttributeScriptState : Int16 {
    case VALID = 0
    case INVALID = 1
    
    internal static func stringFormat(_ state: AttributeScriptState) -> String {
        var value : String
        
        switch state {
            case VALID:
                value = "Valid"
            case INVALID:
                value = "Invalid"
        }
        return value
    }
    
    public var description: String {
        return AttributeScriptState.stringFormat(self)
    }
    
    internal static func intFormat(_ state: AttributeScriptState) -> Int16 {
        var value : Int16
        
        switch state {
            case VALID:
                value = 0
            case INVALID:
                value = 1
        }
        return value
    }
    
    public var value: Int16 {
        return AttributeScriptState.intFormat(self)
    }
}

internal func convertCAttributeScriptStateToAttributeScriptState(_ cstatus: Int16) -> AttributeScriptState {
    return AttributeScriptState(rawValue: Int16(cstatus))!
}
