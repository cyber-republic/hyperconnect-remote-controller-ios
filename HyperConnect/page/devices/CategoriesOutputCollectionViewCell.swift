
import UIKit

class CategoriesOutputCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    func bind(name: String) {
        nameLabel.text=name
    }
}
