/**
 * InfoProfileViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit

class InfoProfileViewController: BaseViewController{
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    
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
    
    var user : User?;
	
    var indexCountry : Int = 0;
    var countryCode : String?;
    
    var indexGender : Int = 0;

    var arrayGender : [String]?;
    
    var imageAvatar : UIImage?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }
    
    func initView() {
        
        viewContainner.frame = CGRect(x: viewContainner.frame.origin.x, y: viewContainner.frame.origin.y, width: UIScreen.main.bounds.width, height: viewContainner.frame.size.height)
        
        self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: viewContainner.frame.size.height);
        self.scrollView.addSubview(viewContainner);
        
        btnCancel.setTitle(StringUtilities.getLocalizedString("cancel", comment: ""), for: UIControlState.normal);
        
        if (user != nil){
            lbTitle.text = Utils.getFullName(user: user!);
        }else{
            lbTitle.text = "";
        }
        
		
        lbChangePhoto.text = StringUtilities.getLocalizedString("setting_avatar", comment: "");
        lblSurName.text = StringUtilities.getLocalizedString("sur_name", comment: "");
        lblName.text = StringUtilities.getLocalizedString("name", comment: "");
        
        if(user?.avatarMedium != nil) {
            imgAvatar.sd_setImage(with: URL.init(string: (user?.avatarMedium)!), placeholderImage: UIImage.init(named: "avatar_no_image"))
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
        if (user != nil && (user?.sex)! <= 1){
            lbGender.text = StringUtilities.getLocalizedString("setting_sex", comment: "");
        }else{
            lbGender.text = self.arrayGender?[((user?.sex)! - 1)];
        }
        
        self.indexGender = (user?.sex)! - 1;

        
        lbCountry.text = LanguageUtils.getCountryNameFromCountryCode(countryCode: (user?.codeCountry)!);
        for i in 0..<Const.arrayCountries.count{
            if (Const.arrayCountries[i] == user?.codeCountry){
                self.indexCountry = i;
                countryCode = Const.arrayCountries[i];
            }
        }
        
        if (user?.lastName != nil){
            tfSurname.text = user?.lastName;
        }
        
        if (user?.fistName != nil){
            tfName.text = user?.fistName;
        }
        
        
        if (user?.address != nil){
            tfAddress.text = user?.address;
        }
        
        if (user?.birthday != nil){
            let birthday = Date(timeIntervalSince1970: TimeInterval((user?.birthday)!));
            lbBirthday.text =  DateTimeUtils.convertDateToString(date: birthday);
            lbBirthday.textColor = UIColor.init(netHex: Const.COLOR_4E4A39);
        }else{
            lbBirthday.text = StringUtilities.getLocalizedString("setting_birthday", comment: "")
            lbBirthday.textColor = UIColor.init(netHex: Const.COLOR_PLACEHOLDER_SETTING);
        }
        
        if (user?.introduction != nil && user?.introduction != ""){
            tvInformation.text = user?.introduction;
            tvInformation.textColor = UIColor.init(netHex: Const.COLOR_4E4A39);
        }
 
    }

    @IBAction func pressCancel(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true);
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        updateFrameTextViewInfo();
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

}
