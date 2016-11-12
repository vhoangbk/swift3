//
//  RegisterViewController.swift
//  Locozap
//
//  Created by paraline on 10/11/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class RegisterViewController: BaseViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfRePassword: UITextField!
    @IBOutlet weak var btnRegister: LocalizedButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView();
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true);
    }
    

    func initView() {
        self.tfUserName.placeholder = NSLocalizedString("enter_user_name", comment: "");
        self.tfPassword.placeholder = NSLocalizedString("enter_password", comment: "");
        self.tfRePassword.placeholder = NSLocalizedString("enter_re_password", comment: "");
        self.btnRegister.setTitle(NSLocalizedString("btn_register", comment: ""), for: UIControlState.normal);
    }

    @IBAction func pressRegister(_ sender: AnyObject) {
        if self.tfUserName.text?.isEmpty == true {
            Utils.showAlertWithTitle("", message: NSLocalizedString("user_name_empty", comment: ""), titleButtonClose: "", titleButtonOk: NSLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil)
            return
        }
        
        if self.tfPassword.text?.isEmpty == true {
            Utils.showAlertWithTitle("", message: NSLocalizedString("password_empty", comment: ""), titleButtonClose: "", titleButtonOk: NSLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil)
            return
        }
        
        if self.tfPassword.text != self.tfRePassword.text {
            Utils.showAlertWithTitle("", message: NSLocalizedString("password_incorrect", comment: ""), titleButtonClose: "", titleButtonOk: NSLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil)
            return
        }
        
        callApiRegister();
    }
    
    func callApiRegister() {
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue(tfUserName.text!, forKey: Const.KEY_PARAMS_USERNAME);
        params.updateValue(tfRePassword.text!, forKey: Const.KEY_PARAMS_PASSWORD);
        
        APIClient.sharedInstance.postRequest(Url: URL_REGISTER, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
            
            Utils.showAlertWithTitle("", message: "Create account success", titleButtonClose: "", titleButtonOk: NSLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                self.navigationController!.popViewController(animated: true)
            })
            
        }) { (error : AnyObject?) in
            
        }
    }
    
    
    func dismissKeyboard() {
        tfUserName.resignFirstResponder();
        tfPassword.resignFirstResponder();
        tfRePassword.resignFirstResponder();
    }

}
