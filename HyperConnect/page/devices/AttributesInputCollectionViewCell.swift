
import UIKit
import CoreData
import SwiftyJSON
import MaterialComponents.MaterialSnackbar

class AttributesInputCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var attributeImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateSwitch: UISwitch!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var categoryPlaceholder: UIView!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    var attribute:Attribute!
    var sensorsVC:SensorsViewController!
    let elastosCarrier=ElastosCarrier.sharedInstance
    let localRepository=LocalRepository.sharedInstance
    let attributeManagement=AttributeManagement.sharedInstance
    var categoryRecordResultsController:NSFetchedResultsController<CategoryRecord>!
    var dataRecordResultsController:NSFetchedResultsController<DataRecord>!
    
    func bind(attribute: Attribute, sensorsVC: SensorsViewController) {
        self.attribute=attribute
        self.sensorsVC=sensorsVC
        
        if attribute.device!.state == DeviceState.ACTIVE.value && attribute.device!.connectionState == DeviceConnectionState.ONLINE.value && attribute.state == AttributeState.ACTIVE.value {
            if !attributeManagement.isAttributeRunning(attribute: attribute) {
                attributeManagement.startAttribute(deviceUserId: attribute.device!.userId!, attribute: attribute)
            }
        }
        
        nameLabel.text=attribute.name
        
        initCategoryRecordResultsController()
        categoriesCollectionView.delegate=self
        categoriesCollectionView.dataSource=self
        initPlaceholder()
        categoriesCollectionView.reloadData()
        
        initDataRecordResultsController()
        setDataRecord()
        
        initImages()
        
        if attribute.state == AttributeState.ACTIVE.value {
            stateLabel.text="Active"
            stateImage.tintColor=UIColor.init(named: "colorGreen")
            stateSwitch.isOn=true
        }
        else if attribute.state == AttributeState.DEACTIVATED.value {
            stateLabel.text="Deactivated"
            stateImage.tintColor=UIColor.init(named: "colorRed")
            stateSwitch.isOn=false
        }
        
        if attribute.type == AttributeType.STRING.value || attribute.type == AttributeType.BOOLEAN.value {
            historyButton.isHidden=true
        }
        else {
            historyButton.isHidden=false
        }
    }
    
    public func initPlaceholder() {
        if categoryRecordResultsController.sections?[0].numberOfObjects ?? 0 == 0 {
            categoriesCollectionView.isHidden=true
            categoryPlaceholder.isHidden=false
        }
        else {
            categoriesCollectionView.isHidden=false
            categoryPlaceholder.isHidden=true
        }
    }
    
    func initCategoryRecordResultsController() {
        let fetchRequest:NSFetchRequest<CategoryRecord>=CategoryRecord.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "category.name", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        let attributePredicate=NSPredicate(format: "attribute.edgeAttributeId==%i", attribute.edgeAttributeId)
        let devicePredicate=NSPredicate(format: "deviceUserId=%@", attribute.device!.userId!)
        let andPredicate=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [attributePredicate, devicePredicate])
        fetchRequest.predicate=andPredicate
        categoryRecordResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: LocalRepository.sharedInstance.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        categoryRecordResultsController.delegate=self
        do{
            try categoryRecordResultsController.performFetch()
        }
        catch{}
    }
    
    func initDataRecordResultsController() {
        let fetchRequest:NSFetchRequest<DataRecord>=DataRecord.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "dateTime", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        let devicePredicate=NSPredicate(format: "deviceUserId=%@", attribute.device!.userId!)
        let attributePredicate=NSPredicate(format: "edgeAttributeId==%i", attribute.edgeAttributeId)
        let andPredicate=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [devicePredicate, attributePredicate])
        fetchRequest.predicate=andPredicate
        dataRecordResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: localRepository.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataRecordResultsController.delegate=self
        do{
            try dataRecordResultsController.performFetch()
        }
        catch{}
    }
    
    public func setDataRecord() {
        let dataRecordList=dataRecordResultsController.fetchedObjects! as [DataRecord]
        if dataRecordList.count > 0 {
            let dataRecord=dataRecordList[0]
            valueLabel.text=dataRecord.value
            dateTimeLabel.text=dataRecord.dateTime
        }
        else {
            valueLabel.text="No Value"
            dateTimeLabel.text="No Value"
        }
    }
    
    private func initImages() {
        stateImage.image=UIImage(named: "imageLens")?.withRenderingMode(.alwaysTemplate)
        attributeImage.image=UIImage(named: "imageMemory")?.withRenderingMode(.alwaysTemplate)
        attributeImage.tintColor=UIColor.init(named: "colorMetal")
        addCategoryButton.imageView?.image=UIImage(named: "imageCategory")?.withRenderingMode(.alwaysTemplate)
        addCategoryButton.imageView?.tintColor=UIColor.init(named: "colorMetal")
    }
    
    private func setSwitch(state: Bool) {
        DispatchQueue.main.async {
            self.stateSwitch.setOn(state, animated: false)
        }
    }
    
    @IBAction func onStateSwitch(_ sender: UISwitch) {
        let device=attribute.device!
        if device.connectionState == DeviceConnectionState.ONLINE.value {
            if attribute.scriptState == AttributeScriptState.VALID.value {
                let jsonObject:JSON=[
                    "command": "changeAttributeState",
                    "id": attribute.edgeAttributeId,
                    "state": stateSwitch.isOn
                ]
                let sendCheck=elastosCarrier.sendFriendMessageWithResponse(userId: device.userId!, message: jsonObject.description)
                if sendCheck {
                    if stateSwitch.isOn {
                        attribute.state=AttributeState.ACTIVE.value
                    }
                    else {
                        attribute.state=AttributeState.DEACTIVATED.value
                        attributeManagement.stopAttribute(attribute: attribute)
                    }
                    localRepository.updateDatabase()
                    MDCSnackbarManager.show(MDCSnackbarMessage(text: "Attribute state has been changed."))
                }
                else {
                    MDCSnackbarManager.show(MDCSnackbarMessage(text: "Sorry, something went wrong."))
                }
            }
            else {
                setSwitch(state: false)
                MDCSnackbarManager.show(MDCSnackbarMessage(text: "Script state must be valid."))
            }
        }
        else {
            setSwitch(state: !stateSwitch.isOn)
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Device is offline."))
        }
    }
    
    @IBAction func onDetailsButton(_ sender: UIButton) {
        let dialog=UIStoryboard(name: "Dialog", bundle: nil).instantiateViewController(withIdentifier: "dialogAttributeDetails") as! DialogAttributeDetailsViewController
        dialog.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        dialog.bind(attribute: attribute)
        sensorsVC.addChild(dialog)
        sensorsVC.view.addSubview(dialog.view)
    }
    
    @IBAction func onHistoryButton(_ sender: UIButton) {
        attributeManagement.stopAttribute(attribute: attribute)
        sensorsVC.performSegue(withIdentifier: "actionHistory", sender: attribute)
    }
    
    @IBAction func onAddCategoryButton(_ sender: UIButton) {
        let dialog=UIStoryboard(name: "Dialog", bundle: nil).instantiateViewController(withIdentifier: "dialogAddCategory") as! DialogAddCategoryViewController
        dialog.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        dialog.bind(attribute: attribute)
        sensorsVC.addChild(dialog)
        sensorsVC.view.addSubview(dialog.view)
    }
}


extension AttributesInputCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryRecordResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categoryRecord=categoryRecordResultsController.object(at: indexPath)
        let cell=categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoriesInputCollectionViewCell
        cell.bind(name: categoryRecord.category!.name!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let categoryRecord=categoryRecordResultsController.object(at: indexPath)
        let text=categoryRecord.category!.name!
        let width=text.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]).width+12
        return CGSize(width: width, height: CGFloat(24))
    }
}


extension AttributesInputCollectionViewCell: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if controller == categoryRecordResultsController {
            switch type {
                case .insert:
                    categoriesCollectionView.insertItems(at: [newIndexPath!])
                    break
                case .update:
                    categoriesCollectionView.reloadItems(at: [indexPath!])
                    break
                case .delete:
                    categoriesCollectionView.deleteItems(at: [indexPath!])
                    break
                case .move:
                    break
                @unknown default:
                    break
            }
            initPlaceholder()
        }
        else if controller == dataRecordResultsController {
            setDataRecord()
        }
        
    }
}
