
import UIKit
import CoreData
import MaterialComponents.MaterialSnackbar

class DialogAddCategoryViewController: UIViewController {
    
    @IBOutlet weak var categoryNameInput: UITextField!
    @IBOutlet weak var emptyPlaceholder: UIView!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    let localRepository=LocalRepository.sharedInstance
    var categoryResultsController:NSFetchedResultsController<Category>!
    var attribute:Attribute!
    var selectedMap:[Category:Bool]=[:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewTap()
        categoryNameInput.delegate=self
        
        initCategoryResultsController()
        categoriesCollectionView.delegate=self
        categoriesCollectionView.dataSource=self
        initPlaceholder()
    }
    
    func bind(attribute: Attribute) {
        self.attribute=attribute
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
        /*let tap=UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tap.numberOfTapsRequired=1
        self.view.addGestureRecognizer(tap)*/
        
        let keyBoardTap=UITapGestureRecognizer(target: self, action: #selector(handleKeyboardTap(sender:)))
        keyBoardTap.numberOfTapsRequired=1
        categoryNameInput.inputView?.addGestureRecognizer(keyBoardTap)
    }
    
    /*@objc func handleTap(sender: UITapGestureRecognizer) {
        closeDialog()
    }*/
    
    @objc func handleKeyboardTap(sender: UITapGestureRecognizer) {
        hideKeyboard()
    }
    
    private func closeDialog() {
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    
    @IBAction func onAddButton(_ sender: UIButton) {
        var canContinue=true
        let categoryName=categoryNameInput.text!
        if categoryName.isEmpty {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Category Name is empty."))
            canContinue=false
        }
        let categoryList=categoryResultsController.fetchedObjects!
        for category in categoryList {
            if category.name == categoryName {
                MDCSnackbarManager.show(MDCSnackbarMessage(text: "Category Name exists."))
                canContinue=false
                break
            }
        }
        if canContinue {
            let category=Category(context: localRepository.getDataController().viewContext)
            category.name=categoryName
            localRepository.updateDatabase()
        }
        categoryNameInput.text=""
    }
    
    @IBAction func onCloseButton(_ sender: UIButton) {
        closeDialog()
    }
    
    @IBAction func onUpdateButton(_ sender: UIButton) {
        for (category, isSelected) in selectedMap {
            let categoryRecord=localRepository.getCategoryRecordByCategoryAndAttribute(category: category, attribute: attribute)
            if isSelected {
                if categoryRecord == nil {
                    let newCategoryRecord=CategoryRecord(context: localRepository.getDataController().viewContext)
                    newCategoryRecord.deviceUserId=attribute.device!.userId
                    newCategoryRecord.attribute=attribute
                    newCategoryRecord.category=category
                    attribute.addToCategories(newCategoryRecord)
                    localRepository.updateDatabase()
                }
            }
            else {
                if categoryRecord != nil {
                    localRepository.deleteCategoryRecord(categoryRecord: categoryRecord!)
                    attribute.removeFromCategories(categoryRecord!)
                    localRepository.updateDatabase()
                }
            }
        }
        MDCSnackbarManager.show(MDCSnackbarMessage(text: "Categories has been updated."))
    }
}


extension DialogAddCategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category=categoryResultsController.object(at: indexPath)
        let cell=categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoriesCollectionViewCell
        cell.bind(category: category, attribute: attribute)
        selectedMap[category]=cell.isCategorySelected()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat(39))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell=categoriesCollectionView.cellForItem(at: indexPath) as! CategoriesCollectionViewCell
        cell.setCellSelected()
        selectedMap[cell.getCategory()]=cell.isCategorySelected()
    }
    
}


extension DialogAddCategoryViewController: NSFetchedResultsControllerDelegate {
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


extension DialogAddCategoryViewController: UITextFieldDelegate {
    fileprivate func hideKeyboard() {
        categoryNameInput.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}
