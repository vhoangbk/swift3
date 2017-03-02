/**
 * LocalizedButton
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */


import UIKit

class LocalizedButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        
    }
    
    override func awakeFromNib() {
        let language = NSLocale.preferredLanguages.first;
        if language?.hasPrefix("ja") == true {
            
        }else{
            self.titleLabel?.font = UIFont.systemFont(ofSize: (self.titleLabel?.font.pointSize)!);
        }
    }

}
