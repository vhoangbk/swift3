/**
 * DetailPushViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit

class DetailPushViewController: BaseViewController {
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var urlImage : String = "";
    var typeMessage = 1;
    
    var objectNotification : ObjectNotification!;
    
    public var callApi = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (callApi) {
            callApi = false;
            var params : Dictionary = Dictionary<String, String>();
            if (mUser == nil) {
                self.intiView();
            }
            params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
            params.updateValue(objectNotification.id, forKey: Const.KEY_PARAMS_PUSH_ID);
            
            APIClient.sharedInstance.postRequest(Url: URL_READ_PUSH, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
                self.intiView();
            }) { (error : AnyObject?) in
                self.intiView();
            }
        } else {
            self.intiView();
        }
    }
    
    func intiView(){
        lblHeader.text = StringUtilities.getLocalizedString("title_header_notification_detail", comment: "");
        if (objectNotification != nil) {
            if (objectNotification.createdTime != nil) {
                lblDateTime.text = DateTimeUtils.convertLongTimeToDateTimeString(longTime: objectNotification.createdTime!);
            }
            var mTitle = "";
            var mContent = "";
            let userAction = self.objectNotification.userAction;
            if(userAction != nil) {
                let fullName = Utils.getFullName(user: userAction!);
                mTitle = fullName;
            }
            if(objectNotification.content != nil){
                mTitle = mTitle + objectNotification.content!;
            }
            lblTitle.text = mTitle;
            if(objectNotification.lastMessage != nil && objectNotification.lastMessage?.message != nil){
                if(objectNotification.lastMessage?.type != nil) {
                    typeMessage = (objectNotification.lastMessage?.type)!;
                }
                if (typeMessage == 3 || typeMessage == 2) {
                    if(objectNotification.lastMessage?.message != nil) {
                        imageView.sd_setImage(with: URL(string: (objectNotification.lastMessage?.message)!), placeholderImage: UIImage(named: "no_image"));
                        urlImage = (objectNotification.lastMessage?.message)!;
                    } else {
                        imageView.image = UIImage(named: "no_image");
                    }
                    let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped(img:)))
                    imageView.isUserInteractionEnabled = true
                    imageView.addGestureRecognizer(tapGestureRecognizer)
                } else {
                    mContent = (objectNotification.lastMessage?.message)!;
                    lblContent.text = mContent;
                }
            }
        }
    }
    
    func imageTapped(img: AnyObject)
    {
        if(typeMessage == 3) {
            if(urlImage == "") {
                let imageVC = TGRImageViewController(image: UIImage(named: "no_image"));
                self.present(imageVC!, animated: true, completion: nil);
            } else {
                let imageVC = TGRImageViewController(link: urlImage);
                self.present(imageVC!, animated: true, completion: nil);
            }
        } else if(typeMessage == 2){
            if(objectNotification.lastMessage?.latitude != nil && objectNotification.lastMessage?.longitude != nil) {
                let latitude:CLLocationDegrees =  (objectNotification.lastMessage?.latitude)!;
                let longitude:CLLocationDegrees =  (objectNotification.lastMessage?.longitude)!;
                let regionDistance:CLLocationDistance = 1000
                let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                ]
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = "";
                mapItem.openInMaps(launchOptions: options)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func pressBack(_ sender: Any) {
        self.navigationController!.popViewController(animated: true);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        appDelegate.screenPosition = AppDelegate.PUSH_DETAIL_POSITION;
        
        NotificationCenter.default.addObserver(self, selector: #selector(DetailPushViewController.notificationUpdateUI), name: Const.KEY_NOTIFICATION_DETAIL_UPDATE, object: nil);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        NotificationCenter.default.removeObserver(self, name: Const.KEY_NOTIFICATION_DETAIL_UPDATE, object: nil)
    }
    
    func notificationUpdateUI(notification: NSNotification) {
        self.objectNotification = notification.object as! ObjectNotification;
        self.intiView();
    }
    
}
