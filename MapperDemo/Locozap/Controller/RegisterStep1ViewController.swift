//
//  RegisterStep1ViewController.swift
//  Locozap
//
//  Created by paraline on 11/11/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class RegisterStep1ViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func pressNext(_ sender: AnyObject) {
        let resgisVC = RegisterStep2ViewController();
        self.navigationController?.pushViewController(resgisVC, animated: true);
    }
    

}
