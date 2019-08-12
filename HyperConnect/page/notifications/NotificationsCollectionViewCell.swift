
import UIKit

class NotificationsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    var notification:Notification!
    let localRepository=LocalRepository.sharedInstance
    
    func bind(notification: Notification) {
        self.notification=notification
        messageLabel.text=notification.message
        dateTimeLabel.text=notification.dateTime
        deviceNameLabel.text=localRepository.getDeviceByUserId(userId: notification.deviceUserId!)!.name!
        
        initImages()
    }
    
    private func initImages() {
        if notification.type == NotificationType.SUCCESS.value {
            typeImage.image=UIImage(named: "imageDone")?.withRenderingMode(.alwaysTemplate)
            typeImage.tintColor=UIColor.init(named: "colorGreen")
        }
        else if notification.type == NotificationType.WARNING.value {
            typeImage.image=UIImage(named: "imageWarning")?.withRenderingMode(.alwaysTemplate)
            typeImage.tintColor=UIColor.init(named: "colorOrange")
        }
        else if notification.type == NotificationType.ERROR.value {
            typeImage.image=UIImage(named: "imageError")?.withRenderingMode(.alwaysTemplate)
            typeImage.tintColor=UIColor.init(named: "colorRed")
        }
        
        if notification.category == NotificationCategory.DEVICE.value {
            categoryImage.image=UIImage(named: "imageRouter")?.withRenderingMode(.alwaysTemplate)
        }
        else if notification.category == NotificationCategory.SENSOR.value {
            categoryImage.image=UIImage(named: "imageDeveloperBoard")?.withRenderingMode(.alwaysTemplate)
        }
        else if notification.category == NotificationCategory.ATTRIBUTE.value {
            categoryImage.image=UIImage(named: "imageMemory")?.withRenderingMode(.alwaysTemplate)
        }
        else if notification.category == NotificationCategory.EVENT.value {
            categoryImage.image=UIImage(named: "imageEvent")?.withRenderingMode(.alwaysTemplate)
        }
        categoryImage.tintColor=UIColor.init(named: "colorMetal")
    }
}
