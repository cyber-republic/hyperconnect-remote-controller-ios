
import UIKit
import CoreData

class DevicesViewController: UIViewController {
    
    @IBOutlet weak var devicesCollectionView: UICollectionView!
    @IBOutlet weak var emptyPlaceholder: UIStackView!
    
    let pageIndex=1
    var deviceResultsController:NSFetchedResultsController<Device>!
    var selectedCategory:Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDeviceResultsController()
        devicesCollectionView.delegate=self
        devicesCollectionView.dataSource=self
        initPlaceholder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "actionAddDevice" {
            let addDeviceVC=segue.destination as! AddDeviceViewController
            addDeviceVC.fromPageIndex=pageIndex
        }
        else if segue.identifier == "actionSensors" {
            let sensorsVC=segue.destination as! SensorsViewController
            sensorsVC.fromPageIndex=pageIndex
            sensorsVC.device=sender as? Device
            if selectedCategory != nil {
                sensorsVC.selectedMap[selectedCategory]=true
            }
        }
        else if segue.identifier == "actionNotifications" {
            let notificationsVC=segue.destination as! NotificationsViewController
            notificationsVC.fromPageIndex=pageIndex
            notificationsVC.device=sender as? Device
        }
    }
    
    public func initPlaceholder() {
        if deviceResultsController.sections?[0].numberOfObjects ?? 0 == 0 {
            devicesCollectionView.isHidden=true
            emptyPlaceholder.isHidden=false
        }
        else {
            devicesCollectionView.isHidden=false
            emptyPlaceholder.isHidden=true
        }
    }
    
    func initDeviceResultsController() {
        let fetchRequest:NSFetchRequest<Device>=Device.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        deviceResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: LocalRepository.sharedInstance.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        deviceResultsController.delegate=self
        do{
            try deviceResultsController.performFetch()
        }
        catch{}
    }
}


extension DevicesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deviceResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let device=deviceResultsController.object(at: indexPath)
        let cell=devicesCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DevicesCollectionViewCell
        cell.bind(devicesVC: self, device: device)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat(174))
    }
}


extension DevicesViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if devicesCollectionView.numberOfItems(inSection: 0) == 0 {
            if type == .insert {
                devicesCollectionView.insertItems(at: [newIndexPath!])
            }
        }
        else {
            devicesCollectionView.reloadData()
        }
        initPlaceholder()
    }
}
