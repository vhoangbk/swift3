/**
 * ChatViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON
import Photos

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ScreenShotMapViewControllerDelegate {
    
    var messageChatList = [MessageChat] ();
    
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    var mUser : User?;
    
    var isTyping : Bool = false;
    var timer : Timer?;
    static let timeoutTyping = 0.6;
    
    var numberLine : Int = 1;
    
    let imagePicker = UIImagePickerController()
    
    var offset = 0;
    var currentPage = 0;
    var isLoadMore = true;
    var isHistoryLoading = false;
    
    var topicId : String?;
    
    var mRefreshControl: UIRefreshControl!
    
    var heightTollbar : CGFloat = 0;
    
    let locationManager = CLLocationManager();
    var locationValue:CLLocationCoordinate2D!;
    
    var isPressNotification : Bool = false;
    
    var viewAlert : UIView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        disableInputToolbar();
        self.timerAction();
        
        mRefreshControl = UIRefreshControl();
        mRefreshControl.addTarget(self, action: #selector(ChatViewController.refreshCollectionView), for: UIControlEvents.valueChanged);
        self.collectionView?.addSubview(mRefreshControl);
        
        imagePicker.delegate = self;
        
        // Bubbles with tails
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor(netHex: 0xe5e5ea));
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor(netHex: 0xfed303));
        
        if (mUser == nil || Utils.getInfoAccount() == nil){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            mUser = appDelegate.mUser;
        }
        
        if mUser == nil {
            let button = UIButton(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45));
            button.addTarget(self, action: #selector(ChatViewController.checkLogin), for: UIControlEvents.touchUpInside);
            
            self.inputToolbar.addSubview(button)
        }
        
        SocketIOManager.sharedInstance.onBlockUser { (data : Any) in
            let responseJson = JSON(data);
            let paserHelper : ParserHelper = ParserHelper();
            let block = paserHelper.parserBlock(data: responseJson);
            if (block?.success)!{
                if (block?.joinTopic == true){
                    SocketIOManager.sharedInstance.joinGroup(topicId: self.topicId!, reConect: false);
                }
            }
        }
        
        iniAlertView()
        
        self.inputToolbar.contentView?.textView?.autocorrectionType = .no
        let badgeNumber = UIApplication.shared.applicationIconBadgeNumber;
        UIApplication.shared.applicationIconBadgeNumber = 0;
        UIApplication.shared.cancelAllLocalNotifications();
        UIApplication.shared.applicationIconBadgeNumber = badgeNumber;
        
    }
    
    func showAlertNetwork() {
        self.view.addSubview(self.viewAlert);
    }
    
    func hideAlertNetwork() {
        self.viewAlert.removeFromSuperview();
    }
    
    func iniAlertView() {
        self.viewAlert = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 65, width: UIScreen.main.bounds.width, height: 20))
        self.viewAlert.backgroundColor = UIColor.red;
        
        let messageLabel = UILabel(frame: CGRect(x: 2, y: 2, width: self.viewAlert.frame.width - 4, height: self.viewAlert.frame.height - 4));
        messageLabel.font = UIFont.systemFont(ofSize: 12)
        messageLabel.textColor = UIColor.white;
        messageLabel.numberOfLines = 0;
        messageLabel.text = StringUtilities.getLocalizedString("message_error_network", comment: "");
        messageLabel.textAlignment = .center;
        self.viewAlert.addSubview(messageLabel)
    }
    
    func newConect(data : Any) {
        NSLog("ChatViewController newConect")
        if (self.mUser != nil && self.topicId != nil){
            if (isPressNotification){
                SocketIOManager.sharedInstance.joinGroup(topicId: (self.topicId)!, reConect: false);
                isPressNotification = false;
            }else{
                SocketIOManager.sharedInstance.joinGroup(topicId: (self.topicId)!, reConect: true);
            }
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        
        NSLog("ChatViewController viewDidDisappear")

    }
    
    func disableInputToolbar() {
        self.inputToolbar.contentView?.textView?.isUserInteractionEnabled = false;
        self.inputToolbar.contentView?.leftBarButtonItem?.isUserInteractionEnabled = false;
        self.inputToolbar.contentView?.rightBarButtonItem?.isUserInteractionEnabled = false;
    }
    
    func enableInputToolbar() {
        self.inputToolbar.contentView?.textView?.isUserInteractionEnabled = true;
        self.inputToolbar.contentView?.leftBarButtonItem?.isUserInteractionEnabled = true;
        self.inputToolbar.contentView?.rightBarButtonItem?.isUserInteractionEnabled = true;
    }
    
    deinit {
        print("ChatViewController deinit")
        deinitChat();
    }
    
    func deinitChat()  {
        
    }
    
    func offChatGroup(){
        SocketIOManager.sharedInstance.offBlockUser();
        leaveGroupChat();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if ( !appDelegate.isInternetConnected ){
            showAlertNetwork()
        }else{
            hideAlertNetwork()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.newConect), name: Const.KEY_NOTIFICATION_SOCKET_NEW_CONNECT, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.onTyping), name: Const.KEY_NOTIFICATION_ON_TYPING, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.onStopTyping), name: Const.KEY_NOTIFICATION_ON_STOP_TYPING, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.reachabilityChanged), name: Const.KEY_NOTIFICATION_NETWORK, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillAppear), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    
    }
    
    func reachabilityChanged(notification: NSNotification){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if ( !appDelegate.isInternetConnected ){
            showAlertNetwork();
        }else{
            hideAlertNetwork();
        }
    }
    
    func keyboardWillAppear(notification: NSNotification){
        let frame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue;
        print("frame \(frame.height)")
        self.constraintTyingButton?.constant = frame.height;
    }
    
    func onTyping(notification: NSNotification) {
        let data = JSON(notification.object!);
        let paserHelper = ParserHelper();
        let user = paserHelper.parserUser(data: data);
        
        if ( user.topicId != self.topicId ){
            return;
        }
        
        self.showTypingIndicator = false;
        self.userTyping = Utils.getFullName(user: user);
        
        self.lbTyping?.text = Utils.getFullName(user: user) + StringUtilities.getLocalizedString("is_typing", comment: "");
        self.lbTyping?.backgroundColor = UIColor.white;
        
        delayStopTyping();
    }
    
    func onStopTyping(notification: NSNotification) {
        self.showTypingIndicator = false
        self.lbTyping?.text = "";
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        NotificationCenter.default.removeObserver(self, name: Const.KEY_NOTIFICATION_SOCKET_NEW_CONNECT, object: nil)
        NotificationCenter.default.removeObserver(self, name: Const.KEY_NOTIFICATION_ON_TYPING, object: nil)
        NotificationCenter.default.removeObserver(self, name: Const.KEY_NOTIFICATION_ON_STOP_TYPING, object: nil)
        NotificationCenter.default.removeObserver(self, name: Const.KEY_NOTIFICATION_NETWORK, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
	
	override func pressBack(_ sender: Any) {
		super.pressBack(sender);
        
        offChatGroup()
        
	}
	
    func openPhoto() {
        
        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("not_access_photo", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return;
        } else if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    
                }
                    
                else {
                    
                }
            })
        }
        
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera() {
        
        //check simulator
        #if (arch(i386) || arch(x86_64))
            
        #else
            
            // Get the current authorization state.
            let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            if (status == .denied) {
                // Access has been denied.
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("not_access_camera", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
                return;
            } else if (status == .notDetermined) {
                
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
                    DispatchQueue.main.async() {
                        
                    } }
            }
            
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo;
            present(imagePicker, animated: true, completion: nil)
        #endif
    }
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapLink nsUrl: URL) {
        let webviewVC = WebViewViewController();
        webviewVC.url = nsUrl;
        dismissKeyboard();
        self.present(webviewVC, animated: true, completion: nil)
	}

    //MARK: JSQMessagesCollectionViewDelegateFlowLayout
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapMessageBubbleAt indexPath: IndexPath) {
        print("didTapMessageBubbleAt")
        
        let mesage : Message = messageChatList[indexPath.row].message!;
        if Message.MESSAGE_SERVER_TYPE_TEXT == mesage.type {
            
        }else if Message.MESSAGE_SERVER_TYPE_IMAGE == mesage.type {
            print("image: " + mesage.message!)
            
            if (mesage.image != nil){
                let imageVC = TGRImageViewController(image: mesage.image);
                dismissKeyboard();
                self.present(imageVC!, animated: true, completion: nil);
            }else{
                let imageVC = TGRImageViewController(link: mesage.message);
                dismissKeyboard();
                self.present(imageVC!, animated: true, completion: nil);
            }
            
            
            
            
        }else if Message.MESSAGE_SERVER_TYPE_LOCATION == mesage.type {
            openMapForPlace(lat: Double(mesage.latitude!), lon: Double(mesage.longitude!));
        }
    }
	
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didPressRetry button: UIButton, at indexPath: IndexPath) {
        let message : Message = messageChatList[indexPath.row].message!;
        showActionRetry(message: message, row : indexPath.row);
    }
    
    func showActionRetry(message : Message, row : Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if ( !appDelegate.isInternetConnected ){
            return;
        }
        
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
        let sheet = UIAlertController(title: nil, message: StringUtilities.getLocalizedString("message_retry_upload", comment: ""), preferredStyle: .actionSheet)
        
        let redoAction = UIAlertAction(title: StringUtilities.getLocalizedString("redo", comment: ""), style: .default) { (action) in
            if (message.image != nil) {
                message.status = Message.STATUS_UPLOADING;
                self.collectionView?.reloadData();
                self.uploadImage(image: message.image!, message: message);
            }
        }
        
        let deleteAction = UIAlertAction(title: StringUtilities.getLocalizedString("delete_upload", comment: ""), style: .default) { (action) in
            self.messageChatList.remove(at: row);
            self.collectionView?.reloadData();
        }
        
        let cancelAction = UIAlertAction(title: StringUtilities.getLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        
        sheet.addAction(redoAction)
        sheet.addAction(deleteAction)
        sheet.addAction(cancelAction)
        
        sheet.popoverPresentationController?.sourceView = view
        sheet.popoverPresentationController?.sourceRect = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 50, width: 50, height: 50);
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    /**
     * Open map
     *
     */
    func openMapForPlace(lat : Double, lon : Double) {
        dismissKeyboard();
        let latitude:CLLocationDegrees =  lat;
        let longitude:CLLocationDegrees =  lon;
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
    
    func checkLogin() -> Bool {
        if (mUser == nil){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("you_can_send_a_message_by_registering_an_account", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_register", comment: ""), viewController: self, actionOK: { (alert : UIAlertAction) in
                
                let loginVC = LoginViewController();
                self.navigationController?.pushViewController(loginVC, animated: true);
                
            })
            return false;
        }
        return true;
    }
    
    /*
     * get history
     */
    func getHistoryChat(topicId : String, isGroup : Bool, loadMore : Bool) {
        
        if (isHistoryLoading){
            if (loadMore){
                self.mRefreshControl.endRefreshing();
            }
            return;
        }
        
        if ( self.isLoadMore == false ){
            if (loadMore){
                self.mRefreshControl.endRefreshing();
            }
            return
        }
        
        if (self.offset > messageChatList.count ){
            if (loadMore){
                self.mRefreshControl.endRefreshing();
            }
            return;
        }
    
        
        self.isHistoryLoading = true;
        
        if (loadMore){
            timerActionDismissRefresh();
        }
        
        
        SocketIOManager.sharedInstance.getHistoryChatGroup(topicId: topicId, isGroup: isGroup, offset: self.offset, callback: { (data, ack) -> Void in
            self.parserHistory(data: JSON(data[0]));
            
            if (self.offset == 0){
                self.finishSendingMessage(animated: true)
                self.scrollToBottom(animated: true);
                
            }else{
                self.collectionView?.reloadData();
                
            }
            
            if (loadMore){
                self.mRefreshControl.endRefreshing();
            }else{
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            let when = DispatchTime.now() + 1;
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.enableInputToolbar();
            }
            
            self.currentPage += 1;
            
            self.isHistoryLoading = false;
            
        });
    }
    
    func timerAction(){
        let when = DispatchTime.now() + 12;
        DispatchQueue.main.asyncAfter(deadline: when) {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.enableInputToolbar();
        }
    }
    
    func timerActionDismissRefresh(){
        let when = DispatchTime.now() + 5;
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.mRefreshControl.endRefreshing();
        }
    }
    
    /*
     * parser history
     */
    func parserHistory(data : JSON) {
        if (data.arrayValue.count == 0){
            self.isLoadMore = false;
        }
        for history in data.arrayValue {
            let parserHelper : ParserHelper = ParserHelper();
            let chatmessage = parserHelper.parserMessageChat(data: history)
            messageChatList.insert(chatmessage, at: 0);
        }
        
        if (self.offset == 0 && messageChatList.last != nil && messageChatList.last?.message != nil ){
            SocketIOManager.sharedInstance.readMessage(messageId: (messageChatList.last?.message?.id)!);
        }
    }
    
    func sendMessage(message : Message, topicId : String) {
        if (!SocketIOManager.sharedInstance.connected()){
            self.view.makeToast(StringUtilities.getLocalizedString("error_code_common", comment: ""), duration: 2.0, position: .center);
            return;
        }
        let messageChat = MessageChat();
        messageChat.message = message;
        messageChat.user = mUser;
        
        messageChatList.append(messageChat);
        
        self.finishSendingMessage(animated: true)
        self.sendMessageText(text: message.message!, topicId: topicId);
    }
    
    func sendMessageText(text : String, topicId : String) {
        SocketIOManager.sharedInstance.sendMessageText(text: text, topicId: topicId);
    }
    
    func convertHistory2JSMessage(messageChat : MessageChat) -> JSQMessage?{
        
        let user : User = messageChat.user!;
        let message : Message = messageChat.message!;
        
        var jsqMessage : JSQMessage?;
        if message.type == Message.MESSAGE_SERVER_TYPE_TEXT {
            jsqMessage = JSQMessage.init(senderId: user.id!, displayName: Utils.getFullName(user: user), text: message.message!);
        }else if message.type == Message.MESSAGE_SERVER_TYPE_IMAGE {
            var JsqPhoto : JSQPhotoMediaItem;
            if (message.image != nil){
                JsqPhoto = JSQPhotoMediaItem(image: message.image);
            }else{
                if ( message.thumbnail == nil ){
                    JsqPhoto = JSQPhotoMediaItem(link: "");
                }else{
                    JsqPhoto = JSQPhotoMediaItem(link: message.thumbnail);
                }
            }
            
            jsqMessage = JSQMessage(senderId: user.id!, displayName: Utils.getFullName(user: user), media: JsqPhoto);
        }else if(message.type == Message.MESSAGE_SERVER_TYPE_LOCATION){
            
            var JsqPhoto : JSQPhotoMediaItem;
            if (message.image != nil){
                JsqPhoto = JSQPhotoMediaItem(image: message.image);
            }else{
                JsqPhoto = JSQPhotoMediaItem(link: message.thumbnail);
            }
            jsqMessage = JSQMessage(senderId: user.id!, displayName: Utils.getFullName(user: user), media: JsqPhoto);
        }
        
        if jsqMessage != nil && message.isLike != nil {
            jsqMessage!.isLike = message.isLike!;
            jsqMessage!.numberLike = message.like!;
            jsqMessage?.status = message.status;
        }
        
        if (user.codeCountry != nil){
            jsqMessage?.imageFlagItem = Utils.getFlagCountry(code: user.codeCountry!);
        }
        return jsqMessage;
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if ( !appDelegate.isInternetConnected ){
            return;
        }
        
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let locationAction = UIAlertAction(title: StringUtilities.getLocalizedString("choose_share_location", comment: ""), style: .default) { (action) in
            self.openShareLocation();
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
    
    func openShareLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization();
                
            } else if (CLLocationManager.authorizationStatus() == .denied){
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("warning_gps", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                    
                    UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL);
                });
                
            }else {
                let locationVC = ScreenShotMapViewController();
                locationVC.delegate = self;
                present(locationVC, animated: true, completion: nil);
            }
        } else {
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("warning_gps", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL);
            });
        }
        
        
    }
    
    func buildLocationItem() -> JSQLocationMediaItem {
        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)
        
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF) {
            self.collectionView!.reloadData()
        }
        
        return locationItem
    }
    
    //MARK: ScreenShotMapViewControllerDelegate
    func didShareLocation(currentLocation: CLLocationCoordinate2D, image: UIImage) {
        print("current location \(currentLocation.latitude),\(currentLocation.longitude)");
        
        let fileName = self.generateFileName();
        
        let message = Message();
        message.topicId = self.topicId;
        message.message = "";
        message.like = 0;
        message.fileName = fileName;
        message.type = Message.MESSAGE_SERVER_TYPE_LOCATION;
        message.size = "";
        message.latitude = currentLocation.latitude;
        message.longitude = currentLocation.longitude;
        message.isLike = false;
        message.image = image;
        message.status = Message.STATUS_UPLOADING;
        
        let messageChat = MessageChat();
        messageChat.message = message
        messageChat.user = self.mUser;
        self.messageChatList.append(messageChat)
        self.finishSendingMessage(animated: true)
        
        self.uploadImage(image: image, message: message)
        
    }
    
    func generateFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: Date());
    }
    
    func uploadImage(image : UIImage, message : Message) {
        let fileName = self.generateFileName();
        APIClient.sharedInstance.uploadImage(image: image, isShowAlert: false, viewController: self, isChat: true, name: fileName, Success: { (success : AnyObject) in
            //emit,update ui
            
            let responseJson = JSON(success)["data"];
            let paserHelper : ParserHelper = ParserHelper();
            let responseUploadImage = paserHelper.parserUploadImage(data: responseJson);
            
            if (responseUploadImage != nil){
                message.fileName = responseUploadImage!.fileName;
                message.message = responseUploadImage!.url;
                message.thumbnail = responseUploadImage!.thumbnail;
                message.status = Message.STATUS_LOADED;
                
                if (Message.MESSAGE_SERVER_TYPE_LOCATION == message.type){
                    self.sendLocationToGroup(url: responseUploadImage!.url!, paththumbnail: responseUploadImage!.urlSmall!, fileName: fileName, latitude: String(message.latitude!), lontitude: String(message.longitude!));
                }else{
                    self.sendImageToGroup(url: responseUploadImage!.url!, paththumbnail: responseUploadImage!.urlSmall!, fileName: fileName);
                }
                
                let messageChat = MessageChat();
                messageChat.message = message
                messageChat.user = self.mUser;
                
                self.finishSendingMessage(animated: true)
            }else{
                message.status = Message.STATUS_UPLOAD_FAILED;
                self.finishSendingMessage(animated: true)
            }
            
            }, Failure: { (error : AnyObject?) in
                //error, update ui
                message.status = Message.STATUS_UPLOAD_FAILED;
                self.finishSendingMessage(animated: true)
        })
    }
    
    override func viewDidLayoutSubviews() {
        self.heightTollbar = self.inputToolbar.frame.size.height;
    }
	
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dismiss(animated:true, completion: nil)
            let fileName = self.generateFileName();
            let message = Message();
            message.topicId = self.topicId;
            message.message = "";
            message.like = 0;
            message.fileName = fileName;
            message.type = Message.MESSAGE_SERVER_TYPE_IMAGE;
            message.size = "";
            message.isLike = false;
            message.image = pickedImage;
            message.status = Message.STATUS_UPLOADING;
            
            let messageChat = MessageChat();
            messageChat.message = message
            messageChat.user = self.mUser;
            self.messageChatList.append(messageChat)
            self.finishSendingMessage(animated: true)
            
            self.uploadImage(image: pickedImage, message: message);
            
            
        }
        
    }
    
    func sendImageToGroup(url : String, paththumbnail : String, fileName: String) {
        if (!SocketIOManager.sharedInstance.connected()){
            self.view.makeToast(StringUtilities.getLocalizedString("error_code_common", comment: ""), duration: 2.0, position: .center);
            return;
        }
        if (self.topicId == nil ){
            return;
        }
        SocketIOManager.sharedInstance.sendImageToGroup(url: url, paththumbnail: paththumbnail, fileName: fileName, topicId: self.topicId!);
    }
    
    func sendLocationToGroup(url : String, paththumbnail : String, fileName: String, latitude : String, lontitude : String) {
        if (!SocketIOManager.sharedInstance.connected()){
            self.view.makeToast(StringUtilities.getLocalizedString("error_code_common", comment: ""), duration: 2.0, position: .center);
            return;
        }
        if (self.topicId == nil ){
            return;
        }
        SocketIOManager.sharedInstance.sendLocationToGroup(url: url, paththumbnail: paththumbnail, fileName: fileName, topicId: self.topicId!, latitude: latitude, lontitude: lontitude);
    }
    
    func leaveGroupChat(){
        if (self.topicId == nil ){
            return;
        }
        SocketIOManager.sharedInstance.leaveGroupChat(topicId: (self.topicId)!);
    }
    
    override func textViewDidBeginEditing(_ textView: UITextView) {
        super.textViewDidBeginEditing(textView);
        
    }

    override func textViewDidChange(_ textView: UITextView) {
        if textView.hasText {
            if (self.isTyping == false){
                self.isTyping = true;
                SocketIOManager.sharedInstance.emitTyping(isTyping: true, topicId: (self.topicId)!);
            }
            timer?.invalidate();
            self.timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(ChatViewController.stopTyping), userInfo: nil, repeats: false);
        }
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        stopTyping();
    }
    
    func stopTyping() {
        if isTyping == false {
            return;
        }
        isTyping = false;
        SocketIOManager.sharedInstance.emitTyping(isTyping: false, topicId: (self.topicId)!);
    }
    
    func refreshCollectionView() {
        
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollToBottom(animated: true)
    }
    
    func delayStopTyping() {
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.showTypingIndicator = false
            self.lbTyping?.text = "";
        }
        
    }
    
    func dismissKeyboard() {
        self.inputToolbar.contentView?.textView?.resignFirstResponder();
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height) {
            self.isBottom = true;
        }else{
            self.isBottom = false;
        }
        
        self.isScrolling = false;
    }
    
    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.isScrolling = true;
    }
}
