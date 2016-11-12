//
//  LoginViewController.swift
//  Locozap
//
//  Created by paraline on 10/7/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit
import SocketIO

class LoginViewController: BaseViewController {
    @IBOutlet weak var mLblTerms: UILabel!
    @IBOutlet weak var mBtnRegister: UIButton!
    @IBOutlet weak var mBtnLoginWithFacebook: UIButton!
    @IBOutlet weak var btnLogin: LocalizedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView();
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: true);
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initView(){
        let strTerms = NSLocalizedString("terms_of_use_and_rivacy_policy", comment: "");
        let strBtnLoginWithFacebook = NSLocalizedString("account_facebook", comment: "");
        let strBtnRegister = NSLocalizedString("account_creation", comment: "");
        let strBtnLoginAcount = NSLocalizedString("login", comment: "");
        
        let attrStr = try! NSAttributedString(
            data: strTerms.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil);
        
        mLblTerms.attributedText = attrStr;
        mBtnRegister.setTitle(strBtnRegister, for: UIControlState.normal);
        mBtnLoginWithFacebook.setTitle(strBtnLoginWithFacebook, for: UIControlState.normal);
        btnLogin.setTitle(strBtnLoginAcount, for: UIControlState.normal);
    }
        

    @IBAction func pressActionLogin(_ sender: AnyObject) {
        let loginVC = LoginAccountViewController()
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func pressActionRegistrer(_ sender: AnyObject) {
        let resgisVC = RegisterViewController();
        self.navigationController?.pushViewController(resgisVC, animated: true);
    }
    
}
