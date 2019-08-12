
import UIKit
import MaterialComponents.MaterialSnackbar

class DialogEditDeviceViewController: UIViewController {
    
    @IBOutlet weak var deviceNameInput: UITextField!
    
    var device:Device!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewTap()
        deviceNameInput.delegate=self
    }
    
    func bind(device: Device) {
        self.device=device
        deviceNameInput.text=device.name
    }
    
    private func initViewTap() {
        let tap=UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tap.numberOfTapsRequired=1
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        closeDialog()
        hideKeyboard()
    }
    
    private func closeDialog() {
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    @IBAction func onCancelButton(_ sender: UIButton) {
        closeDialog()
    }
    
    @IBAction func onUpdateButton(_ sender: UIButton) {
        let deviceName=deviceNameInput.text!
        if deviceName.isEmpty {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Device Name is empty."))
        }
        else {
            closeDialog()
            device.name=deviceName
            LocalRepository.sharedInstance.updateDatabase()
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Device has been updated."))
        }
    }
}


extension DialogEditDeviceViewController: UITextFieldDelegate {
    
    fileprivate func hideKeyboard() {
        deviceNameInput.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}
