
public enum DeviceConnectionState : Int16 {
    case ONLINE = 0
    case OFFLINE = 1
    
    internal static func stringFormat(_ state: DeviceConnectionState) -> String {
        var value : String
        
        switch state {
            case ONLINE:
                value = "Online"
            case OFFLINE:
                value = "Offline"
        }
        return value
    }
    
    public var description: String {
        return DeviceConnectionState.stringFormat(self)
    }
    
    internal static func intFormat(_ state: DeviceConnectionState) -> Int16 {
        var value : Int16
        
        switch state {
            case ONLINE:
                value = 0
            case OFFLINE:
                value = 1
        }
        return value
    }
    
    public var value: Int16 {
        return DeviceConnectionState.intFormat(self)
    }
}

internal func convertCDeviceConnectionStateToDeviceConnectionState(_ cstatus: Int16) -> DeviceConnectionState {
    return DeviceConnectionState(rawValue: Int16(cstatus))!
}
