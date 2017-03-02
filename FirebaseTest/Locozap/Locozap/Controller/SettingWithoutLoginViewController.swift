/**
 * SettingViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import FacebookLogin
import FacebookCore

class SettingSettingWithoutLoginViewController: BaseViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbPolicy: UILabel!
    @IBOutlet weak var lbTerms: UILabel!
    @IBOutlet weak var lbPremium: UILabel!
    @IBOutlet weak var lbHelp: UILabel!
    
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
        lbPolicy.text = StringUtilities.getLocalizedString("setting_privacy_policy", comment: "");
        lbPremium.text = StringUtilities.getLocalizedString("premium_service", comment: "");
        lbTerms.text = StringUtilities.getLocalizedString("setting_terms_of_service", comment: "");
        lbHelp.text = StringUtilities.getLocalizedString("setting_help", comment: "");
        
        //tap policy
        let tapPolicy = UITapGestureRecognizer(target: self, action: #selector(SettingSettingWithoutLoginViewController.didTapPolicy))
        lbPolicy.addGestureRecognizer(tapPolicy)
        
        //tap terms
        let tapTerms = UITapGestureRecognizer(target: self, action: #selector(SettingSettingWithoutLoginViewController.didTapTerms))
        lbTerms.addGestureRecognizer(tapTerms)
        
        //tap help
        let tapHelp = UITapGestureRecognizer(target: self, action: #selector(SettingSettingWithoutLoginViewController.didTapHelp))
        lbHelp.addGestureRecognizer(tapHelp)
        
    }
    
    @IBAction func pressBack(_ sender: Any) {
        self.navigationController!.popViewController(animated: true);
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
    
    func didTapHelp() {
        let helpVC = WebViewViewController();
        helpVC.url = URL(string: Const.URL_HELP + Utils.getLanguageCode());
        helpVC.textBack = StringUtilities.getLocalizedString("header_activity_setting", comment: "");
        helpVC.textTitle = StringUtilities.getLocalizedString("setting_help_title", comment: "");
        helpVC.isShowNaviWeb = true;
        self.navigationController?.pushViewController(helpVC, animated: true)
    }
    
    @IBAction func pressPrenium(_ sender: Any) {
        self.navigationController?.pushViewController(PremiumViewController(), animated: true);
    }
}
