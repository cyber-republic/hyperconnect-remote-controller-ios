
import UIKit
import CoreData

class SensorsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var sensorNameLabel: UILabel!
    @IBOutlet weak var sensorImage: UIImageView!
    @IBOutlet weak var attributesCollectionView: UICollectionView!
    
    var device:Device!
    var sensor:Sensor!
    var sensorsVC:SensorsViewController!
    var selectedList:[Category]!
    var visibleMap:[Attribute:Bool]=[:]
    var attributeResultsController:NSFetchedResultsController<Attribute>!
    let localRepository=LocalRepository.sharedInstance
    
    func bind(device: Device, sensor: Sensor, sensorsVC: SensorsViewController, selectedList: [Category]) {
        self.device=device
        self.sensor=sensor
        self.sensorsVC=sensorsVC
        self.selectedList=selectedList
        sensorNameLabel.text=sensor.name
        initImageColor()
        initAttributeResultsController()
        attributesCollectionView.delegate=self
        attributesCollectionView.dataSource=self
        attributesCollectionView.reloadData()
    }
    
    fileprivate func initImageColor() {
        let developerBoardImage=UIImage(named: "imageDeveloperBoard")?.withRenderingMode(.alwaysTemplate)
        sensorImage.image=developerBoardImage
        sensorImage.tintColor=UIColor.init(named: "colorMetal")
    }
    
    func initAttributeResultsController() {
        let fetchRequest:NSFetchRequest<Attribute>=Attribute.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors=[sortDescriptor]
        let devicePredicate=NSPredicate(format: "device.userId==%@", device.userId!)
        let sensorPredicate=NSPredicate(format: "sensor.edgeSensorId==%i", sensor.edgeSensorId)
        
        if selectedList.count == 0 {
            let andPredicate=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [devicePredicate, sensorPredicate])
            fetchRequest.predicate=andPredicate
        }
        else {
            var categoryPredicates:[NSPredicate]=[]
            for category in selectedList {
                let categoryPredicate=NSPredicate(format: "ANY categories.category.name==%@", category.name!)
                categoryPredicates.append(categoryPredicate)
            }
            let orPredicate=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: categoryPredicates)
            let andPredicate=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [devicePredicate, sensorPredicate, orPredicate])
            fetchRequest.predicate=andPredicate
        }
        
        attributeResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: LocalRepository.sharedInstance.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        attributeResultsController.delegate=self
        do{
            try attributeResultsController.performFetch()
        }
        catch{}
    }
    
}

extension SensorsCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attributeResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let attribute=attributeResultsController.object(at: indexPath)
        if attribute.direction == AttributeDirection.INPUT.value {
            let cell=attributesCollectionView.dequeueReusableCell(withReuseIdentifier: "attributeInputCell", for: indexPath) as! AttributesInputCollectionViewCell
            cell.bind(attribute: attribute, sensorsVC: sensorsVC)
            return cell
        }
        else {
            let cell=attributesCollectionView.dequeueReusableCell(withReuseIdentifier: "attributeOutputCell", for: indexPath) as! AttributesOutputCollectionViewCell
            cell.bind(attribute: attribute, sensorsVC: sensorsVC)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let attribute=attributeResultsController.object(at: indexPath)
        if attribute.direction == AttributeDirection.INPUT.value {
            return CGSize(width: collectionView.bounds.size.width, height: CGFloat(270))
        }
        else {
            return CGSize(width: collectionView.bounds.size.width, height: CGFloat(216))
        }
    }
}


extension SensorsCollectionViewCell: NSFetchedResultsControllerDelegate{
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if attributesCollectionView.numberOfItems(inSection: 0) == 0 {
            attributesCollectionView.reloadData()
        }
        else {
            switch type {
                case .insert:
                    attributesCollectionView.insertItems(at: [newIndexPath!])
                    break
                case .update:
                    attributesCollectionView.reloadItems(at: [indexPath!])
                    break
                case .delete:
                    attributesCollectionView.deleteItems(at: [indexPath!])
                    break
                case .move:
                    break
                @unknown default:
                    break
            }
        }
    }
}
