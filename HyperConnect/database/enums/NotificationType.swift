
public enum NotificationType : Int16 {
    case SUCCESS = 0
    case WARNING = 1
    case ERROR = 2
    
    internal static func stringFormat(_ type: NotificationType) -> String {
        var value : String
        
        switch type {
        case SUCCESS:
            value = "Success"
        case WARNING:
            value = "Warning"
        case ERROR:
            value = "Error"
        }
        return value
    }
    
    public var description: String {
        return NotificationType.stringFormat(self)
    }
    
    internal static func intFormat(_ type: NotificationType) -> Int16 {
        var value : Int16
        
        switch type {
        case SUCCESS:
            value = 0
        case WARNING:
            value = 1
        case ERROR:
            value = 2
        }
        return value
    }
    
    public var value: Int16 {
        return NotificationType.intFormat(self)
    }
}

internal func convertCNotificationTypeToNotificationType(_ cstatus: Int16) -> NotificationType {
    return NotificationType(rawValue: Int16(cstatus))!
}
