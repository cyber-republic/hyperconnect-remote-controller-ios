
import UIKit

class PopoverDeviceActionsViewController: UIViewController {
    
    @IBOutlet weak var popoverView: UIView!
    @IBOutlet weak var arrowImage: UIImageView!
    
    var button:UIButton!
    var devicesVC:DevicesViewController!
    var device:Device!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPopoverPosition()
        initImageColor()
        initViewTap()
    }
    
    func bind(button: UIButton, devicesVC: DevicesViewController, device: Device) {
        self.button=button
        self.devicesVC=devicesVC
        self.device=device
    }
    
    private func initPopoverPosition() {
        let x=button.frame.origin.x-25
        let y=button.frame.origin.y+popoverView.frame.height-button.frame.height+12
        let width=popoverView.frame.width-button.frame.width
        let height=popoverView.frame.height
        popoverView.frame=CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func initImageColor() {
        let dropUpArrowImage=UIImage(named: "imageArrowDropUp")?.withRenderingMode(.alwaysTemplate)
        arrowImage.image=dropUpArrowImage
        arrowImage.tintColor=UIColor.init(named: "colorPrimary")
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
    
    @IBAction func onEditButton(_ sender: UIButton) {
        closeDialog()
        let dialog=UIStoryboard(name: "Dialog", bundle: nil).instantiateViewController(withIdentifier: "dialogEditDevice") as! DialogEditDeviceViewController
        dialog.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        dialog.view.center=devicesVC.view.center
        dialog.bind(device: device)
        devicesVC.addChild(dialog)
        devicesVC.view.addSubview(dialog.view)
    }
    
    @IBAction func onRemoveButton(_ sender: UIButton) {
        closeDialog()
        let dialog=UIStoryboard(name: "Dialog", bundle: nil).instantiateViewController(withIdentifier: "dialogRemoveDevice") as! DialogRemoveDeviceViewController
        dialog.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        dialog.view.center=devicesVC.view.center
        dialog.bind(device: device)
        devicesVC.addChild(dialog)
        devicesVC.view.addSubview(dialog.view)
    }
    
}
