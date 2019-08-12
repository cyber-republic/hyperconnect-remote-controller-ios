
import UIKit

class FilterCategoriesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectImage: UIImageView!
    
    let localRepository=LocalRepository.sharedInstance
    var isCellSelected:Bool=false
    var category:Category!
    
    func bind(category: Category, selectedMap: [Category:Bool]) {
        self.category=category
        nameLabel.text=category.name
        
        let isCategoryInFilter=selectedMap[category]
        if isCategoryInFilter != nil {
            if isCategoryInFilter! {
                isCellSelected=true
            }
            else {
                isCellSelected=false
            }
        }
        else {
            isCellSelected=false
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
