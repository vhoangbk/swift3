/**
 * MyProfileViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON

class MyProfileViewController: BaseViewController {
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbLikeNumber: UILabel!
    
    @IBOutlet weak var ratingbar1: RatingBar!
    @IBOutlet weak var ratingbar2: RatingBar!
    @IBOutlet weak var ratingbar3: RatingBar!
    
    @IBOutlet weak var lbLang1: UILabel!
    @IBOutlet weak var lbLang2: UILabel!
    @IBOutlet weak var lbLang3: UILabel!
    
    @IBOutlet weak var viewLanguage1: UIView!
    @IBOutlet weak var viewLanguage2: UIView!
    @IBOutlet weak var viewLanguage3: UIView!
    
    @IBOutlet weak var viewSpace: UIView!
    
    @IBOutlet weak var btnPremium: UIButton!
    @IBOutlet weak var viewLanguage: UIView!
    
    @IBOutlet weak var lblInfor: UILabel!
    @IBOutlet weak var lblBirthday: UILabel!
    @IBOutlet weak var lblBirthdayDate: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblGenderName: UILabel!
    
    var arrayGender : [String]?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView();
    }
    
    func initView() {
        let unknown : String = StringUtilities.getLocalizedString("unknown", comment: "");
        let male : String = StringUtilities.getLocalizedString("male", comment: "");
        let female : String = StringUtilities.getLocalizedString("female", comment: "");
        self.arrayGender = [unknown, male, female];
        lbLang1.text = StringUtilities.getLocalizedString("unknown", comment: "");
        lbLang2.text = StringUtilities.getLocalizedString("unknown", comment: "");
        lbLang3.text = StringUtilities.getLocalizedString("unknown", comment: "");
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        if(mUser == nil || mUser?.apiKey == nil){
            lbName.text = StringUtilities.getLocalizedString("guest_user", comment: "");
            btnPremium.setTitle(StringUtilities.getLocalizedString("premium_service", comment: ""), for: UIControlState.normal);
            btnPremium.isHidden = false;
            viewSpace.isHidden = true;
            return;
        }
        
        btnPremium.isHidden = true;
        self.lblBirthday.text = StringUtilities.getLocalizedString("birthday", comment: "");
        self.lblGender.text = StringUtilities.getLocalizedString("sex", comment: "");
        viewSpace.isHidden = false;
        self.callApiUserInfo();

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressSettingProfile(_ sender: Any) {
        if(mUser == nil || mUser?.apiKey == nil){
            let settingWithoutLoginVC = SettingSettingWithoutLoginViewController();
            self.navigationController?.pushViewController(settingWithoutLoginVC, animated: true);
            return;
        }
        let settingVC = SettingViewController();
        self.navigationController?.pushViewController(settingVC, animated: true);
    }
    
    func callApiUserInfo() {
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue((mUser?.id)!, forKey: Const.KEY_PARAMS_USER_ID);
        
        APIClient.sharedInstance.postRequest(Url: URL_USER_INFO, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
            
            let responseJson = JSON(success)["data"];
            let paserHelper : ParserHelper = ParserHelper();
            
            self.mUser = paserHelper.parserUser(data: responseJson);
            self.mUser?.apiKey = Utils.getApiKey();
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            
            appDelegate.mUser = self.mUser;
            
            self.updateUI();
            
        }) { (error : AnyObject?) in
            
        }
    }
    
    func updateUI() {
        if(mUser?.avatarMedium != nil) {
            self.imgAvatar.sd_setImage(with: URL(string: (mUser?.avatarMedium)!), placeholderImage: UIImage.init(named: "avatar_no_image"));
        }else{
            self.imgAvatar.image = UIImage.init(named: "avatar_no_image");
        }
        
        imgFlag.image = Utils.getFlagCountry(code: (mUser?.codeCountry)!);
        lbName.text = Utils.getFullName(user: mUser!);
        lbAddress.text = mUser?.address;
     
        if ( (mUser?.like)! > 1000){
            lbLikeNumber.text = "10k"
        }else{
            lbLikeNumber.text = String(describing: (mUser?.like)!);
        }
        
        viewLanguage1.isHidden = false;
        viewLanguage2.isHidden = true;
        viewLanguage3.isHidden = true;
        for i in 0..<(mUser?.language?.count)! {
            let lang = mUser?.language?[i];
            if ( i == 0 ){
                ratingbar1.rating = CGFloat((lang?.level)!);
                if(lang?.codeLanguage != nil) {
                    lbLang1.text = LanguageUtils.getLanguageNameFromLanguageCode(languageCode: (lang?.codeLanguage)!);
                }
            }
            
            if ( i == 1 ){
                ratingbar2.rating = CGFloat((lang?.level)!);
                if(lang?.codeLanguage != nil) {
                    lbLang2.text = LanguageUtils.getLanguageNameFromLanguageCode(languageCode: (lang?.codeLanguage)!);
                }
                viewLanguage2.isHidden = false;
            }
            
            if ( i == 2 ){
                ratingbar3.rating = CGFloat((lang?.level)!);
                if(lang?.codeLanguage != nil) {
                    lbLang3.text = LanguageUtils.getLanguageNameFromLanguageCode(languageCode: (lang?.codeLanguage)!);
                }
                viewLanguage3.isHidden = false;
            }
        }
        
        // Update contrain language
        self.updateContrainLanguage();
        
        self.lblInfor.text = mUser?.introduction;

        if (mUser?.birthday != nil) {
            self.lblBirthday.isHidden = false;
            self.lblBirthdayDate.isHidden = false;
            let birthday = Date(timeIntervalSince1970: TimeInterval((mUser?.birthday)!));
            self.lblBirthdayDate.text =  DateTimeUtils.convertDateToString(date: birthday);
        } else {
            self.lblBirthday.isHidden = true;
            self.lblBirthdayDate.isHidden = true;
        }
        
        if ( mUser?.sex != nil && mUser?.sex != 1) {
            self.lblGender.isHidden = false;
            self.lblGenderName.isHidden = false;
            lblGenderName.text = self.arrayGender?[((mUser?.sex)! - 1)];
        } else {
            self.lblGender.isHidden = true;
            self.lblGenderName.isHidden = true;
        }

        let language = NSLocale.preferredLanguages.first;
        if language?.hasPrefix("ja") == true {
            
        } else {
            self.lblInfor?.font = UIFont.systemFont(ofSize: (self.lblInfor?.font.pointSize)!);
        }
    }
    
    /**
     * Update contrain language
     */
    func updateContrainLanguage(){
        if(mUser?.language?.count == 1) {
            viewLanguage1.frame = CGRect(x: viewLanguage1.frame.origin.x, y: viewLanguage1.frame.origin.y, width: UIScreen.main.bounds.width, height: viewLanguage1.frame.size.height);
            viewLanguage1.translatesAutoresizingMaskIntoConstraints = true;
        } else if (mUser?.language?.count == 2) {
            viewLanguage1.frame = CGRect(x: viewLanguage1.frame.origin.x, y: viewLanguage1.frame.origin.y, width: UIScreen.main.bounds.width/2, height: viewLanguage1.frame.size.height);
            viewLanguage1.translatesAutoresizingMaskIntoConstraints = true;
            
            viewLanguage2.frame = CGRect(x: viewLanguage1.frame.size.width, y: viewLanguage2.frame.origin.y, width: UIScreen.main.bounds.width/2, height: viewLanguage2.frame.size.height);
            viewLanguage2.translatesAutoresizingMaskIntoConstraints = true;
        } else {
            viewLanguage1.frame = CGRect(x: viewLanguage1.frame.origin.x, y: viewLanguage1.frame.origin.y, width: UIScreen.main.bounds.width/3, height: viewLanguage1.frame.size.height);
            viewLanguage1.translatesAutoresizingMaskIntoConstraints = true;
            
            viewLanguage2.frame = CGRect(x: viewLanguage1.frame.size.width, y: viewLanguage2.frame.origin.y, width: UIScreen.main.bounds.width/3, height: viewLanguage2.frame.size.height);
            viewLanguage2.translatesAutoresizingMaskIntoConstraints = true;
            
            viewLanguage3.frame = CGRect(x: (viewLanguage1.frame.size.width * 2) , y: viewLanguage3.frame.origin.y, width: UIScreen.main.bounds.width/3, height: viewLanguage3.frame.size.height);
            viewLanguage3.translatesAutoresizingMaskIntoConstraints = true;
        }
    }
    
    @IBAction func pressPremium(_ sender: Any) {
        self.navigationController?.pushViewController(PremiumViewController(), animated: true);
    }
    
}
