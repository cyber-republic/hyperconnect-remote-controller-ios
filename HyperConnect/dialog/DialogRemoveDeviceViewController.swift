
import UIKit
import SwiftyJSON
import MaterialComponents.MaterialSnackbar

class DialogRemoveDeviceViewController: UIViewController {
    
    var device:Device!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewTap()
    }
    
    func bind(device: Device) {
        self.device=device
    }
    
    private func initViewTap() {
        let tap=UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tap.numberOfTapsRequired=1
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        closeDialog()
    }
    
    private func closeDialog() {
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    @IBAction func onCancelButton(_ sender: UIButton) {
        closeDialog()
    }
    
    @IBAction func onConfirmButton(_ sender: UIButton) {
        closeDialog()
        
        let elastosCarrier=ElastosCarrier.sharedInstance
        let localRepository=LocalRepository.sharedInstance
        
        let jsonObject:JSON=[
            "command": "removeMe"
        ]
        elastosCarrier.sendFriendMessage(userId: device.userId!, message: jsonObject.description)
        
        let removeCheck=elastosCarrier.removeFriend(userId: device.userId!)
        if removeCheck {
            localRepository.deleteDevice(device: device)
            localRepository.updateDatabase()
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Device has been removed."))
        }
        else {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Sorry, something went wrong."))
        }
        
    }
    
    
}
