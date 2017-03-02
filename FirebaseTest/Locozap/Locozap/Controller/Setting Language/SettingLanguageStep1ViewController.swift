/**
 * SettingLanguageStep1ViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON


class SettingLanguageStep1ViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    static let TYPE_EDIT_DEFAULT = 0;
    static let TYPE_EDIT_NOT_DEFAULT = 1;
    static let TYPE_ADD = 2;
    @IBOutlet weak var mTblView: UITableView!
    @IBOutlet weak var mViewSearch: UIView!
    @IBOutlet weak var edTextSearch: UITextField!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnClear: UIButton!
    var arrayLanguage : [Language]!;
    var filteredLanguage : [Language] = [Language]();
    var typeEditOrAdd : Int!;
    var languageEdit : Language!;
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false);
        initView();
        getAllLanguage()
        
        self.addDoneButton();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Init view 
    func initView(){
         self.arrayLanguage = [Language]();
        mViewSearch.layer.cornerRadius = 5;
        self.mTblView.delegate = self;
        self.mTblView.dataSource = self;
        // Register cell
        let nibCell1 = UINib(nibName: "CellSettingLanguageStep1", bundle: nil);
        self.mTblView.register(nibCell1, forCellReuseIdentifier: "mCell");
        
        btnBack.setTitle(StringUtilities.getLocalizedString("cancel", comment: ""), for: UIControlState.normal);
        lblTitle.text = StringUtilities.getLocalizedString("language_level_add_language", comment: "");
        btnClear.setTitle(StringUtilities.getLocalizedString("btn_clear", comment: ""), for: UIControlState.normal);
        edTextSearch.placeholder = StringUtilities.getLocalizedString("search", comment: "");
    }
    
    @IBAction func textFieldDidChange(_ sender: Any) {
        filterContentForSearchText(searchText: edTextSearch.text!);
//         print("Text changed: " + edTextSearch.text! + "\n")
    }
    
    func getAllLanguage(){
        self.arrayLanguage.removeAll();
        var arrayLanguageCurrent : [Language] = [Language]();
        if(mUser != nil) {
            arrayLanguageCurrent = (mUser?.language)!;
        }
        self.arrayLanguage = LanguageUtils.getListLanguageNameNotExistListLanguageCode(arrayLanguageCode: arrayLanguageCurrent);
        self.mTblView.reloadData();
    }
    @IBAction func pressCancel(_ sender: Any) {
        edTextSearch.text = "";
        filterContentForSearchText(searchText: "");
    }
    
    @IBAction func pressBack(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
    
    
    // MARK: Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var language : Language!;
        if(edTextSearch.text! == ""){
            language = self.arrayLanguage[indexPath.row];
        } else {
            language = self.filteredLanguage[indexPath.row];
        }
        switch typeEditOrAdd {
        case (SettingLanguageStep1ViewController.TYPE_EDIT_DEFAULT)?:
            editLanguageDefault(languageUpdate:language);
            break;
            
        case (SettingLanguageStep1ViewController.TYPE_EDIT_NOT_DEFAULT)?:
            let settingLanguageStep2 = SettingLanguageStep2ViewController();
            settingLanguageStep2.languageValue = language;
            settingLanguageStep2.languageEdit = languageEdit;
            self.navigationController?.pushViewController(settingLanguageStep2, animated: true);
            break;
            
        case (SettingLanguageStep1ViewController.TYPE_ADD)?:
            let settingLanguageStep2 = SettingLanguageStep2ViewController();
            settingLanguageStep2.languageValue = language;
            self.navigationController?.pushViewController(settingLanguageStep2, animated: true);
            break;
        default:
            break;
        }
    }
    
    // MARK: Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(edTextSearch.text! == ""){
            return self.arrayLanguage.count;
        } else {
           return filteredLanguage.count;
        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var language : Language!;
        if(edTextSearch.text! == ""){
            language = self.arrayLanguage[indexPath.row];
        } else {
            language = self.filteredLanguage[indexPath.row];
        }
        
        let mCell = self.mTblView.dequeueReusableCell(withIdentifier: "mCell") as! CellSettingLanguageStep1;
        mCell.selectionStyle = UITableViewCellSelectionStyle.none;
        mCell.cellNameLanguage.text = language.nameLanguage;
        mCell.cellDescriptionLanguage.text = language.descriptionLanguage;
        return mCell;
    }
    
    // MARK: Common edit language
    // Edit language default
    func editLanguageDefault(languageUpdate : Language){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let user = appDelegate.mUser;
        user?.language?[0].nameLanguage = languageUpdate.nameLanguage;
        user?.language?[0].descriptionLanguage = languageUpdate.descriptionLanguage;
        user?.language?[0].codeLanguage = languageUpdate.codeLanguage;
        let mLanguageCurrent = user?.language;
        var arrayDictLanguage : Array = Array<Any>();
        for language in mLanguageCurrent!{
            var dictLanguage : Dictionary = Dictionary<String, Any>();
            dictLanguage = Utils.createDictionaryLanguage(obj: language);
            arrayDictLanguage.append(dictLanguage);
        }
        callApiUpdateLanguage(arrayDictLanguage: arrayDictLanguage);
    }
    
    func callApiUpdateLanguage(arrayDictLanguage : Array<Any>){
        var params : Dictionary = Dictionary<String, Any>();
        if (mUser != nil) {
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
            if ((self.navigationController as! NavigationSettingLanguageViewController).delegateSettingLanguage != nil){
                (self.navigationController as! NavigationSettingLanguageViewController).delegateSettingLanguage?.didCompleteSettingLanguage();
            }
            self.dismiss(animated: true, completion: nil);
        }) { (Error) in
            // Error
        }
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredLanguage = self.arrayLanguage.filter({( language : Language) -> Bool in
            if((language.nameLanguage?.lowercased().contains(searchText.lowercased()))! || (language.descriptionLanguage?.lowercased().contains(searchText.lowercased()))!){
                return true;
            } else {
                return false;
            }
        })
        self.mTblView.reloadData()
    }
    
    func addDoneButton() {
        let keyboardToolbar = UIToolbar();
        keyboardToolbar.sizeToFit();
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)));
        keyboardToolbar.items = [flexBarButton, doneBarButton];
        self.edTextSearch.inputAccessoryView = keyboardToolbar;
    }
}
