
import UIKit
import CoreData
import SwiftyJSON
import MaterialComponents.MaterialSnackbar

class EventsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateSwitch: UISwitch!
    @IBOutlet weak var sourceDeviceLabel: UILabel!
    @IBOutlet weak var sourceAttributeLabel: UILabel!
    @IBOutlet weak var actionDeviceLabel: UILabel!
    @IBOutlet weak var actionAttributeLabel: UILabel!
    @IBOutlet weak var sourceDeviceImage: UIImageView!
    @IBOutlet weak var sourceAttributeImage: UIImageView!
    @IBOutlet weak var actionDeviceImage: UIImageView!
    @IBOutlet weak var actionAttributeImage: UIImageView!
    
    var eventsVC:EventsViewController!
    var event:Event!
    let elastosCarrier=ElastosCarrier.sharedInstance
    let localRepository=LocalRepository.sharedInstance
    var sourceDeviceResultsController:NSFetchedResultsController<Device>!
    var sourceAttributeResultsController:NSFetchedResultsController<Attribute>!
    var actionDeviceResultsController:NSFetchedResultsController<Device>!
    var actionAttributeResultsController:NSFetchedResultsController<Attribute>!
    var sourceDevice:Device!
    var sourceAttribute:Attribute!
    var actionDevice:Device!
    var actionAttribute:Attribute!
    
    func bind(eventsVC: EventsViewController, event: Event) {
        self.eventsVC=eventsVC
        self.event=event
        nameLabel.text=event.name
        
        initImages()
        initSourceDeviceResultsController()
        initSourceAttributeResultsController()
        initActionDeviceResultsController()
        initActionAttributeResultsController()
        setSourceDevice()
        setSourceAttribute()
        setActionDevice()
        setActionAttribute()
        
        sourceDeviceLabel.text=sourceDevice.name
        sourceAttributeLabel.text=sourceAttribute.name
        actionDeviceLabel.text=actionDevice.name
        actionAttributeLabel.text=actionAttribute.name
        
        if event.state == EventState.ACTIVE.value {
            stateLabel.text="Active"
            stateImage.tintColor=UIColor.init(named: "colorGreen")
            stateSwitch.isOn=true
        }
        else if event.state == EventState.DEACTIVATED.value {
            stateLabel.text="Deactivated"
            stateImage.tintColor=UIColor.init(named: "colorRed")
            stateSwitch.isOn=false
        }
    }
    
    private func initImages(){
        eventImage.image=UIImage(named: "imageEvent")?.withRenderingMode(.alwaysTemplate)
        eventImage.tintColor=UIColor.init(named: "colorMetal")
        stateImage.image=UIImage(named: "imageLens")?.withRenderingMode(.alwaysTemplate)
        sourceDeviceImage.image=UIImage(named: "imageRouter")?.withRenderingMode(.alwaysTemplate)
        sourceAttributeImage.image=UIImage(named: "imageMemory")?.withRenderingMode(.alwaysTemplate)
        actionDeviceImage.image=UIImage(named: "imageRouter")?.withRenderingMode(.alwaysTemplate)
        actionAttributeImage.image=UIImage(named: "imageMemory")?.withRenderingMode(.alwaysTemplate)
    }
    
    func initSourceDeviceResultsController() {
        let fetchRequest:NSFetchRequest<Device>=Device.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        let predicate=NSPredicate(format: "userId==%@", event.sourceDeviceUserId!)
        fetchRequest.predicate=predicate
        sourceDeviceResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: localRepository.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        sourceDeviceResultsController.delegate=self
        do{
            try sourceDeviceResultsController.performFetch()
        }
        catch{}
    }
    
    func initSourceAttributeResultsController() {
        let fetchRequest:NSFetchRequest<Attribute>=Attribute.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        let devicePredicate=NSPredicate(format: "device.userId==%@", event.sourceDeviceUserId!)
        let attributePredicate=NSPredicate(format: "edgeAttributeId==%i", event.sourceEdgeAttributeId)
        let andPredicate=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [devicePredicate, attributePredicate])
        fetchRequest.predicate=andPredicate
        sourceAttributeResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: localRepository.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        sourceAttributeResultsController.delegate=self
        do{
            try sourceAttributeResultsController.performFetch()
        }
        catch{}
    }
    
    func initActionDeviceResultsController() {
        let fetchRequest:NSFetchRequest<Device>=Device.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        let predicate=NSPredicate(format: "userId==%@", event.actionDeviceUserId!)
        fetchRequest.predicate=predicate
        actionDeviceResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: localRepository.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        actionDeviceResultsController.delegate=self
        do{
            try actionDeviceResultsController.performFetch()
        }
        catch{}
    }
    
    func initActionAttributeResultsController() {
        let fetchRequest:NSFetchRequest<Attribute>=Attribute.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        let devicePredicate=NSPredicate(format: "device.userId==%@", event.actionDeviceUserId!)
        let attributePredicate=NSPredicate(format: "edgeAttributeId==%i", event.actionEdgeAttributeId)
        let andPredicate=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [devicePredicate, attributePredicate])
        fetchRequest.predicate=andPredicate
        actionAttributeResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: localRepository.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        actionAttributeResultsController.delegate=self
        do{
            try actionAttributeResultsController.performFetch()
        }
        catch{}
    }
    
    func setSourceDevice() {
        sourceDevice=sourceDeviceResultsController.fetchedObjects![0]
        if sourceDevice.connectionState == DeviceConnectionState.ONLINE.value {
            sourceDeviceImage.tintColor=UIColor.init(named: "colorGreen")
        }
        else if sourceDevice.connectionState == DeviceConnectionState.OFFLINE.value {
            sourceDeviceImage.tintColor=UIColor.init(named: "colorRed")
        }
    }
    
    func setSourceAttribute() {
        sourceAttribute=sourceAttributeResultsController.fetchedObjects![0]
        if sourceAttribute.state == AttributeState.ACTIVE.value {
            sourceAttributeImage.tintColor=UIColor.init(named: "colorGreen")
        }
        else if sourceAttribute.state == AttributeState.DEACTIVATED.value {
            sourceAttributeImage.tintColor=UIColor.init(named: "colorRed")
        }
    }
    
    func setActionDevice() {
        actionDevice=actionDeviceResultsController.fetchedObjects![0]
        if actionDevice.connectionState == DeviceConnectionState.ONLINE.value {
            actionDeviceImage.tintColor=UIColor.init(named: "colorGreen")
        }
        else if actionDevice.connectionState == DeviceConnectionState.OFFLINE.value {
            actionDeviceImage.tintColor=UIColor.init(named: "colorRed")
        }
    }
    
    func setActionAttribute() {
        actionAttribute=actionAttributeResultsController.fetchedObjects![0]
        if actionAttribute.state == AttributeState.ACTIVE.value {
            actionAttributeImage.tintColor=UIColor.init(named: "colorGreen")
        }
        else if actionAttribute.state == AttributeState.DEACTIVATED.value {
            actionAttributeImage.tintColor=UIColor.init(named: "colorRed")
        }
    }
    
    @IBAction func onDetailsButton(_ sender: UIButton) {
        let dialog=UIStoryboard(name: "Dialog", bundle: nil).instantiateViewController(withIdentifier: "dialogEventDetails") as! DialogEventDetailsViewController
        dialog.view.backgroundColor=UIColor.black.withAlphaComponent(0.6)
        dialog.view.center=eventsVC.view.center
        dialog.bind(event: event)
        eventsVC.addChild(dialog)
        eventsVC.view.addSubview(dialog.view)
    }
    
    @IBAction func onStateSwitch(_ sender: UISwitch) {
        var canContinue=false
        if sourceDevice.connectionState == DeviceConnectionState.OFFLINE.value && actionDevice.connectionState == DeviceConnectionState.OFFLINE.value {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "The source and action devices for this event must be online."))
        }
        else if sourceDevice.connectionState == DeviceConnectionState.OFFLINE.value {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "The source device for this event must be online."))
        }
        else if actionDevice.connectionState == DeviceConnectionState.OFFLINE.value {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "The action device for this event must be online."))
        }
        else if sourceAttribute.state == AttributeState.DEACTIVATED.value && actionAttribute.state == AttributeState.DEACTIVATED.value {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "The source and action attributes for this event must be activated."))
        }
        else if sourceAttribute.state == AttributeState.DEACTIVATED.value {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "The source attribute for this event must be activated."))
        }
        else if actionAttribute.state == AttributeState.DEACTIVATED.value {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "The action attribute for this event must be activated."))
        }
        else {
            canContinue=true
        }
        
        if canContinue {
            var jsonObject:JSON=[
                "command": "changeEventState",
                "globalEventId": event.globalEventId!,
                "state": stateSwitch.isOn
            ]
            
            if sourceDevice.connectionState == DeviceConnectionState.ONLINE.value && actionDevice.connectionState == DeviceConnectionState.ONLINE.value {
                var sourceMessageCheck=true
                var actionMessageCheck=true
                if event.type == EventType.LOCAL.value {
                    let mergeJsonObject:JSON=["edgeType": EventEdgeType.SOURCE_AND_ACTION.value]
                    do {
                        jsonObject = try jsonObject.merged(with: mergeJsonObject)
                        sourceMessageCheck=elastosCarrier.sendFriendMessageWithResponse(userId: event.sourceDeviceUserId!, message: jsonObject.description)
                    }
                    catch{}
                }
                else if event.type == EventType.GLOBAL.value {
                    let mergeSourceJsonObject:JSON=["edgeType": EventEdgeType.SOURCE.value]
                    let mergeActionJsonObject:JSON=["edgeType": EventEdgeType.ACTION.value]
                    do {
                        jsonObject = try jsonObject.merged(with: mergeSourceJsonObject)
                        sourceMessageCheck=elastosCarrier.sendFriendMessageWithResponse(userId: event.sourceDeviceUserId!, message: jsonObject.description)
                        jsonObject = try jsonObject.merged(with: mergeActionJsonObject)
                        actionMessageCheck=elastosCarrier.sendFriendMessageWithResponse(userId: event.actionDeviceUserId!, message: jsonObject.description)
                    }
                    catch{}
                }
                
                if sourceMessageCheck && actionMessageCheck {
                    if stateSwitch.isOn {
                        setSwitch(state: true)
                    }
                    else {
                        setSwitch(state: false)
                    }
                    localRepository.updateDatabase()
                    MDCSnackbarManager.show(MDCSnackbarMessage(text: "Event state has been changed."))
                }
                else {
                    MDCSnackbarManager.show(MDCSnackbarMessage(text: "Sorry, something went wrong."))
                }
            }
            else {
                MDCSnackbarManager.show(MDCSnackbarMessage(text: "The source and action devices for this event must be online."))
            }
        }
        else {
            setSwitch(state: !stateSwitch.isOn)
        }
        
    }
    
    private func setSwitch(state: Bool) {
        DispatchQueue.main.async {
            self.stateSwitch.setOn(state, animated: false)
        }
    }
}


extension EventsCollectionViewCell: NSFetchedResultsControllerDelegate{
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if controller == sourceDeviceResultsController {
            setSourceDevice()
        }
        else if controller == sourceAttributeResultsController {
            setSourceAttribute()
        }
        else if controller == actionDeviceResultsController {
            setActionDevice()
        }
        else if controller == actionAttributeResultsController {
            setActionAttribute()
        }
    }
}
