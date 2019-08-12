
import UIKit

class CategoriesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectImage: UIImageView!
    
    let localRepository=LocalRepository.sharedInstance
    var isCellSelected:Bool=false
    var category:Category!
    
    func bind(category: Category, attribute: Attribute) {
        self.category=category
        nameLabel.text=category.name
        
        let categoryRecord=localRepository.getCategoryRecordByCategoryAndAttribute(category: category, attribute: attribute)
        if categoryRecord == nil {
            isCellSelected=false
        }
        else {
            isCellSelected=true
        }
        
        initImages()
    }
    
    func setCellSelected() {
        isCellSelected = !isCellSelected
        initSelectedImages()
    }
    
    func getCategory() -> Category {
        return category
    }
    
    func isCategorySelected() -> Bool {
        return isCellSelected
    }
    
    private func initImages() {
        categoryImage.image=UIImage(named: "imageCategory")?.withRenderingMode(.alwaysTemplate)
        categoryImage.tintColor=UIColor.init(named: "colorMetal")
        initSelectedImages()
    }
    
    private func initSelectedImages() {
        if isCellSelected {
            selectImage.image=UIImage(named: "imageCheckBox")?.withRenderingMode(.alwaysTemplate)
            selectImage.tintColor=UIColor.init(named: "colorGreen")
        }
        else {
            selectImage.image=UIImage(named: "imageCheckBoxOutline")?.withRenderingMode(.alwaysTemplate)
            selectImage.tintColor=UIColor.init(named: "colorMetal")
        }
    }
}
