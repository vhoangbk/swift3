/**
 * PostsActivityViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import DatePickerDialog

class PostsActivityViewController: BaseViewController, UITextViewDelegate {
    @IBOutlet weak var edTitleTopic: UITextView!
    @IBOutlet weak var edDescriptionTopic: UITextView!
//    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var mViewToolbar: UIView!
    @IBOutlet weak var mViewStatusbar: UIView!
    @IBOutlet weak var mIconTopic: UIImageView!
//    @IBOutlet weak var heightTitle: NSLayoutConstraint!
//    @IBOutlet weak var heightDescription: NSLayoutConstraint!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var scrollViewContent: UIScrollView!
//    @IBOutlet var viewContentScroll: UIView!
    @IBOutlet weak var viewDateTime: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblLanguage: UILabel!
    
    var positionLanguage : Int = 1;
    var colorTabBar : UIColor!;
    var typeTopic : Int!;
    
    private var arrayLanguage: Array<Language> = Array<Language>();

    override func viewDidLoad() {
        super.viewDidLoad()
        initView();
//        self.updateUI();
        self.addDoneButton();
//        scrollViewContent.addSubview(viewContentScroll);
        // Do any additional setup after loading the view.
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(PostsActivityViewController.adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(PostsActivityViewController.adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollViewContent.contentInset = UIEdgeInsets.zero
        } else {
            scrollViewContent.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        scrollViewContent.scrollIndicatorInsets = scrollViewContent.contentInset
    }

    // MARK: Init view
    func initView(){
        mViewToolbar.backgroundColor = colorTabBar;
        mViewStatusbar.backgroundColor = colorTabBar;
        mIconTopic.image = Utils.getTopicFormType(typeTopic: typeTopic);
        if(mUser != nil) {
            if(mUser?.language != nil) {
               let arrayLanguage = LanguageUtils.getListLanguageNameFromListLanguageCodeCurrentLocale(arrayLanguageCode: (mUser?.language)!);
                self.lblLanguage.text =  arrayLanguage[0].descriptionLanguage;
                self.lblLanguage.tag = 1;
            }
        }
        
        self.lblDate.text = StringUtilities.getLocalizedString("activity_post_today", comment: "");
        
        // Set delegate UITextView
        edTitleTopic.delegate = self;
        edDescriptionTopic.delegate = self;
        // Set placeholder UITextView
        edTitleTopic.text = StringUtilities.getLocalizedString("activity_post_enter_title", comment: "");
        edTitleTopic.textColor = UIColor.lightGray;
        edDescriptionTopic.textColor = UIColor.lightGray;
        edDescriptionTopic.text = StringUtilities.getLocalizedString("activity_post_enter_contents", comment: "");
        // Remove top space UITextView
        edTitleTopic.textContainerInset = UIEdgeInsets.zero;
        edDescriptionTopic.textContainerInset = UIEdgeInsets.zero;
        
        // init header
        self.btnBack.setTitle(StringUtilities.getLocalizedString("cancel", comment: ""), for: UIControlState.normal);
        self.btnNext.setTitle(StringUtilities.getLocalizedString("next", comment: ""), for: UIControlState.normal);
        lblTitle.text = StringUtilities.getLocalizedString("activity_post_title", comment: "");
        lblContent.text = StringUtilities.getLocalizedString("activity_post_content", comment: "");
        
        self.initLanguage();
    }
    
    @IBAction func chosenLanguage(_ sender: Any) {
        let count = self.arrayLanguage.count;
        if (count > 1) {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            for index in 0..<count {
                let language = self.arrayLanguage[index];
                let languageAction = UIAlertAction(title: language.descriptionLanguage, style: .default) { (action) in
                    self.lblLanguage.text = language.descriptionLanguage;
                    self.lblLanguage.tag = index + 1;
                };
                alertController.addAction(languageAction);
            }
            
            self.present(alertController, animated: true) {
                // ...
            }
        }
    }
    
    func initLanguage(){
        if(mUser != nil) {
            self.arrayLanguage = Array<Language>();
            self.arrayLanguage = LanguageUtils.getListLanguageNameFromListLanguageCodeCurrentLocale(arrayLanguageCode: (mUser?.language)!);
            
            let count = self.arrayLanguage.count;
            if (count == 1) {
                let language = self.arrayLanguage[0];
                self.lblLanguage.text = language.descriptionLanguage;
                self.lblLanguage.tag = 1;
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if(textView == edTitleTopic){
            if(self.edTitleTopic.text.characters.count == 0) {
                edTitleTopic.textColor = UIColor.lightGray;
            } else {
                edTitleTopic.textColor = colorTabBar;
//                let height = (textView.text!).heightWithConstrainedWidth(width: self.viewContent.frame.size.width, font: UIFont(name:(self.edTitleTopic.font?.fontName)!, size: (self.edTitleTopic.font?.pointSize)!)!);
//                self.heightTitle.constant = height + CGFloat(10);
                
            }
        } else {
            if(self.edDescriptionTopic.text.characters.count == 0) {
                self.edDescriptionTopic.textColor = UIColor.lightGray;
            } else {
//                let height = (textView.text!).heightWithConstrainedWidth(width: self.viewContent.frame.size.width, font: UIFont(name:(self.edDescriptionTopic.font?.fontName)!, size: (self.edDescriptionTopic.font?.pointSize)!)!);
//                self.heightDescription.constant = height + CGFloat(10);
                self.edDescriptionTopic.textColor = UIColor.black;
            }
        }
//        self.updateUI();
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView == edTitleTopic){
            if(self.edTitleTopic.text.characters.count == 0) {
                self.edTitleTopic.text = StringUtilities.getLocalizedString("activity_post_enter_title", comment: "")
            }
        } else {
            if(self.edDescriptionTopic.text.characters.count == 0) {
                self.edDescriptionTopic.text = StringUtilities.getLocalizedString("activity_post_enter_contents", comment: "")
            }
        }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView == edTitleTopic){
            if(self.edTitleTopic.text == StringUtilities.getLocalizedString("activity_post_enter_title", comment: "")) {
                self.edTitleTopic.text = "";
            }
        } else {
            if(self.edDescriptionTopic.text == StringUtilities.getLocalizedString("activity_post_enter_contents", comment: "")) {
                self.edDescriptionTopic.text = "";
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        if(textView == edTitleTopic){
            return numberOfChars <= 100;
        } else {
            return numberOfChars <= 2000;
        }
    }
    
    // MARK : Onclick button view
    @IBAction func pressChooseDate(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let todayAction = UIAlertAction(title: StringUtilities.getLocalizedString("activity_post_today", comment: ""), style: .default) { (action) in
            self.lblDate.text = StringUtilities.getLocalizedString("activity_post_today", comment: "");
        }
        
        let tomorrowAction = UIAlertAction(title: StringUtilities.getLocalizedString("activity_post_tomorrow", comment: ""), style: .default) { (action) in
            self.lblDate.text = StringUtilities.getLocalizedString("activity_post_tomorrow", comment: "");
        }
        
        let postDateSpecifiedAction = UIAlertAction(title: StringUtilities.getLocalizedString("activity_post_date_specified", comment: ""), style: .default) { (action) in
            DatePickerDialog().show(StringUtilities.getLocalizedString("datepicker", comment: ""), doneButtonTitle: StringUtilities.getLocalizedString("btn_ok", comment: ""), cancelButtonTitle: StringUtilities.getLocalizedString("cancel", comment: ""), datePickerMode: .date) {
                (date) -> Void in
                if(date != nil){
                    if(DateTimeUtils.currentTimeYearMonthDayLessDateInput(dateInput: date! as Date)){
                        self.lblDate.text = DateTimeUtils.getDateFromLimitDatePiker(dateInput: date! as Date);
                        
                    } else {
                        Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("post_time_validate", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
                    }
                }
            }
        }
        
        alertController.addAction(todayAction)
        alertController.addAction(tomorrowAction)
        alertController.addAction(postDateSpecifiedAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    @IBAction func pressBack(_ sender: Any) {
        if ((self.navigationController?.viewControllers.count)! > 1){
            self.navigationController!.popViewController(animated: true);
        }else{
            dismiss(animated: false, completion: nil);
        }
    }
    
    // Click button continue
    @IBAction func pressContinue(_ sender: Any) {
        if(isValidate()){
            self.edTitleTopic.resignFirstResponder();
            self.edDescriptionTopic.resignFirstResponder();
            let postTopicStep1VC = PostsActivityStep1ViewController();
            postTopicStep1VC.titleTopic = self.edTitleTopic.text.trim();
            postTopicStep1VC.descriptionTopic = self.edDescriptionTopic.text.trim();
            let(typeDate, valueDate) = getDateCreateTopicType(textDate: self.lblDate.text!);
            postTopicStep1VC.typeDateTopic = typeDate;
            postTopicStep1VC.valueTypeDateTopic = valueDate;
            postTopicStep1VC.colorTabBar = colorTabBar;
            postTopicStep1VC.countryLanguageTopic = self.getCountryLanguage();
            postTopicStep1VC.typeTopic = typeTopic;
            self.navigationController?.pushViewController(postTopicStep1VC, animated: true);
        }
    }
    
    func getDateCreateTopicType(textDate : String) -> (typeDate : Int, valueDate : String){
        if(textDate == StringUtilities.getLocalizedString("activity_post_today", comment: "")) {
            return (Const.TOPIC_DATE_TODAY, textDate);
        } else if (textDate == StringUtilities.getLocalizedString("activity_post_tomorrow", comment: "")) {
            return (Const.TOPIC_DATE_TOMORROW, textDate);
        } else {
            return (Const.TOPIC_DATE_SPECIFICATION, textDate);
        }
    }
    
    func getCountryLanguage() -> String? {
        let indexLanguage = self.lblLanguage.tag;
        if (indexLanguage > 0) {
            return self.arrayLanguage[indexLanguage - 1].codeLanguage;
        } else {
            return nil;
        }
    }
    
    // Validate pass screen
    func isValidate() -> Bool {
        if (self.edTitleTopic.text.trim().isEmpty) {
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("post_title_name_empty", comment: ""), titleButtonClose: "", titleButtonOk:
                StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        
        if (self.edTitleTopic.text.trim() == StringUtilities.getLocalizedString("activity_post_enter_title", comment: "")) {
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("post_title_name_empty", comment: ""), titleButtonClose: "", titleButtonOk:
                StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        
        if(self.edDescriptionTopic.text.trim().isEmpty) {
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("post_content_empty", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        
        if(self.edDescriptionTopic.text.trim() == StringUtilities.getLocalizedString("activity_post_enter_contents", comment: "")) {
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("post_content_empty", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        
        if(self.getCountryLanguage() == nil) {
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("post_language_empty", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        
        return true;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false);
    }
    
//    func updateUI(){
//        let heightTitle = self.lblTitle.intrinsicContentSize.height;
//        let heightContentTitle = self.edTitleTopic.intrinsicContentSize.height;
//        let heightDescriptionTopic = self.lblContent.intrinsicContentSize.height;
//        let heightContentDescriptionTopic = self.heightDescription.constant + 10;
//        let HeightViewDateTime = self.viewDateTime.bounds.height;
//        let HeightViewLanguage = HeightViewDateTime;
//        let hieghtContentView = heightTitle + heightContentTitle + heightDescriptionTopic + heightContentDescriptionTopic + HeightViewDateTime + HeightViewLanguage + 100;
//        self.viewContentScroll.frame = CGRect(x: self.viewContentScroll.frame.origin.x, y: self.viewContentScroll.frame.origin.y, width: UIScreen.main.bounds.width - 40, height: hieghtContentView);
//        self.scrollViewContent.contentSize = CGSize(width: UIScreen.main.bounds.width - 40, height: hieghtContentView);
//    }
    
    func addDoneButton() {
        let keyboardToolbar = UIToolbar();
        keyboardToolbar.sizeToFit();
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)));
        keyboardToolbar.items = [flexBarButton, doneBarButton];
        self.edTitleTopic.inputAccessoryView = keyboardToolbar;
        self.edDescriptionTopic.inputAccessoryView = keyboardToolbar;
    }
}
