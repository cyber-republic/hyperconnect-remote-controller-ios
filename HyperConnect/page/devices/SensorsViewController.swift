
import UIKit
import CoreData
import iOSDropDown

class SensorsViewController: UIViewController {
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var sensorsDropDown: DropDown!
    @IBOutlet weak var emptyPlaceholder: UIStackView!
    @IBOutlet weak var sensorsCollectionView: UICollectionView!
    @IBOutlet weak var categoryPlaceholder: UILabel!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    var fromPageIndex:Int!
    let localRepository=LocalRepository.sharedInstance
    let attributeManagement=AttributeManagement.sharedInstance
    var device:Device!
    var sensorResultsController:NSFetchedResultsController<Sensor>!
    var selectedMap:[Category:Bool]=[:]
    var selectedList:[Category]=[]
    var selectedSensor:Sensor!
    var sensorList:[Sensor]=[]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceNameLabel.text="Sensors of "+device.name!
        
        initSensorResultsController()
        sensorsCollectionView.delegate=self
        sensorsCollectionView.dataSource=self
        initPlaceholder()
        initSensorDropDown()
        
        initSelectedCategories()
        categoriesCollectionView.delegate=self
        categoriesCollectionView.dataSource=self
        initCategoryPlaceholder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "actionHome" {
            attributeManagement.stopAllAttributes()
            let viewVC=segue.destination as! ViewController
            viewVC.currentPageIndex=fromPageIndex
        }
        else if segue.identifier == "actionHistory" {
            let historyVC=segue.destination as! HistoryViewController
            historyVC.fromPageIndex=fromPageIndex
            historyVC.attribute=sender as? Attribute
            historyVC.device=device
        }
    }
    
    public func initSensorDropDown() {
        let emptySensor="-- All Sensors --"
        sensorsDropDown.optionArray.removeAll()
        sensorsDropDown.optionArray.append(emptySensor)
        sensorsDropDown.text=emptySensor
        sensorList.removeAll()
        for sensor in sensorResultsController.fetchedObjects! as [Sensor] {
            sensorsDropDown.optionArray.append(sensor.name!)
            sensorList.append(sensor)
        }
        sensorsDropDown.didSelect{(selectedText, index, id) in
            self.attributeManagement.stopAllAttributes()
            if index != 0 {
                self.selectedSensor=self.sensorList[index-1]
            }
            else {
                self.selectedSensor=nil
            }
            
            if self.selectedSensor == nil {
                let predicate=NSPredicate(format: "device.userId==%@", self.device.userId!)
                self.sensorResultsController.fetchRequest.predicate=predicate
            }
            else {
                let devicePredicate=NSPredicate(format: "device.userId==%@", self.device.userId!)
                let sensorPredicate=NSPredicate(format: "edgeSensorId==%i", self.selectedSensor.edgeSensorId)
                let andPredicate=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [devicePredicate, sensorPredicate])
                self.sensorResultsController.fetchRequest.predicate=andPredicate
            }
            do{
                try self.sensorResultsController.performFetch()
            }
            catch{}
            self.sensorsCollectionView.reloadData()
        }
    }
    
    public func initPlaceholder() {
        if sensorResultsController.sections?[0].numberOfObjects ?? 0 == 0 {
            sensorsCollectionView.isHidden=true
            emptyPlaceholder.isHidden=false
        }
        else {
            sensorsCollectionView.isHidden=false
            emptyPlaceholder.isHidden=true
        }
    }
    
    func initSensorResultsController() {
        let fetchRequest:NSFetchRequest<Sensor>=Sensor.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors=[sortDescriptor]
        let devicePredicate=NSPredicate(format: "device.userId==%@", device.userId!)
        fetchRequest.predicate=devicePredicate
        sensorResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: LocalRepository.sharedInstance.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        sensorResultsController.delegate=self
        do{
            try sensorResultsController.performFetch()
        }
        catch{}
    }
    
    public func initCategoryPlaceholder() {
        if selectedList.count == 0 {
            categoriesCollectionView.isHidden=true
            categoryPlaceholder.isHidden=false
        }
        else {
            categoriesCollectionView.isHidden=false
            categoryPlaceholder.isHidden=true
        }
    }
    
    func initSelectedCategories() {
        selectedList.removeAll()
        for (category, isSelected) in selectedMap {
            if isSelected {
                selectedList.append(category)
            }
        }
    }
    
    public func setSelectedMap(selectedMap: [Category:Bool]) {
        attributeManagement.stopAllAttributes()
        self.selectedMap=selectedMap
        initSelectedCategories()
        initCategoryPlaceholder()
        categoriesCollectionView.reloadData()
        sensorsCollectionView.reloadData()
    }
    
    @IBAction func onCategoryFilterButton(_ sender: UIButton) {
        let dialog=UIStoryboard(name: "Dialog", bundle: nil).instantiateViewController(withIdentifier: "dialogFilterCategory") as! DialogFilterCategoryViewController
        dialog.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        dialog.bind(sensorsVC: self, selectedMap: selectedMap)
        addChild(dialog)
        view.addSubview(dialog.view)
    }
}


extension SensorsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == sensorsCollectionView {
            return sensorResultsController.sections?[section].numberOfObjects ?? 0
        }
        else {
            return selectedList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == sensorsCollectionView {
            let sensor=sensorResultsController.object(at: indexPath)
            let cell=sensorsCollectionView.dequeueReusableCell(withReuseIdentifier: "sensorCell", for: indexPath) as! SensorsCollectionViewCell
            cell.bind(device: device, sensor: sensor, sensorsVC: self, selectedList: selectedList)
            return cell
        }
        else {
            let category=selectedList[indexPath.row]
            let cell=categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoriesSensorCollectionViewCell
            cell.bind(category: category)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == sensorsCollectionView {
            let sensor=sensorResultsController.object(at: indexPath)
            let attributeList:[Attribute]=(sensor.attributes?.allObjects) as! [Attribute]
            var height=40
            if attributeList.count > 0 {
                for attribute in attributeList {
                    var isCellVisible=false
                    if selectedList.count == 0 {
                        isCellVisible=true
                    }
                    else {
                        for category in selectedList {
                            let categoryRecord=localRepository.getCategoryRecordByCategoryAndAttribute(category: category, attribute: attribute)
                            if categoryRecord != nil {
                                isCellVisible=true
                                break
                            }
                        }
                    }
                    
                    if isCellVisible {
                        if attribute.direction == AttributeDirection.INPUT.value {
                            height+=270+5
                        }
                        else {
                            height+=216+5
                        }
                    }
                }
            }
            return CGSize(width: collectionView.bounds.size.width, height: CGFloat(height))
        }
        else {
            let category=selectedList[indexPath.row]
            let text=category.name!
            let width=text.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]).width+12
            return CGSize(width: width, height: CGFloat(24))
        }
    }
}


extension SensorsViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if sensorsCollectionView.numberOfItems(inSection: 0) == 0 {
            if type == .insert {
                sensorsCollectionView.insertItems(at: [newIndexPath!])
            }
        }
        else {
            sensorsCollectionView.reloadData()
        }
        initPlaceholder()
        //initSensorDropDown()
    }
}
