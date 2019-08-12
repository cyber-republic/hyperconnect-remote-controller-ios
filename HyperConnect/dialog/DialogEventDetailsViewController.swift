
import UIKit

class DialogEventDetailsViewController: UIViewController {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var conditionValueLabel: UILabel!
    @IBOutlet weak var triggerValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewTap()
    }
    
    func bind(event: Event) {
        typeLabel.text=EventType.init(rawValue: event.type)?.description
        averageLabel.text=EventAverage.init(rawValue: event.average)?.description
        conditionLabel.text=EventCondition.init(rawValue: event.condition)?.description
        conditionValueLabel.text=event.conditionValue
        triggerValueLabel.text=event.triggerValue
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
