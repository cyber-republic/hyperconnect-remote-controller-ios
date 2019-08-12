
public enum NotificationCategory : Int16 {
    case DEVICE = 0
    case SENSOR = 1
    case ATTRIBUTE = 2
    case EVENT = 3
    case SYSTEM = 4
    
    internal static func stringFormat(_ category: NotificationCategory) -> String {
        var value : String
        
        switch category {
            case DEVICE:
                value = "Device"
            case SENSOR:
                value = "Sensor"
            case ATTRIBUTE:
                value = "Attribute"
            case EVENT:
                value = "Event"
            case SYSTEM:
                value = "System"
        }
        return value
    }
    
    public var description: String {
        return NotificationCategory.stringFormat(self)
    }
    
    internal static func intFormat(_ category: NotificationCategory) -> Int16 {
        var value : Int16
        
        switch category {
            case DEVICE:
                value = 0
            case SENSOR:
                value = 1
            case ATTRIBUTE:
                value = 2
            case EVENT:
                value = 3
            case SYSTEM:
                value = 4
        }
        return value
    }
    
    public var value: Int16 {
        return NotificationCategory.intFormat(self)
    }
}

internal func convertCNotificationCategoryToNotificationCategory(_ cstatus: Int16) -> NotificationCategory {
    return NotificationCategory(rawValue: Int16(cstatus))!
}
