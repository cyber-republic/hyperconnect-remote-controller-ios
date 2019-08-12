
public enum DeviceState : Int16 {
    case ACTIVE = 0
    case PENDING = 1
    case DEACTIVATED = 2
    
    internal static func stringFormat(_ state: DeviceState) -> String {
        var value : String
        
        switch state {
            case ACTIVE:
                value = "Active"
            case PENDING:
                value = "Pending"
            case DEACTIVATED:
                value = "Deactivated"
        }
        return value
    }
    
    public var description: String {
        return DeviceState.stringFormat(self)
    }
    
    internal static func intFormat(_ state: DeviceState) -> Int16 {
        var value : Int16
        
        switch state {
            case ACTIVE:
                value = 0
            case PENDING:
                value = 1
            case DEACTIVATED:
                value = 2
        }
        return value
    }
    
    public var value: Int16 {
        return DeviceState.intFormat(self)
    }
}

internal func convertCDeviceStateToDeviceState(_ cstatus: Int16) -> DeviceState {
    return DeviceState(rawValue: Int16(cstatus))!
}
