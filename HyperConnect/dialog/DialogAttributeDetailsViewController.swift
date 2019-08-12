
import UIKit

class DialogAttributeDetailsViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var scriptStateLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewTap()
    }
    
    func bind(attribute: Attribute) {
        nameLabel.text=attribute.name
        directionLabel.text=AttributeDirection.init(rawValue: attribute.direction)?.description
        typeLabel.text=AttributeType.init(rawValue: attribute.type)?.description
        intervalLabel.text=String(attribute.interval)+" seconds"
        scriptStateLabel.text=AttributeScriptState.init(rawValue: attribute.scriptState)?.description
        stateLabel.text=AttributeState.init(rawValue: attribute.state)?.description
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
    
    @IBAction func onCloseButton(_ sender: UIButton) {
        closeDialog()
    }
    
}
