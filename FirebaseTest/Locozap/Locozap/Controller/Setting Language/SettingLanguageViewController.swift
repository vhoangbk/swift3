/**
 * SettingLanguageViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON

class SettingLanguageViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, DelegateCellSettingLanguage, DelegateSettingLanguageViewController {
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var mTblView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMainContent: UILabel!
    @IBOutlet weak var constraintTableHeight: NSLayoutConstraint!
    var countryCode : String?;
    var arrayLanguage : [Language]!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false);
        initView();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints();
        self.updateHeightTableView();
    }
    
    private func updateHeightTableView() {
        constraintTableHeight.constant = mTblView.contentSize.height;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Init view 
    func initView(){
        self.mTblView.delegate = self;
        self.mTblView.dataSource = self;
        
        self.mTblView.layer.borderColor = UIColor(netHex: Const.COLOR_BDBDBD).cgColor;
        self.mTblView.layer.borderWidth = 0.5;
        // Register cell
        let nibCell1 = UINib(nibName: "CellSettingLanguage", bundle: nil);
        self.mTblView.register(nibCell1, forCellReuseIdentifier: "mCell");
        if(mUser != nil) {
            getAllLanguage(user: mUser!);
        }
        
        btnCancel.setTitle(StringUtilities.getLocalizedString("setting", comment: ""), for: UIControlState.normal);
        lblTitle.text = StringUtilities.getLocalizedString("language_level_title", comment: "");
        lblMainContent.text = StringUtilities.getLocalizedString("language_level_content", comment: "");
        
        if (DeviceUtil.hardware() == .IPHONE_5 || DeviceUtil.hardware() == .IPHONE_5C
            || DeviceUtil.hardware() == .IPHONE_5S || DeviceUtil.hardware() == .IPHONE_SE){
            lblTitle.font = UIFont.systemFont(ofSize: 14);
        }
    }
    
    func getAllLanguage(user : User){
        self.arrayLanguage = [Language]();
        var arrayLanguageCurrent : [Language] = [Language]();
        arrayLanguageCurrent = (user.language)!;
        if(arrayLanguageCurrent.count > 0){
           self.arrayLanguage = LanguageUtils.getListLanguageNameFromListLanguageCode(arrayLanguageCode: arrayLanguageCurrent);
        }
        self.mTblView.reloadData();
        self.updateHeightTableView();
    }
    
    @IBAction func pressBack(_ sender: Any) {
        self.navigationController!.popViewController(animated: true);
    }
    
    @IBAction func pressAdd(_ sender: Any) {
        if(self.arrayLanguage.count < 3) {
            let settingLanguageStep1 = SettingLanguageStep1ViewController();
            settingLanguageStep1.typeEditOrAdd = SettingLanguageStep1ViewController.TYPE_ADD;
            let naviSettingLangague = NavigationSettingLanguageViewController(rootViewController: settingLanguageStep1);
            naviSettingLangague.delegateSettingLanguage = self;
            present(naviSettingLangague, animated: true, completion: nil);
        } else {
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("note_setting_fragment_add_level_language", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
        }
    }
    
    
    // MARK : Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = self.arrayLanguage[indexPath.row];
        let settingLanguageStep1 = SettingLanguageStep1ViewController();
        if(indexPath.row == 0) {
            settingLanguageStep1.typeEditOrAdd = SettingLanguageStep1ViewController.TYPE_EDIT_DEFAULT;
        } else {
            settingLanguageStep1.languageEdit = language;
            settingLanguageStep1.typeEditOrAdd = SettingLanguageStep1ViewController.TYPE_EDIT_NOT_DEFAULT;
        }
        let naviSettingLangague = NavigationSettingLanguageViewController(rootViewController: settingLanguageStep1);
        naviSettingLangague.delegateSettingLanguage = self;
        present(naviSettingLangague, animated: true, completion: nil);
    }
    
    // MARK : Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayLanguage.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let language = self.arrayLanguage[indexPath.row];
        let mCell = self.mTblView.dequeueReusableCell(withIdentifier: "mCell") as! CellSettingLanguage;
        mCell.selectionStyle = UITableViewCellSelectionStyle.none;
        mCell.nameLanguage.text = language.descriptionLanguage;
        mCell.levelLanguage.rating = CGFloat(language.level!);
        if (indexPath.row == 0) {
            mCell.btnDelete.isHidden = true;
            mCell.levelLanguage.imageLight = UIImage(named: "ic_start_red")!;
        } else {
            mCell.btnDelete.isHidden = false;
            mCell.levelLanguage.imageLight = UIImage(named: "ic_start_activated")!;
        }
        mCell.delegateCellSettingLanguage = self;
        mCell.mLanguage = language;
        return mCell;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    // MARK : Delegate custom
    func didSelectDeleteSettingLanguage(language: Language) {
        if(self.arrayLanguage.count == 1) {
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("not_remove_all_language_setting", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
        } else {
            callApiDeleteLanguage(language: language);
        }
    }
    
    func didCompleteSettingLanguage() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        self.getAllLanguage(user: appDelegate.mUser!);
        self.mUser = appDelegate.mUser!;
    }
    
    
    // MARK : Call api
    func callApiDeleteLanguage(language: Language){
        var params : Dictionary = Dictionary<String, Any>();
        if (mUser != nil) {
            var arrayDictLanguage : Array = Array<Any>();
            var mLanguageCurrent = mUser?.language;
            for index in 0..<(mLanguageCurrent?.count)!  {
                if(mLanguageCurrent?[index].codeLanguage == language.codeLanguage) {
                    mLanguageCurrent?.remove(at: index);
                    break;
                }
            }
            
            for language in mLanguageCurrent!{
                var dictLanguage : Dictionary = Dictionary<String, Any>();
                dictLanguage = Utils.createDictionaryLanguage(obj: language);
                arrayDictLanguage.append(dictLanguage);
            }
            params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
            params.updateValue(arrayDictLanguage, forKey: Const.KEY_PARAMS_LANGUAGE);
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
            self.getAllLanguage(user: user);
        }) { (Error) in
            // Error
        }
    }
}
