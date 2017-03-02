/**
 * RegisterStep2ViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */


import UIKit

class RegisterStep2ViewController: BaseRegisterViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tfEmail: UITextField!
    
    var fistName : String?;
    var lastName : String?;
    var uiImage : UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView();
    }
    
    func initView() {
        let email = NSAttributedString(string: StringUtilities.getLocalizedString("email_address", comment: ""), attributes: [NSForegroundColorAttributeName:UIColor.init(netHex: Const.COLOR_PLACEHOLDER)])
        tfEmail.attributedPlaceholder = email
        
        lbTitle.text = StringUtilities.getLocalizedString("enter_email_address", comment: "");
    }

    override func didPressNext() {
        if (validate() == true){
            let resgisVC = RegisterStep3ViewController();
            resgisVC.fistName = fistName;
            resgisVC.lastName = lastName;
            resgisVC.email = tfEmail.text?.trim();
            resgisVC.uiImage = self.uiImage;
            self.navigationController?.pushViewController(resgisVC, animated: true);
        }
        
    }

    func validate() -> Bool {
        let email = tfEmail.text?.trim();
        
        if (email?.isEmpty == true){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("email_empty", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        
        if (Utils.isValidEmail(testStr: email!) == false){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("email_incorect_format", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        return true;
    }
 
    @IBAction func didEnd(_ sender: AnyObject) {
        tfEmail.resignFirstResponder();
    }

}
