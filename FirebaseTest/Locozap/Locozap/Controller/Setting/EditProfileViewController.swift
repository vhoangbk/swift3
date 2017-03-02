/**
 * EditProfileViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import AlamofireImage
import SwiftyJSON
import Photos

class EditProfileViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnDone: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var viewContainner: UIView!
	
	@IBOutlet var tfSurname: UITextField!
	@IBOutlet var tfName: UITextField!
    @IBOutlet weak var lbCountry: UILabel!
	@IBOutlet var tfAddress: UITextField!
	@IBOutlet var tvInformation: UITextView!
	@IBOutlet var lbBirthday: UILabel!
	@IBOutlet var lbGender: UILabel!
	
	@IBOutlet var imgAvatar: UIImageView!
	@IBOutlet var lbChangePhoto: UILabel!
    @IBOutlet weak var lblSurName: UILabel!
    @IBOutlet weak var lblName: UILabel!

    @IBOutlet weak var constraintBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightInfomation: NSLayoutConstraint!
	
	var datePicker : GKActionSheetPicker?;
    var dateSelected : Date!;
    
    var actionSheetPickerCountry : GKActionSheetPicker?;
    var indexCountry : Int = 0;
    var countryCode : String?;
    
    var actionSheetPickerGender : GKActionSheetPicker?;
    var indexGender : Int = 0;
    
    let imagePicker = UIImagePickerController()

    var arrayGender : [String]?;
    
    var imageAvatar : UIImage?;
    var isDeleteAvatar : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
        
        requestPhotoPermistion();
        requestCameraPermistion();
    }
    
    func initView() {
        
        viewContainner.frame = CGRect(x: viewContainner.frame.origin.x, y: viewContainner.frame.origin.y, width: UIScreen.main.bounds.width, height: viewContainner.frame.size.height)
        
        self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: viewContainner.frame.size.height);
        self.scrollView.addSubview(viewContainner);
        
        btnCancel.setTitle(StringUtilities.getLocalizedString("cancel", comment: ""), for: UIControlState.normal);
        btnDone.setTitle(StringUtilities.getLocalizedString("done", comment: ""), for: UIControlState.normal);
        lbTitle.text = StringUtilities.getLocalizedString("profile", comment: "");
		
        lbChangePhoto.text = StringUtilities.getLocalizedString("setting_avatar", comment: "");
        lblSurName.text = StringUtilities.getLocalizedString("sur_name", comment: "");
        lblName.text = StringUtilities.getLocalizedString("name", comment: "");
        
        if(mUser?.avatarMedium != nil) {
            imgAvatar.sd_setImage(with: URL.init(string: (mUser?.avatarMedium)!), placeholderImage: UIImage.init(named: "avatar_no_image"))
        } else{
            self.imgAvatar.image = UIImage.init(named: "avatar_no_image");
        }   
        
        //place holder
        let address = NSAttributedString(string: StringUtilities.getLocalizedString("setting_address", comment: ""), attributes: [NSForegroundColorAttributeName:UIColor.init(netHex: Const.COLOR_PLACEHOLDER_SETTING)])
        tfAddress.attributedPlaceholder = address;
        tvInformation.placeholder = StringUtilities.getLocalizedString("setting_user_infor", comment: "");
        tvInformation.placeholderColor = UIColor.init(netHex: Const.COLOR_PLACEHOLDER_SETTING);
        
        let unknown : String = StringUtilities.getLocalizedString("unknown", comment: "");
        let male : String = StringUtilities.getLocalizedString("male", comment: "");
        let female : String = StringUtilities.getLocalizedString("female", comment: "");
        self.arrayGender = [unknown, male, female];
        if ((mUser?.sex)! <= 1){
            lbGender.text = StringUtilities.getLocalizedString("setting_sex", comment: "");
        }else{
            lbGender.text = self.arrayGender?[((mUser?.sex)! - 1)];
        }
        
        self.indexGender = (mUser?.sex)! - 1;

        
        lbCountry.text = LanguageUtils.getCountryNameFromCountryCode(countryCode: (mUser?.codeCountry)!);
        for i in 0..<Const.arrayCountries.count{
            if (Const.arrayCountries[i] == mUser?.codeCountry){
                self.indexCountry = i;
                countryCode = Const.arrayCountries[i];
            }
        }
        
        if (mUser?.lastName != nil){
            tfSurname.text = mUser?.lastName;
        }
        
        if (mUser?.fistName != nil){
            tfName.text = mUser?.fistName;
        }
        
        
        if (mUser?.address != nil){
            tfAddress.text = mUser?.address;
        }
        
        if (mUser?.birthday != nil){
            let birthday = Date(timeIntervalSince1970: TimeInterval((mUser?.birthday)!));
            lbBirthday.text =  DateTimeUtils.convertDateToString(date: birthday);
            lbBirthday.textColor = UIColor.init(netHex: Const.COLOR_4E4A39);
        }else{
            lbBirthday.text = StringUtilities.getLocalizedString("setting_birthday", comment: "")
            lbBirthday.textColor = UIColor.init(netHex: Const.COLOR_PLACEHOLDER_SETTING);
        }
        
        if (mUser?.introduction != nil && mUser?.introduction != ""){
            tvInformation.text = mUser?.introduction;
            tvInformation.textColor = UIColor.init(netHex: Const.COLOR_4E4A39);
        }
 
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.keyboardWillAppear), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.keyboardWillDisappear), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.dismissKeyboard))
		viewContainner.addGestureRecognizer(tapGestureRecognizer)
		
		let tapBirthday = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.choseBirthday))
		lbBirthday.addGestureRecognizer(tapBirthday)
        
        //chose gender
        let tapGender = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.choseGender))
        lbGender.addGestureRecognizer(tapGender)
        
        //chose gender
        let tapCountry = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.choseCountry))
        lbCountry.addGestureRecognizer(tapCountry)
        
        //tap avatar
        let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.tapImageAvatar))
        imgAvatar.addGestureRecognizer(tapAvatar)
        
        imagePicker.delegate = self;
        
        isDeleteAvatar = false;
        tfName.delegate = self;
        tfSurname.delegate = self;
        
        tvInformation.delegate = self;
    }
    
    func keyboardWillAppear(){
        constraintBottom.constant = 260;
    }
    
    func keyboardWillDisappear(){
        constraintBottom.constant = 0;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated);
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true);
    }

    @IBAction func pressCancel(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true);
    }

    @IBAction func pressDone(_ sender: AnyObject) {
        
        let fistName = self.tfSurname.text?.trim();
        let lastName = self.tfName.text?.trim();
        
        if (fistName?.isEmpty == true){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("name_empty", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return;
        }
        
        if (lastName?.isEmpty == true){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("name_empty", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return;
        }
        
        dismissKeyboard();
        
        MBProgressHUD.showAdded(to: self.view, animated: true);
        if self.imageAvatar == nil {
            if (self.isDeleteAvatar == true){
                self.callApiUpdateProfile(avatar: "", avatarSmall: "", avatarMedium: "");
            }else{
                var avatarSmall = "";
                if (mUser?.avatarSmall !=  nil){
                    avatarSmall = (mUser?.avatarSmall)!;
                }
                
                var avatarMedium = "";
                if (mUser?.avatarMedium !=  nil){
                    avatarMedium = (mUser?.avatarMedium)!;
                }
                
                self.callApiUpdateProfile(avatar: (mUser?.avatar)!, avatarSmall: avatarSmall, avatarMedium: avatarMedium)
            }
        }else{
            self.uploadImage(image: self.imageAvatar!);
        }
    }
	
	func dismissKeyboard(){
		tfSurname.resignFirstResponder();
		tfName.resignFirstResponder();
		tfAddress.resignFirstResponder();
		tvInformation.resignFirstResponder();
	}

	func choseBirthday(){
		self.datePicker = GKActionSheetPicker.datePicker(with: .date, from: Date.init(timeIntervalSince1970: 0), to: Date.init(), interval: 60 * 60 * 24, selectCallback: { (selected : Any) in
			
			self.dateSelected = selected as! Date;
			self.lbBirthday.text = DateTimeUtils.convertDateToString(date: self.dateSelected);
            self.lbBirthday.textColor = UIColor.init(netHex: Const.COLOR_4E4A39);
			
			}, cancelCallback: {
				
		})
		

		self.datePicker?.present(on: self.view);
		self.datePicker?.select(self.dateSelected)
	}
    
    @IBAction func dissmitKeyboard(_ sender: AnyObject) {
        tfSurname.resignFirstResponder();
    }
    
    func choseGender() {
        
        var listGender : [GKActionSheetPickerItem] = [GKActionSheetPickerItem]();
        
        let count = self.arrayGender?.count;
        for i in 0..<count!{
            let gender = arrayGender?[i];
            let item = GKActionSheetPickerItem(title: gender, value: i)
            listGender.append(item!);
        }
        
        actionSheetPickerGender = GKActionSheetPicker.stringPicker(withItems: listGender, selectCallback: { (selected : Any?) in
            
            self.indexGender = selected as! Int;
            self.lbGender.text = self.arrayGender?[self.indexGender];
            
        }) {
            
        };
        
        actionSheetPickerGender?.select(self.toUint(signed: self.indexGender))
        
        actionSheetPickerGender?.present(on: self.view);
    }
    
    func choseCountry() {
        
        let currentLocale : NSLocale = NSLocale.current as NSLocale;
        var arrayNameCountries : [GKActionSheetPickerItem] = [GKActionSheetPickerItem]();
        for i in 0..<Const.arrayCountries.count{
            let countryName = currentLocale.displayName(forKey: NSLocale.Key.countryCode, value: Const.arrayCountries[i])
            let item = GKActionSheetPickerItem(title: countryName, value: i)
            arrayNameCountries.append(item!);
        }
        
        actionSheetPickerCountry = GKActionSheetPicker.stringPicker(withItems: arrayNameCountries, selectCallback: { (selected : Any?) in
            self.indexCountry = selected as! Int;
            self.countryCode = Const.arrayCountries[self.indexCountry];

            self.lbCountry.text = arrayNameCountries[self.indexCountry].title;
            
        }) {
            
        };
        
        actionSheetPickerCountry?.select(self.toUint(signed: self.indexCountry))
        
        actionSheetPickerCountry?.present(on: self.view);
    }
    
    /*
     * convet int to uint
     */
    func toUint(signed: Int) -> UInt {
        let unsigned = signed >= 0 ?
            UInt(signed) :
            UInt(signed  - Int.min) + UInt(Int.max) + 1
        
        return unsigned
    }
    
    func tapImageAvatar() {
        dismissKeyboard();
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let locationAction = UIAlertAction(title: StringUtilities.getLocalizedString("delete_photo", comment: ""), style: .default) { (action) in
            self.deleteAvatar();
        }
        
        let takePhotoAction = UIAlertAction(title: StringUtilities.getLocalizedString("choose_camera", comment: ""), style: .default) { (action) in
            self.openCamera()
        }
        
        let photoAction = UIAlertAction(title: StringUtilities.getLocalizedString("choose_gallery", comment: ""), style: .default) { (action) in
            self.openPhoto();
        }
        
        let cancelAction = UIAlertAction(title: StringUtilities.getLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        
        sheet.addAction(locationAction)
        sheet.addAction(takePhotoAction)
        sheet.addAction(photoAction)
        
        sheet.addAction(cancelAction)
        
        sheet.popoverPresentationController?.sourceView = view
        sheet.popoverPresentationController?.sourceRect = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 50, width: 50, height: 50);
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    func openPhoto() {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("not_access_photo", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return;
        } else if (status == PHAuthorizationStatus.authorized) {
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func openCamera() {
        //check simulator
        #if (arch(i386) || arch(x86_64))
            
        #else
            let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            if (status == .denied) {
                // Access has been denied.
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("not_access_camera", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
                return;
            } else if (status == .authorized) {
                imagePicker.mediaTypes = ["public.image"]
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                imagePicker.cameraCaptureMode = .photo;
                present(imagePicker, animated: true, completion: nil)
            }
            
            
        #endif
    }
    
    func deleteAvatar() {
        imgAvatar.image = UIImage.init(named: "avatar_no_image");
        self.imageAvatar = nil;
        isDeleteAvatar = true;
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dismiss(animated: true, completion: nil)
            self.imageAvatar = pickedImage;
            self.imgAvatar.image = pickedImage;
        }
        
    }
    
    func uploadImage(image : UIImage) {
        let fileName = Utils.generateFileName();
        APIClient.sharedInstance.uploadImage(image: image, isShowAlert: true, viewController: self, isChat: false, name: fileName, Success: { (success : AnyObject) in
            
            let responseJson = JSON(success)["data"];
            let paserHelper : ParserHelper = ParserHelper();
            let responseUploadImage = paserHelper.parserUploadImage(data: responseJson);
            
            if (responseUploadImage != nil){
                self.callApiUpdateProfile(avatar: responseUploadImage!.url!, avatarSmall: responseUploadImage!.urlSmall!, avatarMedium: responseUploadImage!.urlMedium!);
            }else{
                self.view.makeToast(StringUtilities.getLocalizedString("image_upload_fail", comment: ""), duration: 2.0, position: .center)
            }
            
            
            }, Failure: { (error : AnyObject?) in
                MBProgressHUD.hide(for: self.view, animated: true)
        })
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let currentCharacterCount = textField.text?.characters.count ?? 0
//        let newLength = currentCharacterCount + string.characters.count;
//        if(textField == tfName) {
//            return newLength <= 10
//        } else if (textField == tfSurname){
//            return newLength <= 15
//        }
        
        return true;
    }
    

    /*
     * call api update user
     * 1: unknown
     * 2: male
     * 3: female
     */
    func callApiUpdateProfile(avatar : String, avatarSmall : String, avatarMedium : String) {
        
        let fistName = self.tfName.text?.trim();
        let lastName = self.tfSurname.text?.trim();
        let address = self.tfAddress.text?.trim();
        let info = self.tvInformation.text.trim();
        
        var params : Dictionary = Dictionary<String, String>();
        
        var birth : String = "";
        if (self.dateSelected != nil) {
            birth = String(self.dateSelected.timeIntervalSince1970);
            params.updateValue(birth, forKey: Const.KEY_PARAMS_BIRTHDAY);
        }
        
        params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(fistName!, forKey: Const.KEY_PARAMS_FIRSTNAME);
        params.updateValue(lastName!, forKey: Const.KEY_PARAMS_LASTNAME);
        params.updateValue(address!, forKey: Const.KEY_PARAMS_ADDRESS);
        params.updateValue(info, forKey: Const.KEY_PARAMS_INFOR);
        
        params.updateValue(countryCode!, forKey: Const.KEY_PARAMS_COUNTRY);
        params.updateValue(String(self.indexGender + 1), forKey: Const.KEY_PARAMS_SEX);
        params.updateValue(avatar, forKey: Const.KEY_PARAMS_AVATAR);
        params.updateValue(avatarSmall, forKey: Const.KEY_PARAMS_AVATAR_SMALL);
        params.updateValue(avatarMedium, forKey: Const.KEY_PARAMS_AVATAR_MEDIUM);
        
        APIClient.sharedInstance.postRequest(Url: URL_UPDATE_USER, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: false, ShowAlert: true, Success: { (success : AnyObject) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let responseJson = JSON(success)["data"];
            Utils.setInfoAccount(infoAccount: NSKeyedArchiver.archivedData(withRootObject: responseJson.rawValue) as AnyObject?);
            let paserHelper : ParserHelper = ParserHelper();
            let user = paserHelper.parserUser(data: responseJson);
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            appDelegate.mUser = user;
            
            if let birthDay = self.dateSelected {
                IgaworksCore.setAge(Int32(birthDay.age))
            }
            
            if self.indexGender == 1 {
                IgaworksCore.setGender(IgaworksCoreGenderMale)
            } else if self.indexGender == 2 {
                IgaworksCore.setGender(IgaworksCoreGenderFemale)
            }
            
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("edit_profile_success", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                self.navigationController!.popViewController(animated: true);
            })
            
        }) { (error : AnyObject?) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }

    }
    
    //MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        if (textView.isEqual(tvInformation)){
            self.updateFrameTextViewInfo();
        }
    }
    
    func updateFrameTextViewInfo() {
        let fixedWidth = tvInformation.frame.size.width
        tvInformation.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = tvInformation.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        if (newSize.height > 100){
            self.constraintHeightInfomation.constant = 100;
        } else if (newSize.height < 45){
            self.constraintHeightInfomation.constant = 45;
        }else{
            self.constraintHeightInfomation.constant = newSize.height;
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        updateFrameTextViewInfo();
    }

}
