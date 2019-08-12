
import UIKit
import CoreData
import SwiftyJSON
import MaterialComponents.MaterialSnackbar
import iOSDropDown

class AttributesOutputCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var attributeImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueInput: UITextField!
    @IBOutlet weak var valueDropDown: DropDown!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateSwitch: UISwitch!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var categoryPlaceholder: UIView!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    
    var attribute:Attribute!
    var sensorsVC:SensorsViewController!
    let elastosCarrier=ElastosCarrier.sharedInstance
    let localRepository=LocalRepository.sharedInstance
    var categoryRecordResultsController:NSFetchedResultsController<CategoryRecord>!
    
    func bind(attribute: Attribute, sensorsVC: SensorsViewController) {
        self.attribute=attribute
        self.sensorsVC=sensorsVC
        nameLabel.text=attribute.name
        
        initViewTap()
        valueInput.delegate=self
        
        initCategoryRecordResultsController()
        categoriesCollectionView.delegate=self
        categoriesCollectionView.dataSource=self
        initPlaceholder()
        categoriesCollectionView.reloadData()
        
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
        
        if attribute.type == AttributeType.BOOLEAN.value {
            valueInput.isHidden=true
            valueDropDown.isHidden=false
            valueDropDown.selectedIndex=0
            valueDropDown.text="True"
            valueInput.text="True"
            valueDropDown.optionArray=["True", "False"]
            valueDropDown.optionIds=[1, 2]
            valueDropDown.didSelect{(selectedText, index, id) in
                self.valueInput.text=selectedText
            }
        }
        else {
            valueInput.isHidden=false
            valueDropDown.isHidden=true
        }
    }
    
    private func initViewTap() {
        let tap=UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tap.numberOfTapsRequired=1
        //self.view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        hideKeyboard()
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
    
    @IBAction func onSendButton(_ sender: UIButton) {
        let device=attribute.device!
        if device.connectionState == DeviceConnectionState.ONLINE.value {
            let value=valueInput.text!
            if value.isEmpty {
                MDCSnackbarManager.show(MDCSnackbarMessage(text: "Please fill out the required field for the attribute."))
            }
            else if value.contains(" ") {
                MDCSnackbarManager.show(MDCSnackbarMessage(text: "The input field cannot contain whitespace."))
            }
            else if attribute.state == AttributeState.DEACTIVATED.value {
                MDCSnackbarManager.show(MDCSnackbarMessage(text: "Attribute is not active."))
            }
            else {
                let jsonObject:JSON=[
                    "command": "executeAttributeAction",
                    "id": attribute.edgeAttributeId,
                    "triggerValue": value
                ]
                let sendCheck=elastosCarrier.sendFriendMessageWithResponse(userId: device.userId!, message: jsonObject.description)
                if sendCheck {
                    MDCSnackbarManager.show(MDCSnackbarMessage(text: "Action message has been sent."))
                }
                else {
                    MDCSnackbarManager.show(MDCSnackbarMessage(text: "Sorry, something went wrong."))
                }
                valueInput.text=""
            }
        }
        else {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Device is offline."))
        }
    }
    
    @IBAction func onAddCategoryButton(_ sender: UIButton) {
        let dialog=UIStoryboard(name: "Dialog", bundle: nil).instantiateViewController(withIdentifier: "dialogAddCategory") as! DialogAddCategoryViewController
        dialog.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        dialog.bind(attribute: attribute)
        sensorsVC.addChild(dialog)
        sensorsVC.view.addSubview(dialog.view)
    }
}


extension AttributesOutputCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryRecordResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categoryRecord=categoryRecordResultsController.object(at: indexPath)
        let cell=categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoriesOutputCollectionViewCell
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


extension AttributesOutputCollectionViewCell: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
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
}


extension AttributesOutputCollectionViewCell: UITextFieldDelegate {
    fileprivate func hideKeyboard() {
        valueInput.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}
