/**
 * ForgotPasswordViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit

class ForgotPasswordViewController: BaseViewController {

    @IBOutlet weak var tfEmailAddress: UITextField!
    @IBOutlet weak var btnReissue: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let strHintUserName = NSAttributedString(string: StringUtilities.getLocalizedString("enter_user_name", comment: ""), attributes: [NSForegroundColorAttributeName:UIColor.init(netHex: Const.COLOR_PLACEHOLDER)])
        tfEmailAddress.attributedPlaceholder = strHintUserName
        
        btnReissue.setTitle(StringUtilities.getLocalizedString("reissue", comment: ""), for: UIControlState.normal);
    }

    @IBAction func pressReissue(_ sender: AnyObject) {
        if (validate() == true){
            self.callApiResetPassword();
        }
    }
    
    func validate () -> Bool{
        
        let userName = tfEmailAddress.text?.trim();
   
        if (userName?.isEmpty == true){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("user_name_empty", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        
        if (Utils.isValidEmail(testStr: userName!) == false){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("email_incorect_format", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        
        return true;
    }
    
    /*
     * call api reset password
     */
    func callApiResetPassword(){
        var params : Dictionary = Dictionary<String, String>();
        let userName = tfEmailAddress.text?.trim();
        params.updateValue(userName!, forKey: Const.KEY_PARAMS_EMAIL);
        
        APIClient.sharedInstance.postRequest(Url: URL_RESET_PASSWORD, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
            self.view.makeToast(StringUtilities.getLocalizedString("success", comment: ""), duration: 2.0, position: .center)
            self.perform(#selector(ForgotPasswordViewController.back), with: nil, afterDelay: 1.0);
            
        }) { (error : AnyObject?) in
            
        }
    }
    
    func back() {
        self.navigationController!.popViewController(animated: true);
    }

}
