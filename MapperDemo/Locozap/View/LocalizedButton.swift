//
//  LocalizedButton.swift
//  Locozap
//
//  Created by paraline on 10/12/16.
//  Copyright © 2016 paraline. All rights reserved.
//

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
