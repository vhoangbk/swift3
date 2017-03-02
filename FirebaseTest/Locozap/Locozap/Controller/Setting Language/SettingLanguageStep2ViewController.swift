/**
 * SettingLanguageStep2ViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON

class SettingLanguageStep2ViewController: BaseViewController, RatingBarDelegate{
    @IBOutlet weak var mRatingbar: RatingBar!
    @IBOutlet weak var mLblLevelLanguage: UILabel!
    @IBOutlet weak var mLblDescriptionLanguage: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var constraintWidthDone: NSLayoutConstraint!
    @IBOutlet weak var constraintWidthBack: NSLayoutConstraint!
    var languageValue : Language!;
    var languageEdit : Language!;
    var ratingValue : Int = 1;
    
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
        mRatingbar.delegate = self;
        mRatingbar.isSlectStart = true;
        languageValue.level = 1;
        
        btnBack.setTitle(StringUtilities.getLocalizedString("language_level_back", comment: ""), for: UIControlState.normal);
        btnDone.setTitle(StringUtilities.getLocalizedString("done", comment: ""), for: UIControlState.normal);
        lblTitle.text = StringUtilities.getLocalizedString("language_level_add_language_level", comment: "");
        lblLanguage.text = languageValue.nameLanguage!;
        lblNote.text = StringUtilities.getLocalizedString("language_level_note", comment: "");
        mLblLevelLanguage.text = StringUtilities.getLocalizedString("degree_language_level_1", comment: "");
        mLblDescriptionLanguage.text = StringUtilities.getLocalizedString("degree_language_level_1_describe", comment: "");
    }

    @IBAction func pressBack(_ sender: Any) {
        self.navigationController!.popViewController(animated: true);
    }
    
    @IBAction func pressDone(_ sender: Any) {
        callApiRegisterLanguage();
    }
    
    func ratingDidChange(ratingBar: RatingBar, rating: CGFloat) {
        self.ratingValue = Int(rating);
        languageValue.level = self.ratingValue;
        if(self.ratingValue == 1){
            mLblLevelLanguage.text = StringUtilities.getLocalizedString("degree_language_level_1", comment: "");
            mLblDescriptionLanguage.text = StringUtilities.getLocalizedString("degree_language_level_1_describe", comment: "");
        } else if (self.ratingValue == 2) {
            mLblLevelLanguage.text = StringUtilities.getLocalizedString("degree_language_level_2", comment: "");
            mLblDescriptionLanguage.text = StringUtilities.getLocalizedString("degree_language_level_2_describe", comment: "");
        } else if (self.ratingValue == 3) {
            mLblLevelLanguage.text = StringUtilities.getLocalizedString("degree_language_level_3", comment: "");
            mLblDescriptionLanguage.text = StringUtilities.getLocalizedString("degree_language_level_3_describe", comment: "");
        }
    }
    
    
    // MARK : Call API register or update language
    
    func callApiRegisterLanguage(){
        var params : Dictionary = Dictionary<String, Any>();
        if(languageEdit == nil){
            if (mUser != nil) {
                var arrayDictLanguage : Array = Array<Any>();
                var mLanguageCurrent = mUser?.language;
                mLanguageCurrent?.append(languageValue);
                for language in mLanguageCurrent!{
                    var dictLanguage : Dictionary = Dictionary<String, String>();
                    dictLanguage = Utils.createDictionaryLanguage(obj: language);
                    arrayDictLanguage.append(dictLanguage);
                }
                params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
                params.updateValue(arrayDictLanguage, forKey: Const.KEY_PARAMS_LANGUAGE);
            }
        } else {
            if (mUser != nil) {
                var arrayDictLanguage : Array = Array<Any>();
                var mLanguageCurrent = mUser?.language;
                mLanguageCurrent?.append(languageValue);
                for index in 0..<mLanguageCurrent!.count{
                    if(mLanguageCurrent?[index].codeLanguage != languageEdit.codeLanguage) {
                        var dictLanguage : Dictionary = Dictionary<String, Any>();
                        let languageAdd = mLanguageCurrent![index];
                        dictLanguage = Utils.createDictionaryLanguage(obj: languageAdd);
                        arrayDictLanguage.append(dictLanguage);
                    }
                }
                params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
                params.updateValue(arrayDictLanguage, forKey: Const.KEY_PARAMS_LANGUAGE);
            }
        }
        APIClient.sharedInstance.postRequest(Url: URL_UPDATE_USER, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success) in
            // Success
            let responseJson = JSON(success)["data"];
            Utils.setInfoAccount(infoAccount: NSKeyedArchiver.archivedData(withRootObject: responseJson.rawValue) as AnyObject?);
            let paserHelper : ParserHelper = ParserHelper();
            let user = paserHelper.parserUser(data: responseJson);
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            appDelegate.mUser = user;
            self.mUser = user;
            if ((self.navigationController as! NavigationSettingLanguageViewController).delegateSettingLanguage != nil){
                (self.navigationController as! NavigationSettingLanguageViewController).delegateSettingLanguage?.didCompleteSettingLanguage();
            }
            self.dismiss(animated: true, completion: nil);
        }) { (Error) in
            // Error
        }
    }
 }
