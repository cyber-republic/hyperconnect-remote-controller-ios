
import UIKit

class CategoriesInputCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    func bind(name: String) {
        nameLabel.text=name
    }
}
