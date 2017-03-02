/**
 * CellSettingLanguage
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */


import UIKit

protocol DelegateCellSettingLanguage {
    func didSelectDeleteSettingLanguage(language : Language);
}

class CellSettingLanguage: UITableViewCell {
    var delegateCellSettingLanguage : DelegateCellSettingLanguage!;
    var mLanguage : Language!;
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var nameLanguage: UILabel!
    @IBOutlet weak var levelLanguage: RatingBar!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func pressDelete(_ sender: Any) {
        if (delegateCellSettingLanguage != nil) {
            delegateCellSettingLanguage.didSelectDeleteSettingLanguage(language: self.mLanguage);
        }
    }
    
}
