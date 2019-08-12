
import UIKit

class CategoriesSensorCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    func bind(category: Category) {
        nameLabel.text=category.name
    }
}
