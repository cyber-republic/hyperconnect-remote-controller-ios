
import UIKit
import CoreData

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var carrierStateImage: UIImageView!
    @IBOutlet weak var carrierStateLabel: UILabel!
    @IBOutlet weak var onlineDeviceCountLabel: UILabel!
    @IBOutlet weak var deviceCountLabel: UILabel!
    @IBOutlet weak var activeAttributeCountLabel: UILabel!
    @IBOutlet weak var attributeCountLabel: UILabel!
    @IBOutlet weak var activeEventCountLabel: UILabel!
    @IBOutlet weak var eventCountLabel: UILabel!
    
    
    let localRepository=LocalRepository.sharedInstance
    var deviceResultsController:NSFetchedResultsController<Device>!
    var onlineDeviceResultsController:NSFetchedResultsController<Device>!
    var activeAttributeResultsController:NSFetchedResultsController<Attribute>!
    var attributeResultsController:NSFetchedResultsController<Attribute>!
    var activeEventResultsController:NSFetchedResultsController<Event>!
    var eventResultsController:NSFetchedResultsController<Event>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCarrierConnectionState(false)
        localRepository.dashboardVC=self
        
        initOnlineDeviceResultsController()
        initDeviceResultsController()
        initActiveAttributeResultsController()
        initAttributeResultsController()
        initActiveEventResultsController()
        initEventResultsController()
        
        setOnlineDeviceCount()
        setDeviceCount()
        setActiveAttributeCount()
        setAttributeCount()
        setActiveEventCount()
        setEventCount()
    }
    
    func setCarrierConnectionState(_ state: Bool) {
        DispatchQueue.main.async {
            let deviceHubImage=UIImage(named: "imageDeviceHub")?.withRenderingMode(.alwaysTemplate)
            self.carrierStateImage.image=deviceHubImage
            if state {
                self.carrierStateImage.tintColor=UIColor.init(named: "colorGreen")
                self.carrierStateLabel.text="Connected"
                self.carrierStateLabel.textColor=UIColor.init(named: "colorGreen")
            }
            else {
                self.carrierStateImage.tintColor=UIColor.init(named: "colorRed")
                self.carrierStateLabel.text="Disconnected"
                self.carrierStateLabel.textColor=UIColor.init(named: "colorRed")
            }
        }
    }
    
    func initOnlineDeviceResultsController() {
        let fetchRequest:NSFetchRequest<Device>=Device.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        let predicate=NSPredicate(format: "connectionState==%i", DeviceConnectionState.ONLINE.value)
        fetchRequest.predicate=predicate
        onlineDeviceResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: localRepository.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        onlineDeviceResultsController.delegate=self
        do{
            try onlineDeviceResultsController.performFetch()
        }
        catch{}
    }
    
    func initDeviceResultsController() {
        let fetchRequest:NSFetchRequest<Device>=Device.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        deviceResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: localRepository.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        deviceResultsController.delegate=self
        do{
            try deviceResultsController.performFetch()
        }
        catch{}
    }
    
    func initActiveAttributeResultsController() {
        let fetchRequest:NSFetchRequest<Attribute>=Attribute.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        let predicate=NSPredicate(format: "state==%i", AttributeState.ACTIVE.value)
        fetchRequest.predicate=predicate
        activeAttributeResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: localRepository.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        activeAttributeResultsController.delegate=self
        do{
            try activeAttributeResultsController.performFetch()
        }
        catch{}
    }

    func initAttributeResultsController() {
        let fetchRequest:NSFetchRequest<Attribute>=Attribute.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        attributeResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: localRepository.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        attributeResultsController.delegate=self
        do{
            try attributeResultsController.performFetch()
        }
        catch{}
    }
    
    func initActiveEventResultsController() {
        let fetchRequest:NSFetchRequest<Event>=Event.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        let predicate=NSPredicate(format: "state==%i", EventState.ACTIVE.value)
        fetchRequest.predicate=predicate
        activeEventResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: localRepository.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        activeEventResultsController.delegate=self
        do{
            try activeEventResultsController.performFetch()
        }
        catch{}
    }
    
    func initEventResultsController() {
        let fetchRequest:NSFetchRequest<Event>=Event.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        eventResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: localRepository.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        eventResultsController.delegate=self
        do{
            try eventResultsController.performFetch()
        }
        catch{}
    }
    
    func setOnlineDeviceCount() {
        onlineDeviceCountLabel.text=String(onlineDeviceResultsController.sections?[0].numberOfObjects ?? 0)
    }
    
    func setDeviceCount() {
        deviceCountLabel.text=String(deviceResultsController.sections?[0].numberOfObjects ?? 0)
    }
    
    func setActiveAttributeCount() {
        activeAttributeCountLabel.text=String(activeAttributeResultsController.sections?[0].numberOfObjects ?? 0)
    }
    
    func setAttributeCount() {
        attributeCountLabel.text=String(attributeResultsController.sections?[0].numberOfObjects ?? 0)
    }
    
    func setActiveEventCount() {
        activeEventCountLabel.text=String(activeEventResultsController.sections?[0].numberOfObjects ?? 0)
    }
    
    func setEventCount() {
        eventCountLabel.text=String(eventResultsController.sections?[0].numberOfObjects ?? 0)
    }
}


extension DashboardViewController: NSFetchedResultsControllerDelegate{
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if controller == onlineDeviceResultsController {
            setOnlineDeviceCount()
        }
        else if controller == deviceResultsController {
            setDeviceCount()
        }
        else if controller == activeAttributeResultsController {
            setActiveAttributeCount()
        }
        else if controller == attributeResultsController {
            setAttributeCount()
        }
        else if controller == activeEventResultsController {
            setActiveEventCount()
        }
        else if controller == eventResultsController {
            setEventCount()
        }
    }
}
