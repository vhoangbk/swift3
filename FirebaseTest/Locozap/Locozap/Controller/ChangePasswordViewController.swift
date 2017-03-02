/**
 * ChangePasswordViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON

class ChangePasswordViewController: BaseViewController{
    @IBOutlet weak var edOldPass: UITextField!
    @IBOutlet weak var edNewPass: UITextField!
    @IBOutlet weak var edReNewPass: UITextField!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var bntDone: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false);
        initView();
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Init view 
    func initView(){
        edOldPass.placeholder = StringUtilities.getLocalizedString("current_password", comment: "");
        edNewPass.placeholder = StringUtilities.getLocalizedString("new_password", comment: "");
        edReNewPass.placeholder = StringUtilities.getLocalizedString("re_enter_new_password", comment: "");
        
        btnCancel.setTitle(StringUtilities.getLocalizedString("cancel", comment: ""), for: UIControlState.normal);
        bntDone.setTitle(StringUtilities.getLocalizedString("done", comment: ""), for: UIControlState.normal);
        lbTitle.text = StringUtilities.getLocalizedString("login_password", comment: "");
        
        self.bntDone.isEnabled = false;
    }

    @IBAction func pressBack(_ sender: Any) {
        self.navigationController!.popViewController(animated: true);
    }

    @IBAction func pressDone(_ sender: AnyObject) {

        edOldPass.resignFirstResponder();
        edNewPass.resignFirstResponder();
        edReNewPass.resignFirstResponder();
        
        if (isValidate()) {
            callApiChangePassword();
        }
    }
    
    
    // Validate
    
    func isValidate() -> Bool{
        if(edOldPass.text?.trim() != "") {
            if(edNewPass.text?.trim() != "") {
                if(edReNewPass.text?.trim() != "") {
                    if(edNewPass.text?.trim() == edReNewPass.text?.trim()){
                       return self.isValidateLengh();
                    } else {
                        Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("password_not_matched", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
                        return false;
                    }
                } else {
                    Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("password_empty", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
                    return false;
                }
            } else {
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("password_empty", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
                return false;
            }
        } else {
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("password_empty", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
    }
    
    func isValidateLengh()->Bool {
        if((edOldPass.text?.trim().characters.count)! >= 6) {
            if((edNewPass.text?.trim().characters.count)! >= 6) {
                return true;
            } else {
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("password_less_6_character", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
                return false;
            }
        } else {
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("password_less_6_character", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
    }
    
    // MARK : Call API register or update language
    func callApiChangePassword(){
        let oldPass : String = (edOldPass.text?.trim())!;
        let newPass : String = (edNewPass.text?.trim())!;
        
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(oldPass, forKey: Const.KEY_PARAMS_OLDPASS);
        params.updateValue(newPass, forKey: Const.KEY_PARAMS_NEWPASS);
        
        APIClient.sharedInstance.postRequest(Url: URL_CHANGE_PASSWORD, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("change_pass_success", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                self.navigationController!.popViewController(animated: true);
            })
            
        }) { (error : AnyObject?) in
            
        }
    }
    
    @IBAction func editChange(_ sender: AnyObject) {
        if(edOldPass.text?.trim() != "" && edNewPass.text?.trim() != ""
            && edReNewPass.text?.trim() != ""){
            self.bntDone.isEnabled = true;
        }else{
            self.bntDone.isEnabled = false;
        }
    }
    
 }
