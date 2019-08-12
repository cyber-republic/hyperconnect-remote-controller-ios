
public enum AttributeDirection : Int16 {
    case INPUT = 0
    case OUTPUT = 1
    
    internal static func stringFormat(_ direction: AttributeDirection) -> String {
        var value : String
        
        switch direction {
            case INPUT:
                value = "Input"
            case OUTPUT:
                value = "Output"
        }
        return value
    }
    
    public var description: String {
        return AttributeDirection.stringFormat(self)
    }
    
    internal static func intFormat(_ direction: AttributeDirection) -> Int16 {
        var value : Int16
        
        switch direction {
            case INPUT:
                value = 0
            case OUTPUT:
                value = 1
        }
        return value
    }
    
    public var value: Int16 {
        return AttributeDirection.intFormat(self)
    }
}

internal func convertCAttributeDirectionToAttributeDirection(_ cstatus: Int16) -> AttributeDirection {
    return AttributeDirection(rawValue: Int16(cstatus))!
}
