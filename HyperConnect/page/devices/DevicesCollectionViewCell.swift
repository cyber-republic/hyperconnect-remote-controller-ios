
import UIKit
import CoreData
import MaterialComponents.MaterialSnackbar

class DevicesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var sensorsButton: UIButton!
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var categoryPlaceholder: UILabel!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    var devicesVC:DevicesViewController!
    var device:Device!
    var categoryRecordResultsController:NSFetchedResultsController<CategoryRecord>!
    var categoryMap:[Category:Bool]=[:]
    
    func bind(devicesVC: DevicesViewController, device: Device) {
        self.devicesVC=devicesVC
        self.device=device
        nameLabel.text=device.name
        
        categoryMap.removeAll()
        initCategoryRecordResultsController()
        categoriesCollectionView.delegate=self
        categoriesCollectionView.dataSource=self
        initPlaceholder()
        categoriesCollectionView.reloadData()
        
        stateImage.image=UIImage(named: "imageLens")?.withRenderingMode(.alwaysTemplate)
        
        if device.state == DeviceState.ACTIVE.value {
            if device.connectionState == DeviceConnectionState.ONLINE.value {
                stateLabel.text="Online"
                stateImage.tintColor=UIColor.init(named: "colorGreen")
            }
            else if device.connectionState == DeviceConnectionState.OFFLINE.value {
                stateLabel.text="Offline"
                stateImage.tintColor=UIColor.init(named: "colorRed")
            }
            sensorsButton.setBackgroundImage(imageWithColor(color: UIColor.init(named: "colorMetal")!), for: .normal)
            notificationsButton.setBackgroundImage(imageWithColor(color: UIColor.init(named: "colorMetal")!), for: .normal)
        }
        else if device.state == DeviceState.PENDING.value || device.state == DeviceState.DEACTIVATED.value {
            stateLabel.text=DeviceState.init(rawValue: device.state)?.description
            stateImage.tintColor=UIColor.init(named: "colorOrange")
            sensorsButton.setBackgroundImage(imageWithColor(color: UIColor.init(named: "colorGray")!), for: .normal)
            notificationsButton.setBackgroundImage(imageWithColor(color: UIColor.init(named: "colorGray")!), for: .normal)
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
        let sortDescriptor=NSSortDescriptor(key: "category.name", ascending: true)
        fetchRequest.sortDescriptors=[sortDescriptor]
        let devicePredicate=NSPredicate(format: "deviceUserId=%@", device.userId!)
        fetchRequest.predicate=devicePredicate
        categoryRecordResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: LocalRepository.sharedInstance.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        categoryRecordResultsController.delegate=self
        do{
            try categoryRecordResultsController.performFetch()
        }
        catch{}
    }
    
    private func imageWithColor(color: UIColor) -> UIImage? {
        let rect=CGRect(x:0.0, y:0.0, width:1.0, height:1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context=UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image=UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    @IBAction func onSensorsButton(_ sender: UIButton) {
        if device.state == DeviceState.ACTIVE.value {
            devicesVC.performSegue(withIdentifier: "actionSensors", sender: device)
        }
        else if device.state == DeviceState.PENDING.value || device.state == DeviceState.DEACTIVATED.value {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Activate the device on the Edge Client."))
        }
    }
    
    @IBAction func onNotificationsButton(_ sender: UIButton) {
        if device.state == DeviceState.ACTIVE.value {
            devicesVC.performSegue(withIdentifier: "actionNotifications", sender: device)
        }
        else if device.state == DeviceState.PENDING.value || device.state == DeviceState.DEACTIVATED.value {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Activate the device on the Edge Client."))
        }
    }
    
    @IBAction func onMoreButton(_ sender: UIButton) {
        let dialog=UIStoryboard(name: "Dialog", bundle: nil).instantiateViewController(withIdentifier: "popoverDeviceActions") as! PopoverDeviceActionsViewController
        dialog.bind(button: sender, cellY: self.frame.origin.y, devicesVC: devicesVC, device: device)
        devicesVC.addChild(dialog)
        devicesVC.view.addSubview(dialog.view)
    }
}



extension DevicesCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryRecordResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categoryRecord=categoryRecordResultsController.object(at: indexPath)
        let cell=categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoriesDeviceCollectionViewCell
        cell.bind(category: categoryRecord.category!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let categoryRecord=categoryRecordResultsController.object(at: indexPath)
        let text=categoryRecord.category!.name!
        
        let hasCategory=categoryMap[categoryRecord.category!]
        if hasCategory == nil {
            categoryMap[categoryRecord.category!]=true
            let width=text.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]).width+12
            return CGSize(width: width, height: CGFloat(24))
        }
        else {
            return CGSize(width: CGFloat(0), height: CGFloat(0))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category=categoryRecordResultsController.object(at: indexPath).category!
        devicesVC.selectedCategory=category
        devicesVC.performSegue(withIdentifier: "actionSensors", sender: device)
    }
}


extension DevicesCollectionViewCell: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if categoriesCollectionView.numberOfItems(inSection: 0) == 0 {
            if type == .insert {
                categoriesCollectionView.insertItems(at: [newIndexPath!])
            }
        }
        else {
            categoriesCollectionView.reloadData()
        }
        initPlaceholder()
    }
}

