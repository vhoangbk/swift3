/**
 * RegisterStep3ViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit

class RegisterStep3ViewController: BaseRegisterViewController {
    
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tfPassword: UITextField!
    
    var fistName : String?;
    var lastName : String?;
    var email : String?;
    var uiImage : UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView();
    }

    func initView() {
        let password = NSAttributedString(string: StringUtilities.getLocalizedString("password", comment: ""), attributes: [NSForegroundColorAttributeName:UIColor.init(netHex: Const.COLOR_PLACEHOLDER)])
        tfPassword.attributedPlaceholder = password
        
        lbTitle.text = StringUtilities.getLocalizedString("enter_password", comment: "");
    }
    
    override func didPressNext() {
        if (self.validate() == true){
            let resgisVC = RegisterStep4ViewController();
            resgisVC.fistName = fistName;
            resgisVC.lastName = lastName;
            resgisVC.email = email;
            resgisVC.password = tfPassword.text?.trim();
            resgisVC.uiImage = self.uiImage;
            self.navigationController?.pushViewController(resgisVC, animated: true);
        }
        
    }

    func validate() -> Bool {
        let password = tfPassword.text?.trim();
        
        if (password?.isEmpty == true){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("password_empty", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        
        if ((password?.characters.count)! < 6){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("password_less_6_character", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        return true;
    }
    
    @IBAction func didEnd(_ sender: AnyObject) {
        tfPassword.resignFirstResponder();
    }
}
