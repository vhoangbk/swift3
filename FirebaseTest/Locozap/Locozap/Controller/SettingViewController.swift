/**
 * SettingViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import FacebookLogin
import FacebookCore

class SettingViewController: BaseViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbEditProfile: UILabel!
    @IBOutlet weak var lbChangePassword: UILabel!
    @IBOutlet weak var lbLevelLanguage: UILabel!
    @IBOutlet weak var lbHelp: UILabel!
    @IBOutlet weak var lbNotice: UILabel!
    @IBOutlet weak var lbPolicy: UILabel!
    @IBOutlet weak var lbTerms: UILabel!
    @IBOutlet weak var lbLogout: UILabel!
    @IBOutlet weak var lbPremium: UILabel!

    @IBOutlet weak var lineChangePass: UIView!
    @IBOutlet weak var imgArrowChangePass: UIImageView!
    @IBOutlet weak var heightContraintChangePass: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        appDelegate.screenPosition = AppDelegate.SETTING_POSITION;
    }
    
    func initView() {
        
        lbTitle.text = StringUtilities.getLocalizedString("header_activity_setting", comment: "");
        lbEditProfile.text = StringUtilities.getLocalizedString("edit_profile", comment: "");
        lbChangePassword.text = StringUtilities.getLocalizedString("change_password", comment: "");
        lbLevelLanguage.text = StringUtilities.getLocalizedString("changing_language_level", comment: "");
        lbHelp.text = StringUtilities.getLocalizedString("setting_help", comment: "");
        lbNotice.text = StringUtilities.getLocalizedString("setting_notification", comment: "");
        lbPolicy.text = StringUtilities.getLocalizedString("setting_privacy_policy", comment: "");
        lbTerms.text = StringUtilities.getLocalizedString("setting_terms_of_service", comment: "");
        lbLogout.text = StringUtilities.getLocalizedString("setting_logout", comment: "");
        lbPremium.text = StringUtilities.getLocalizedString("premium_service", comment: "");
        
        if let isFacebookAccount = mUser?.facebookAccount {
            if isFacebookAccount {
                self.lineChangePass.isHidden = true;
                self.imgArrowChangePass.isHidden = true;
                self.lbChangePassword.isHidden = true;
                heightContraintChangePass.constant = 92;
            } else {
                self.lineChangePass.isHidden = false;
                self.imgArrowChangePass.isHidden = false;
                self.lbChangePassword.isHidden = false;
                heightContraintChangePass.constant = 137;
            }
        }
        
        //tap edit profile
        lbEditProfile.isUserInteractionEnabled = true;
        let tapEditProfile = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.editProfile))
        lbEditProfile.addGestureRecognizer(tapEditProfile)
        
        //tap edit profile
        let tapChangePassword = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.changePassword))
        lbChangePassword.addGestureRecognizer(tapChangePassword)
        
        //tap help
        let tapHelp = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.didTapHelp))
        lbHelp.addGestureRecognizer(tapHelp)
        
        //tap notice
        let tapNotice = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.didTapNotice))
        lbNotice.addGestureRecognizer(tapNotice)
        
        //tap policy
        let tapPolicy = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.didTapPolicy))
        lbPolicy.addGestureRecognizer(tapPolicy)
        
        //tap terms
        let tapTerms = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.didTapTerms))
        lbTerms.addGestureRecognizer(tapTerms)
        
        
    }
    
    @IBAction func pressBack(_ sender: Any) {
        self.navigationController!.popViewController(animated: true);
    }

    @IBAction func pressLogout(_ sender: AnyObject) {
        
        self.callApiLogout();
        
    }
    
    @IBAction func pressSettingLanguage(_ sender: Any) {
        let settingLangagueVC = SettingLanguageViewController();
        self.navigationController?.pushViewController(settingLangagueVC, animated: true);
    }
    
    func editProfile() {
        let editProfileVC = EditProfileViewController();
        self.navigationController?.pushViewController(editProfileVC, animated: true);
    }
    
    func callApiLogout() {
       
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
   
        APIClient.sharedInstance.postRequest(Url: URL_LOGOUT, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
            let loginManager = LoginManager();
            loginManager.logOut();
            Utils.setInfoAccount(infoAccount: nil);
            Utils.setApiKey(token: "");
            
            Utils.setPremium(isPremium: false)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            UIApplication.shared.applicationIconBadgeNumber = 0;
            UIApplication.shared.cancelAllLocalNotifications();
            appDelegate.mUser = nil;
            let login = LoginViewController();
            let naviVC = UINavigationController(rootViewController: login);
            appDelegate.window?.rootViewController = naviVC;
            appDelegate.window?.makeKeyAndVisible();
            
        }) { (error : AnyObject?) in
            
        }

    }
    
    func changePassword() {
        let changPasswordVC = ChangePasswordViewController();
        self.navigationController?.pushViewController(changPasswordVC, animated: true);
    }
    
    func didTapHelp() {
        let helpVC = WebViewViewController();
        helpVC.url = URL(string: Const.URL_HELP + Utils.getLanguageCode());
        helpVC.textBack = StringUtilities.getLocalizedString("header_activity_setting", comment: "");
        helpVC.textTitle = StringUtilities.getLocalizedString("setting_help_title", comment: "");
        helpVC.isShowNaviWeb = true;
        self.navigationController?.pushViewController(helpVC, animated: true)
    }
    
    func didTapNotice() {
        let noticeVC = WebViewViewController();
        noticeVC.url = URL(string: Const.URL_NOTICE + Utils.getLanguageCode());
        noticeVC.isShowNaviWeb = true;
        noticeVC.textBack = StringUtilities.getLocalizedString("header_activity_setting", comment: "");
        noticeVC.textTitle = StringUtilities.getLocalizedString("setting_notice_title", comment: "");
        self.navigationController?.pushViewController(noticeVC, animated: true)
    }
    
    func didTapPolicy() {
        let policyVC = WebViewViewController();
        policyVC.url = URL(string: Const.URL_PRIVACY + Utils.getLanguageCode());
        policyVC.textBack = StringUtilities.getLocalizedString("header_activity_setting", comment: "");
        policyVC.textTitle = StringUtilities.getLocalizedString("setting_terms_title", comment: "");
        self.navigationController?.pushViewController(policyVC, animated: true)
    }
    
    func didTapTerms() {
        let termsVC = WebViewViewController();
        termsVC.url = URL(string: Const.URL_TERM + Utils.getLanguageCode());
        termsVC.isShowNaviWeb = false;
        termsVC.textBack = StringUtilities.getLocalizedString("header_activity_setting", comment: "");
        termsVC.textTitle = StringUtilities.getLocalizedString("setting_policy_title", comment: "");
        self.navigationController?.pushViewController(termsVC, animated: true)
    }
    
    @IBAction func pressPrenium(_ sender: Any) {
        self.navigationController?.pushViewController(PremiumViewController(), animated: true);
    }
}
