
import UIKit

class CategoriesDeviceCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    func bind(category: Category) {
        nameLabel.text=category.name
    }
}
