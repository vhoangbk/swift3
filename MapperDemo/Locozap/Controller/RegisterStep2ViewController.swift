//
//  RegisterStep2ViewController.swift
//  Locozap
//
//  Created by paraline on 11/11/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class RegisterStep2ViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressNext(_ sender: AnyObject) {
        let resgisVC = RegisterStep4ViewController();
        self.navigationController?.pushViewController(resgisVC, animated: true);
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
