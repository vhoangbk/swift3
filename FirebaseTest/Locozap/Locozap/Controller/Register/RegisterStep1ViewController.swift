/**
 * RegisterStep1ViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import AlamofireImage
import Photos

class RegisterStep1ViewController: BaseRegisterViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lbRegisterPhoto: UILabel!
    @IBOutlet weak var tfFistName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    
    var uiImage : UIImage?
    
    let imagePicker = UIImagePickerController()
    
    private var shadowImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView();
        
        requestPhotoPermistion();
        requestCameraPermistion();
    }
    
    func initView() {
        let fistName = NSAttributedString(string: StringUtilities.getLocalizedString("name", comment: ""), attributes: [NSForegroundColorAttributeName:UIColor.init(netHex: Const.COLOR_PLACEHOLDER)])
        tfFistName.attributedPlaceholder = fistName
        
        let lastName = NSAttributedString(string: StringUtilities.getLocalizedString("sur_name", comment: ""), attributes: [NSForegroundColorAttributeName:UIColor.init(netHex: Const.COLOR_PLACEHOLDER)])
        tfLastName.attributedPlaceholder = lastName
        
        lbTitle.text = StringUtilities.getLocalizedString("enter_name", comment: "");
        lbRegisterPhoto.text = StringUtilities.getLocalizedString("register_photo", comment: "");
        
        //tap avatar
        let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(RegisterStep1ViewController.tapImageAvatar))
        imgAvatar.addGestureRecognizer(tapAvatar)
        
        //dismis keyboad
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterStep1ViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        tfFistName.delegate = self;
        tfLastName.delegate = self;
        imagePicker.delegate = self;
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let currentCharacterCount = textField.text?.characters.count ?? 0
//        let newLength = currentCharacterCount + string.characters.count;
//        if(textField == tfFistName) {
//            return newLength <= 10
//        } else if (textField == tfLastName){
//            return newLength <= 15
//        }
        return true;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true);
        
        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationController!.navigationBar)
        }
        shadowImageView?.isHidden = true
    }
    
    private func findShadowImage(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return (view as! UIImageView)
        }
        for subview in view.subviews {
            if let imageView = findShadowImage(under: subview) {
                return imageView
            }
        }
        return nil
    }
    
    func dismissKeyboard() {
        tfFistName.resignFirstResponder();
        tfLastName.resignFirstResponder();
    }

    
    override func didPressBack() {
        dismiss(animated: true, completion: nil);
    }
    
    override func didPressNext(){
        if (validate() == true){
            let resgisVC = RegisterStep2ViewController();
            resgisVC.fistName = tfFistName.text?.trim();
            resgisVC.lastName = tfLastName.text;
            resgisVC.uiImage = self.uiImage;
            self.navigationController?.pushViewController(resgisVC, animated: true);
        }
        
    }
    
    override func getBackImage() -> UIImage {
        return UIImage(named: "img_cancel")!;
    }
    
    func validate() -> Bool {
        
        let fistName = tfFistName.text?.trim();
        let lastName = tfLastName.text?.trim();
        
        if (fistName?.isEmpty == true){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("name_empty", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        
        if (lastName?.isEmpty == true){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("name_empty", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        
        return true;
    }

    func tapImageAvatar() {
        self.tfFistName.resignFirstResponder()
        self.tfLastName.resignFirstResponder()
        
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
        self.uiImage = nil;
        imgAvatar.image = UIImage.init(named: "avatar_no_image");
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dismiss(animated: true, completion: nil)
            self.uiImage = pickedImage;
            let imageFilter = CircleFilter();
            self.imgAvatar.image = imageFilter.filter(self.uiImage!);
        }
        
    }

    @IBAction func didEnd(_ sender: AnyObject) {
        tfFistName.resignFirstResponder();
    }
}
