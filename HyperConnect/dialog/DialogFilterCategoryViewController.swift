
import UIKit
import CoreData

class DialogFilterCategoryViewController: UIViewController {
    @IBOutlet weak var emptyPlaceholder: UIView!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    let localRepository=LocalRepository.sharedInstance
    var categoryResultsController:NSFetchedResultsController<Category>!
    var sensorsVC:SensorsViewController!
    var selectedMap:[Category:Bool]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initViewTap()
        initCategoryResultsController()
        categoriesCollectionView.delegate=self
        categoriesCollectionView.dataSource=self
        initPlaceholder()
    }
    
    func bind(sensorsVC: SensorsViewController, selectedMap: [Category:Bool]) {
        self.sensorsVC=sensorsVC
        self.selectedMap=selectedMap
    }
    
    public func initPlaceholder() {
        if categoryResultsController.sections?[0].numberOfObjects ?? 0 == 0 {
            categoriesCollectionView.isHidden=true
            emptyPlaceholder.isHidden=false
        }
        else {
            categoriesCollectionView.isHidden=false
            emptyPlaceholder.isHidden=true
        }
    }
    
    func initCategoryResultsController() {
        let fetchRequest:NSFetchRequest<Category>=Category.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        categoryResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: LocalRepository.sharedInstance.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        categoryResultsController.delegate=self
        do{
            try categoryResultsController.performFetch()
        }
        catch{}
    }
    
    private func initViewTap() {
        let tap=UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tap.numberOfTapsRequired=1
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        //closeDialog()
        //hideKeyboard()
    }
    
    private func closeDialog() {
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    @IBAction func onCloseButton(_ sender: UIButton) {
        closeDialog()
    }
    
    @IBAction func onUpdateButton(_ sender: UIButton) {
        closeDialog()
        sensorsVC.setSelectedMap(selectedMap: selectedMap)
    }
}


extension DialogFilterCategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category=categoryResultsController.object(at: indexPath)
        let cell=categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FilterCategoriesCollectionViewCell
        cell.bind(category: category, selectedMap: selectedMap)
        selectedMap[category]=cell.isCategorySelected()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat(39))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell=categoriesCollectionView.cellForItem(at: indexPath) as! FilterCategoriesCollectionViewCell
        cell.setCellSelected()
        selectedMap[cell.getCategory()]=cell.isCategorySelected()
    }
    
}


extension DialogFilterCategoryViewController: NSFetchedResultsControllerDelegate {
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
