
public enum AttributeType : Int16 {
    case STRING = 0
    case BOOLEAN = 1
    case INTEGER = 2
    case DOUBLE = 3
    
    internal static func stringFormat(_ type: AttributeType) -> String {
        var value : String
        
        switch type {
            case STRING:
                value = "String"
            case BOOLEAN:
                value = "Boolean"
            case INTEGER:
                value = "Integer"
            case DOUBLE:
                value = "Double"
        }
        return value
    }
    
    public var description: String {
        return AttributeType.stringFormat(self)
    }
    
    internal static func intFormat(_ type: AttributeType) -> Int16 {
        var value : Int16
        
        switch type {
            case STRING:
                value = 0
            case BOOLEAN:
                value = 1
            case INTEGER:
                value = 2
            case DOUBLE:
                value = 3
        }
        return value
    }
    
    public var value: Int16 {
        return AttributeType.intFormat(self)
    }
}

internal func convertCAttributeTypeToAttributeType(_ cstatus: Int16) -> AttributeType {
    return AttributeType(rawValue: Int16(cstatus))!
}
