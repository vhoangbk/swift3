//
//  BaseViewController.swift
//  IOSBase
//
//  Created by paraline on 2/22/17.
//  Copyright © 2017 paraline. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationController?.isNavigationBarHidden = isHideNavigation();
    }
    
    func isHideNavigation() -> Bool {
        return false;
    }
    
   

}
