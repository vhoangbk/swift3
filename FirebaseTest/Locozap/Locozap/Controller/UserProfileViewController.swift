/**
 * UserProfileViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON

class UserProfileViewController: BaseViewController {
    
    @IBOutlet weak var lbBlock: UILabel!

    var userAround : User = User.init();
    
    var isCanChat : Bool = true;
    
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
    
    
    @IBOutlet weak var lblInfor: UILabel!
    @IBOutlet weak var lblBirthday: UILabel!
    @IBOutlet weak var lblBirthdayDate: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblGenderName: UILabel!
    
    @IBOutlet weak var lbChat: UILabel!
    @IBOutlet weak var constraintCenterHorizontalViewLike: NSLayoutConstraint!
    
    var arrayGender : [String]?;

    @IBOutlet weak var btnBlock: UIButton!
    @IBOutlet weak var viewChat: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        appDelegate.screenPosition = AppDelegate.USER_PROFILE_POSITION;
        
        self.navigationController?.setNavigationBarHidden(true, animated: true);
    
        self.callApiUserInfo();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initView() {
        let unknown : String = StringUtilities.getLocalizedString("unknown", comment: "");
        let male : String = StringUtilities.getLocalizedString("male", comment: "");
        let female : String = StringUtilities.getLocalizedString("female", comment: "");
        self.arrayGender = [unknown, male, female];
        
        self.lblBirthday.text = StringUtilities.getLocalizedString("birthday", comment: "");
        self.lblGender.text = StringUtilities.getLocalizedString("sex", comment: "");
        
        lbLang1.text = StringUtilities.getLocalizedString("unknown", comment: "");
        lbLang2.text = StringUtilities.getLocalizedString("unknown", comment: "");
        lbLang3.text = StringUtilities.getLocalizedString("unknown", comment: "");
		
		if (mUser == nil) {
			self.btnBlock.isHidden = true;
			
		} else {
			if (mUser?.id == userAround.id || !self.isCanChat){
				self.btnBlock.isHidden = true;
                viewChat.isHidden = true;
                self.constraintCenterHorizontalViewLike.constant = 0;
			}else{
				self.btnBlock.isHidden = false;
                viewChat.isHidden = false;
			}
		}
        
        lbChat.text = StringUtilities.getLocalizedString("button_chat", comment: "");
        
        //tap chat
        let tapChat = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.pressChat))
        viewChat.addGestureRecognizer(tapChat)
        
        //tap avatar
        let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.pressAvatar))
        imgAvatar.isUserInteractionEnabled = true;
        imgAvatar.addGestureRecognizer(tapAvatar)
        
    }
    
    func pressAvatar() {
        if (mUser != nil && mUser?.id == userAround.id){
            return;
        }
        let infoVC = InfoProfileViewController();
        infoVC.user = userAround;
        self.navigationController?.pushViewController(infoVC, animated: true);
    }
    
    // MARK: OnClick view
    func pressChat(_ sender: AnyObject) {
        
        if (mUser == nil){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("you_can_send_a_message_by_registering_an_account", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_register", comment: ""), viewController: self, actionOK: { (alert : UIAlertAction) in
                
                let loginVC = LoginViewController();
                self.navigationController?.pushViewController(loginVC, animated: true);
                
            })
            return;
        }
		
		if (mUser?.id == userAround.id){
			return;
		}
		
        let chatOneVC = ChatOneViewController();
        if (self.userAround.isBlock != nil) {
            chatOneVC.isBlock = self.userAround.isBlock!;
        }
        chatOneVC.userAround = self.userAround;
        self.navigationController?.pushViewController(chatOneVC, animated: true);
    }
    
   
    @IBAction func pressBack(_ sender: AnyObject) {
        if (self.navigationController != nil && (self.navigationController?.viewControllers.count)! > 1){
            didPressBack();
        }else{
            dismiss(animated: true, completion: nil);
        }
        
    }

    func callApiUserInfo() {
        var params : Dictionary = Dictionary<String, String>();
        if (mUser != nil){
            params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        }
        
        var userId = "";
        if let _ = userAround.id {
            userId = userAround.id!;
        }
        params.updateValue(userId, forKey: Const.KEY_PARAMS_USER_ID);
        
        APIClient.sharedInstance.postRequest(Url: URL_USER_INFO, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
            
            let responseJson = JSON(success)["data"];
            let paserHelper : ParserHelper = ParserHelper();
            
            self.userAround = paserHelper.parserUser(data: responseJson);
            
            self.updateUI();
            
        }) { (error : AnyObject?) in
            
        }
    }
    
    func updateUI() {
        imgAvatar.sd_setImage(with: URL(string: (userAround.avatar)!), placeholderImage: UIImage.init(named: "avatar_no_image"))
        imgFlag.image = Utils.getFlagCountry(code: (userAround.codeCountry)!);
        lbName.text = Utils.getFullName(user: userAround);
        lbAddress.text = userAround.address;
        viewLanguage1.isHidden = true;
        viewLanguage2.isHidden = true;
        viewLanguage3.isHidden = true;
        if ( (userAround.like)! > 1000){
            lbLikeNumber.text = "10k"
        }else{
            lbLikeNumber.text = String(describing: (userAround.like)!);
        }
		
		if (mUser != nil && userAround.isBlock!){
			lbBlock.text = StringUtilities.getLocalizedString("blocked", comment: "")
		}
        
        for i in 0..<(userAround.language?.count)! {
            let lang = userAround.language?[i];
            if ( i == 0 ){
                ratingbar1.rating = CGFloat((lang?.level)!);
                lbLang1.text = LanguageUtils.getLanguageNameFromLanguageCode(languageCode: (lang?.codeLanguage)!);
                viewLanguage1.isHidden = false;
            }
            
            if ( i == 1 ){
                ratingbar2.rating = CGFloat((lang?.level)!);
                lbLang2.text = LanguageUtils.getLanguageNameFromLanguageCode(languageCode: (lang?.codeLanguage)!);
                viewLanguage2.isHidden = false;
            }
            
            if ( i == 2 ){
                ratingbar3.rating = CGFloat((lang?.level)!);
                lbLang3.text = LanguageUtils.getLanguageNameFromLanguageCode(languageCode: (lang?.codeLanguage)!);
                viewLanguage3.isHidden = false;
            }
        }
        
        self.updateContrainLanguage(userAround: userAround);
        
        self.lblInfor.text = userAround.introduction;
        
        if (userAround.birthday != nil) {
            self.lblBirthday.isHidden = false;
            self.lblBirthdayDate.isHidden = false;
            let birthday = Date(timeIntervalSince1970: TimeInterval((userAround.birthday)!));
            self.lblBirthdayDate.text =  DateTimeUtils.convertDateToString(date: birthday);
        } else {
            self.lblBirthday.isHidden = true;
            self.lblBirthdayDate.isHidden = true;
        }
        
        if (userAround.sex != nil && userAround.sex != 1) {
            self.lblGender.isHidden = false;
            self.lblGenderName.isHidden = false;
            self.lblGenderName.text = self.arrayGender?[((userAround.sex)! - 1)];
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
    func updateContrainLanguage(userAround : User){
        if(userAround.language?.count == 1) {
            viewLanguage1.frame = CGRect(x: viewLanguage1.frame.origin.x, y: viewLanguage1.frame.origin.y, width: UIScreen.main.bounds.width, height: viewLanguage1.frame.size.height);
            viewLanguage1.translatesAutoresizingMaskIntoConstraints = true;
        } else if (userAround.language?.count == 2) {
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

    
    @IBAction func pressBlock(_ sender: AnyObject) {
        if ( userAround.isBlock == true){
            showConfirmUnBlockUser();
        }else{
            showConfirmBlockUser();
        }
    }
    
    func callApiBlockUser() {
        SocketIOManager.sharedInstance.emitDoBlockUser(isBlock: true, userId: (userAround.id)!, onSuccess: { (data : Any) in

            let paserHelper : ParserHelper = ParserHelper();
            let block = paserHelper.parserBlock(data: data as! JSON);
            if (block?.success)!{
                if (block?.doBlock == true){
                    self.userAround.isBlock = true;
                    self.lbBlock.text = StringUtilities.getLocalizedString("blocked", comment: "")
                }
            }
        });
        
    
    }
    
    func callApiUnBlockUser() {
        SocketIOManager.sharedInstance.emitDoBlockUser(isBlock: false, userId: (userAround.id)!, onSuccess: { (data : Any) in
            
            let paserHelper : ParserHelper = ParserHelper();
            let block = paserHelper.parserBlock(data: data as! JSON);
            if (block?.success)!{
                if (block?.doBlock == false){
                    self.userAround.isBlock = false;
                    self.lbBlock.text = "";
                }
            }
            
        });
    }
    
    func showConfirmBlockUser() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoAction = UIAlertAction(title: StringUtilities.getLocalizedString("block_this_account", comment: ""), style: .destructive) { (action) in
            self.callApiBlockUser();
        }
        let cancelAction = UIAlertAction(title: StringUtilities.getLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)

        sheet.addAction(photoAction)
        
        sheet.addAction(cancelAction)
        
        sheet.popoverPresentationController?.sourceView = view
        sheet.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.size.width - 50, y: 0, width: 50, height: 50);
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    func showConfirmUnBlockUser() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoAction = UIAlertAction(title: StringUtilities.getLocalizedString("unblock_this_account", comment: ""), style: .destructive) { (action) in
            self.callApiUnBlockUser()
        }
        let cancelAction = UIAlertAction(title: StringUtilities.getLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        
        sheet.addAction(photoAction)
        
        sheet.addAction(cancelAction)
        
        sheet.popoverPresentationController?.sourceView = view
        sheet.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.size.width - 50, y: 0, width: 50, height: 50);
        
        self.present(sheet, animated: true, completion: nil)
    }
    
}
