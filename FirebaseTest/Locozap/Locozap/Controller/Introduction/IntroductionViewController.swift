//
//  IntroductionViewController.swift
//  Locozap
//
//  Created by Macintosh HD on 2/7/17.
//  Copyright © 2017 paraline. All rights reserved.
//

import UIKit

class IntroductionViewController: UIViewController, UIScrollViewDelegate {
    
    
    @IBOutlet weak var textview: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func pressToken(_ sender: Any) {
        textview.text = Utils.getDeviceToken();
    }
    
}
