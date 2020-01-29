
import UIKit
import CoreData
import iOSDropDown

class NotificationsViewController: UIViewController {
    @IBOutlet weak var notificationsNameLabel: UILabel!
    @IBOutlet weak var typeDropDown: DropDown!
    @IBOutlet weak var categoryDropDown: DropDown!
    @IBOutlet weak var notificationsCollectionView: UICollectionView!
    @IBOutlet weak var emptyPlaceholder: UIStackView!
    
    var fromPageIndex:Int!
    var device:Device!
    var notificationResultsController:NSFetchedResultsController<Notification>!
    var typeList:[Int16]=[NotificationType.SUCCESS.value, NotificationType.WARNING.value, NotificationType.ERROR.value]
    var categoryList:[Int16]=[NotificationCategory.DEVICE.value, NotificationCategory.SENSOR.value, NotificationCategory.ATTRIBUTE.value, NotificationCategory.EVENT.value]
    var selectedType:Int16!
    var selectedCategory:Int16!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if device == nil {
            notificationsNameLabel.text="Notifications"
        }
        else {
            notificationsNameLabel.text="Notifications of "+device.name!
        }
        
        initNotificationResultsController()
        notificationsCollectionView.delegate=self
        notificationsCollectionView.dataSource=self
        initPlaceholder()
        initFilterDropDowns()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "actionHome" {
            let viewVC=segue.destination as! ViewController
            viewVC.modalPresentationStyle = .fullScreen
            viewVC.currentPageIndex=fromPageIndex
        }
    }
    
    public func initPlaceholder() {
        if notificationResultsController.sections?[0].numberOfObjects ?? 0 == 0 {
            notificationsCollectionView.isHidden=true
            emptyPlaceholder.isHidden=false
        }
        else {
            notificationsCollectionView.isHidden=false
            emptyPlaceholder.isHidden=true
        }
    }
    
    func initNotificationResultsController() {
        let fetchRequest:NSFetchRequest<Notification>=Notification.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "dateTime", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        
        if device != nil {
            let devicePredicate=NSPredicate(format: "deviceUserId==%@", device.userId!)
            fetchRequest.predicate=devicePredicate
        }
        
        notificationResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: LocalRepository.sharedInstance.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        notificationResultsController.delegate=self
        do{
            try notificationResultsController.performFetch()
        }
        catch{}
    }
    
    public func initFilterDropDowns() {
        typeDropDown.optionArray=["-- Select Type --", "Success", "Warning", "Error"]
        typeDropDown.text="-- Select Type --"
        typeDropDown.didSelect{(selectedText, index, id) in
            if index != 0 {
                self.selectedType=self.typeList[index-1]
            }
            else {
                self.selectedType=nil
            }
            self.filter()
        }
        
        categoryDropDown.optionArray=["-- Select Category --", "Device", "Sensor", "Attribute", "Event"]
        categoryDropDown.text="-- Select Category --"
        categoryDropDown.didSelect{(selectedText, index, id) in
            if index != 0 {
                self.selectedCategory=self.categoryList[index-1]
            }
            else {
                self.selectedCategory=nil
            }
            self.filter()
        }
    }
    
    private func filter() {
        var predicateList:[NSPredicate]=[]
        if device != nil {
            let devicePredicate=NSPredicate(format: "deviceUserId==%@", device.userId!)
            predicateList.append(devicePredicate)
        }
        if selectedType != nil {
            let typePredicate=NSPredicate(format: "type==%i", selectedType)
            predicateList.append(typePredicate)
        }
        if selectedCategory != nil {
            let categoryPredicate=NSPredicate(format: "category==%i", selectedCategory)
            predicateList.append(categoryPredicate)
        }
        let andPredicate=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateList)
        notificationResultsController.fetchRequest.predicate=andPredicate
        do{
            try self.notificationResultsController.performFetch()
        }
        catch{}
        notificationsCollectionView.reloadData()
        initPlaceholder()
    }
}


extension NotificationsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notificationResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let notification=notificationResultsController.object(at: indexPath)
        let cell=notificationsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NotificationsCollectionViewCell
        cell.bind(notification: notification)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat(97))
    }
}


extension NotificationsViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                notificationsCollectionView.insertItems(at: [newIndexPath!])
                break
            case .update:
                notificationsCollectionView.reloadItems(at: [indexPath!])
                break
            case .delete:
                notificationsCollectionView.deleteItems(at: [indexPath!])
                break
            case .move:
                break
            @unknown default:
                break
        }
        initPlaceholder()
    }
}
