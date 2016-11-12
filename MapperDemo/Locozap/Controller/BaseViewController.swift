//
//  BaseViewController.swift
//  Locozap
//
//  Created by paraline on 10/7/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var mUser : User?;

    override func viewDidLoad() {
        super.viewDidLoad()

        if (mUser == nil && Utils.getInfoAccount() != nil){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            mUser = appDelegate.mUser;
        }
        
        initNavigationBar();
    }
    
    func initNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor(netHex: Const.COLOR_PRIMARY);
        let backButton = UIBarButtonItem(image: UIImage(named: "img_back")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BaseViewController.didPressBack));
  
        self.navigationItem.leftBarButtonItem = backButton;
        
        let navFont : UIFont?;
        let language = NSLocale.preferredLanguages.first;
        if language?.hasPrefix("ja") == true {
            navFont = UIFont(name: Const.HIRAKAKUPRO_W6, size: 13);
        }else{
            navFont = UIFont.systemFont(ofSize: 13);
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.white;

        let navBarAttributesDictionary: [String: AnyObject]? = [
            (NSForegroundColorAttributeName as NSObject) as! String: UIColor(netHex: Const.COLOR_WHITE),
            (NSFontAttributeName as NSObject) as! String: navFont!
        ]
        self.navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didPressBack() {
        self.navigationController!.popViewController(animated: true);
    }
    

}
