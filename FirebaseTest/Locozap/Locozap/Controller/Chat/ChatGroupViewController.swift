/**
 * ChatGroupViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON
import Alamofire
import FacebookLogin

class ChatGroupViewController: ChatViewController {
    
    var itemHome : ItemHome?;
	
	var isAnimation : Bool = false;
    var isLastPost : Bool = false;
    
    let duration = 0.2;
    
    var heightHeaderContent : CGFloat = 300;
    
    var isDidLoad = false;
    
    var fromCreateTopic : Bool = false;
    var notification: ObjectNotification! = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isDidLoad = true;
        
        if (notification != nil) {
            var params : Dictionary = Dictionary<String, String>();
            params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
            params.updateValue(notification.id, forKey: Const.KEY_PARAMS_PUSH_ID);
            
            APIClient.sharedInstance.postRequest(Url: URL_READ_PUSH, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: false, ShowAlert: false, Success: { (success : AnyObject) in
                let objSetTabbar = SetInfoBadgeTabbar(type: TypeSetInfoBadgeTabbar.Decrement, value: 1);
                NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_SET_BADGE_TAB, object: objSetTabbar, userInfo: nil);
            }) { (error : AnyObject?) in
            }
        }

        if (self.topicId != nil) {
            callApiTopicInfo(topicId: self.topicId!, completeReloadData: {
                (topic) -> Void in
                self.itemHome = ItemHome(user: (topic.userCreate)!, topic: topic);
                self.initView();
                self.getDataChat();
            });
        } else {
            if (self.itemHome != nil && self.itemHome?.topic != nil) {
                self.topicId = itemHome?.topic.id;
            }
            self.initView();
            self.getDataChat();
        }
        
        listenRemove();
        
        self.showViewLike = true;
        
    }
    
    func getDataChat() {
        if (self.mUser != nil){
            SocketIOManager.sharedInstance.joinGroup(topicId: (self.itemHome?.topic.id)!, reConect: false);
        }
        
        if (SocketIOManager.sharedInstance.connected()) {
            self.getHistoryChat(topicId: (itemHome?.topic.id)!, isGroup: true, loadMore: false);
            self.listenNewMessageAndLike();
        }else{
            let when = DispatchTime.now() + 10;
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.getHistoryChat(topicId: (self.itemHome?.topic.id)!, isGroup: true, loadMore: false);
                self.listenNewMessageAndLike();
            }
        }
    }
    
    func listenNewMessageAndLike() {
        SocketIOManager.sharedInstance.onNewMessageGroup { (data : Any) in
            print("[ChatGroupViewController] onNewMessageGroup \(data)")
            self.parserNewMessage(data: JSON(data));
        }
        
        SocketIOManager.sharedInstance.onLikeMessage { (data : Any) in
            print("[ChatGroupViewController] onLikeMessage \(data)")
            self.parserOnLikeMessage(data: data);
            self.collectionView?.reloadData();
        }
    }
    
    func initView(){
        lbGroupTitle?.text = itemHome?.topic.title;
        lbGroupTitle1?.text = itemHome?.topic.title;
		
		self.lbtitleHeader.text = StringUtilities.getLocalizedString("title_posting", comment: "");
        
        let category = itemHome?.topic.category;
        imgCategory?.image = Utils.getTopicFormType(typeTopic: category!);
        
        var color : UIColor!;
        if (category == Const.TOPIC_CATEGORY_PLAY) {
            color = UIColor(netHex: Const.COLOR_PLAY);
            
        } else if (category == Const.TOPIC_CATEGORY_DRINK){
            color = UIColor(netHex: Const.COLOR_DRINK);
            
        } else if (category == Const.TOPIC_CATEGORY_FOOD){
            color = UIColor(netHex: Const.COLOR_FOOD);
        }else{
            color = UIColor(netHex: Const.COLOR_HELP);
        }
        
        lbGroupTitle1?.textColor = color;
        
        if (itemHome?.topic.address == nil){
            lbAddress?.isHidden = true;
            imgLocation?.isHidden = true;
        }else{
            lbAddress?.isHidden = false;
            imgLocation?.isHidden = false;
            if (Utils.isJapanese()){
                lbAddress?.text = itemHome?.topic.address?.ja;
            }else{
                lbAddress?.text = itemHome?.topic.address?.en;
            }
            
        }
        
        lbGroupContent?.text = itemHome?.topic.content;
        lbUserName?.text = Utils.getFullName(user: (itemHome?.user)!);
        if (itemHome?.user.avatarSmall != nil) {
            imgAvatar?.sd_setImage(with: URL(string: (itemHome?.user.avatarSmall)!), placeholderImage: UIImage(named: "avatar_no_image"));
        } else if (itemHome?.user.avatarMedium != nil) {
            imgAvatar?.sd_setImage(with: URL(string: (itemHome?.user.avatarMedium)!), placeholderImage: UIImage(named: "avatar_no_image"));
        } else if (itemHome?.user.avatar != nil) {
            imgAvatar?.sd_setImage(with: URL(string: (itemHome?.user.avatar)!), placeholderImage: UIImage(named: "avatar_no_image"));
        }
        if(itemHome?.user.codeCountry != nil) {
            imgFlag?.image = Utils.getFlagCountry(code: (itemHome?.user.codeCountry)!);
        }
        
        self.viewHeaderContent.isHidden = false;
        self.viewExpand?.isHidden = true;
        
        let tapAddress = UITapGestureRecognizer(target: self, action: #selector(ChatGroupViewController.openLocationInMap));
        let tapLocation = UITapGestureRecognizer(target: self, action: #selector(ChatGroupViewController.openLocationInMap));
        lbAddress?.addGestureRecognizer(tapAddress);
        imgLocation?.addGestureRecognizer(tapLocation);
        
        if(isLastPost) {
            self.inputToolbar.isHidden = true;
        } else {
            self.inputToolbar.isHidden = false;
        }
    }
    
    @objc private func openLocationInMap() {
        print("Tap addres " + (lbAddress?.text)!);
        if (self.itemHome != nil && self.itemHome?.topic.latitude != nil && self.itemHome?.topic.longitude != nil) {
            self.openMapForPlace(lat: (self.itemHome?.topic.latitude)!, lon: (self.itemHome?.topic.longitude)!);
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
    }

    func parserNewMessage(data : JSON) {
        let parserHelper : ParserHelper = ParserHelper();
        let messageChat = parserHelper.parserMessageChat(data: data);
        
        if (messageChat.message?.isLike == nil){
            messageChat.message?.isLike = false;
        }
        
        messageChatList.append(messageChat);
        self.finishReceivingMessage();
        SocketIOManager.sharedInstance.readMessage(messageId: (messageChat.message?.id)!);
    }
    
    func listenRemove() {
        SocketIOManager.sharedInstance.onRemoveTopicOrUser { (data : Any) in
            let parserHelper : ParserHelper = ParserHelper();
            let remover = parserHelper.parserResponseRemove(data: JSON(data));
            if (APIError.TopicIsDeleted == remover?.errorCode){
                //topic is deleted
                //refresh home
                NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_RELOADS_TOP_WHEN_CREATE_TOPIC, object: nil);
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("topic_is_deleted", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                    self.backViewControlelr();
                })
                
            }else if (APIError.UserIsDeleted == remover?.errorCode){
                //user is deleted
                //refresh home
                NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_RELOADS_TOP_WHEN_CREATE_TOPIC, object: nil);
                
            }else if (APIError.YouAreDeleted == remover?.errorCode){
                //you is deleted
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("user_is_deleted", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                    
                    let loginManager = LoginManager();
                    loginManager.logOut();
                    Utils.setPremium(isPremium: false)
                    
                    Utils.setInfoAccount(infoAccount: nil);
                    Utils.setApiKey(token: "");
                    
                    self.inputToolbar.contentView?.textView?.resignFirstResponder();
                    self.inputToolbar.isHidden = true;
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
                    appDelegate.mUser = nil;
                    let login = LoginViewController();
                    let naviVC = UINavigationController(rootViewController: login);
                    appDelegate.window?.rootViewController = naviVC;
                    appDelegate.window?.makeKeyAndVisible();
                    
                })
                
            }else if (APIError.LoginAgain == remover?.errorCode){
                if (self.mUser == nil){
                    return;
                }
                //login again
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("error_11157", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                    
                    let loginManager = LoginManager();
                    loginManager.logOut();
                    Utils.setPremium(isPremium: false)
                    
                    Utils.setInfoAccount(infoAccount: nil);
                    Utils.setApiKey(token: "");
                    
                    self.inputToolbar.contentView?.textView?.resignFirstResponder();
                    self.inputToolbar.isHidden = true;
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
                    appDelegate.mUser = nil;
                    let login = LoginViewController();
                    let naviVC = UINavigationController(rootViewController: login);
                    appDelegate.window?.rootViewController = naviVC;
                    appDelegate.window?.makeKeyAndVisible();
                    
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        appDelegate.screenPosition = AppDelegate.CHAT_GROUP_POSITION;
        
        if(isLastPost) {
            self.inputToolbar.isHidden = true;
        } else {
            self.inputToolbar.isHidden = false;
        }
        self.navigationItem.title = StringUtilities.getLocalizedString("title_posting", comment: "");
        
        if ( (scrollHeader?.contentSize.height)! < 300 ){
            self.constraintHeightHeaderContent?.constant = (scrollHeader?.contentSize.height)! + 10;
            self.heightHeaderContent = (scrollHeader?.contentSize.height)!;
        }else{
            self.constraintHeightHeaderContent?.constant = 300 + 10;
            self.heightHeaderContent = 300;
        }
        
        if ( self.isDidLoad ){
            self.isDidLoad = false;
            self.constraintTopCollectionView?.constant = self.heightHeaderContent;
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        
    }
    
    override func offChatGroup() {
        super.offChatGroup();
        NSLog("ChatGroupViewController offChatGroup")
        SocketIOManager.sharedInstance.offHistoryChatGroup();
        SocketIOManager.sharedInstance.offNewMessageGroup();
        SocketIOManager.sharedInstance.offLikeMessage();
        SocketIOManager.sharedInstance.offRemoveTopicOrUser();
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if ( !appDelegate.isInternetConnected ){
            return;
        }
        
        if (!SocketIOManager.sharedInstance.connected()){
            self.view.makeToast(StringUtilities.getLocalizedString("error_code_common", comment: ""), duration: 2.0, position: .center);
            return;
        }
        let message = Message();
        message.topicId = itemHome?.topic.id;
        message.message = text;
        message.type = Message.MESSAGE_SERVER_TYPE_TEXT;
        message.like = 0;
        message.fileName = "";
        message.isLike = false;
        
        self.sendMessage(message: message, topicId : (itemHome?.topic.id)!);

    }
    
    
    //MARK: JSQMessages CollectionView DataSource
    override func senderId() -> String {
        if (mUser != nil){
            return (mUser?.id)!;
        }else{
            return "";
        }
        
    }
    
    override func senderDisplayName() -> String {
        return Utils.getFullName(user: mUser!);
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageChatList.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return convertHistory2JSMessage(messageChat: messageChatList[indexPath.row])!
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        return convertHistory2JSMessage(messageChat: messageChatList[indexPath.row])?.senderId == self.senderId() ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        
        var avatar : String = "";
        
        if (messageChatList[indexPath.row].user?.avatarSmall != nil){
            avatar = (messageChatList[indexPath.row].user?.avatarSmall)!;
        }else if(messageChatList[indexPath.row].user?.avatarMedium != nil){
            avatar = (messageChatList[indexPath.row].user?.avatarMedium)!;
        }else if(messageChatList[indexPath.row].user?.avatar != nil){
            avatar = (messageChatList[indexPath.row].user?.avatar)!;
        }
        return JSQMessagesAvatarImage(avatarLink: avatar);
 
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        
        let messageChat = messageChatList[indexPath.row]
        if ( messageChat.message?.createdTime != nil ){
            let strDate = DateTimeUtils.convertLongTimeToDateTimeString2(longTime: (messageChat.message?.createdTime)!);
            if (indexPath.row == 0){
                return NSAttributedString(string: strDate);
            }else{
                
                let preMessageChat = messageChatList[indexPath.row - 1]
                if ( preMessageChat.message?.createdTime != nil ) {
                    let preStrDate = DateTimeUtils.convertLongTimeToDateTimeString2(longTime: (preMessageChat.message?.createdTime)!);
                    if ( preStrDate != strDate ){
                        return NSAttributedString(string: strDate);
                    }
                }
            }
            
        }
        return nil;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let jsqMessage : JSQMessage = (convertHistory2JSMessage(messageChat: messageChatList[indexPath.row]))!
        
        if jsqMessage.senderId == self.senderId() {
            return nil
        }
        
        return NSAttributedString(string: jsqMessage.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        let messageChat = messageChatList[indexPath.row]
        if ( messageChat.message?.createdTime != nil ){
            let strDate = DateTimeUtils.convertLongTimeToDateTimeString2(longTime: (messageChat.message?.createdTime)!);
            if (indexPath.row == 0){
                return kJSQMessagesCollectionViewCellLabelHeightDefault;
            }else{
                
                let preMessageChat = messageChatList[indexPath.row - 1]
                if ( preMessageChat.message?.createdTime != nil ) {
                    let preStrDate = DateTimeUtils.convertLongTimeToDateTimeString2(longTime: (preMessageChat.message?.createdTime)!);
                    if ( preStrDate != strDate ){
                        return kJSQMessagesCollectionViewCellLabelHeightDefault;
                    }
                }
            }
            
        }
        return 0.0;
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        let jsqMessage : JSQMessage = (convertHistory2JSMessage(messageChat: messageChatList[indexPath.row]))!
        
        if jsqMessage.senderId == self.senderId() {
            return 0.0
        }
        
        if (indexPath as NSIndexPath).item - 1 > 0 {
            let previousMessage = (convertHistory2JSMessage(messageChat: messageChatList[indexPath.row - 1]))!
            if previousMessage.senderId == jsqMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    //MARK: JSQMessagesCollectionViewDelegateFlowLayout
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapAvatarImageView avatarImageView: UIImageView, at indexPath: IndexPath) {
        
        let userProfileVC = UserProfileViewController();
        userProfileVC.userAround = messageChatList[indexPath.row].user!;
        dismissKeyboard();
        self.present(UINavigationController(rootViewController: userProfileVC), animated: true, completion: nil);
    }
 
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapLike likeView: UIView, at indexPath: IndexPath) {
        print("didTapLike");
        if (messageChatList[indexPath.row].message != nil){
            let messageId : String? = messageChatList[indexPath.row].message!.id;
            var like : Bool? = messageChatList[indexPath.row].message!.isLike;
            if (like == nil) {
                like = false;
            }
            if (messageId != nil){
                SocketIOManager.sharedInstance.sendLikeMessage(messageId: messageId!, isLike: !like!)
            }
        }
    }
    
    
    func parserOnLikeMessage(data : Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if ( !appDelegate.isInternetConnected ){
            return;
        }
        
        print("parserOnLikeMessage \(JSON(data))" )
        let parserHelper = ParserHelper();
        let reponseLikeMessage = parserHelper.parserResponseLikeMessage(data: JSON(data));
    
        for messageChat in messageChatList {
            
            if (messageChat.message?.id == reponseLikeMessage.messageId){
                if (mUser != nil && reponseLikeMessage.user?.id == mUser?.id){
                    messageChat.message?.isLike = reponseLikeMessage.isLike;
                }
                
                messageChat.message?.like = reponseLikeMessage.like;
            }

        }
    }
	
	override func collapseHeader() {
		super.collapseHeader();
		
		self.collapse();
	}
	
	override func pressExpandOrCollapse() {
		expand();
	}
	
	func collapse() {
		if (self.isAnimation == true){
			return;
		}
		self.isAnimation = true;
		UIView.animate(withDuration: duration, animations: {
			self.viewHeaderContent.frame.size.height = 44;
			self.collectionView?.frame.origin.y = 64 + 44;
		}) { (completed : Bool) in
			self.isAnimation = false;
			
			self.viewHeaderContent.isHidden = true;
			self.viewExpand?.isHidden = false;
			
			self.constraintTopCollectionView?.constant = 44;
			self.collectionView?.frame = CGRect(x: 0, y: 64 + 44, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (64 + 44));
		}
		
	}
    
	func expand() {
		if (self.isAnimation == true){
			return;
		}
		self.isAnimation = true;
		self.viewExpand?.isHidden = true;
		self.scrollHeader?.isHidden = false;
		UIView.animate(withDuration: duration, animations: {
			self.viewHeaderContent.frame.size.height = self.heightHeaderContent + 10;
			self.collectionView?.frame.origin.y = self.heightHeaderContent + 10 + 64;
		}) { (completed : Bool) in
			self.isAnimation = false;

			self.viewHeaderContent.isHidden = false;
			self.viewExpand?.isHidden = true;

			
		}
	}
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.collapse();
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    override func handlerTabAvatar() {
        super.handlerTabAvatar();
        
        let userProfileVC = UserProfileViewController();
        userProfileVC.userAround = (itemHome?.user)!;
        dismissKeyboard();
        self.present(UINavigationController(rootViewController: userProfileVC), animated: true, completion: nil);
    }

    
    override func refreshCollectionView() {
        super.refreshCollectionView();
        
        print("[ChatGroup] refreshCollectionView")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if ( !appDelegate.isInternetConnected ){
            self.mRefreshControl.endRefreshing();
            return;
        }
        
        self.offset = self.currentPage * Const.CHAT_LOAD_MORE;
        
        self.getHistoryChat(topicId: (itemHome?.topic.id)!, isGroup: true, loadMore: true);
    }
    
    private func callApiTopicInfo(topicId: String, completeReloadData : @escaping (_ topic: Topic) -> Void) {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        var params : Dictionary = Dictionary<String, String>();
        if (mUser == nil) {
            return;
        }
        params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID);
        
        APIClient.sharedInstance.postRequest(Url: URL_TOPIC_INFO, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: false, ShowAlert: false, Success: { (success : AnyObject) in
            
            let responseJson = JSON(success);
            
            let topicInfo = responseJson[Const.KEY_RESPONSE_DATA];
            let paserHelper : ParserHelper = ParserHelper();
            
            let topic: Topic = paserHelper.pareserModel(data: topicInfo);
            self.isLastPost = topic.isOld!;
            completeReloadData(topic);
        }) { (error : AnyObject?) in
            
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true);
            }
            
            if (error != nil){
                let response = JSON(error!);
                var mes : String? = response["message"].rawString()!;
                let errorCode : String? = response["error_code"].rawString();
                if (errorCode != nil){
                    let apiError = APIError();
                    if apiError.hasErrorCode(errorCode: errorCode!){
                        mes = apiError.getMessage(errorCode: errorCode!);
                    }
                }

                Utils.showAlertWithTitle("", message: mes!, titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (action : UIAlertAction) in
                            
                    self.backViewControlelr();
                })
                
            }else{
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("error_code_common", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (action : UIAlertAction) in
                    self.backViewControlelr();
                })
            }
            
        }
    }
    
    override func pressBack(_ sender: Any) {
        super.pressBack(sender);
        
        backViewControlelr();
    }
    
    func backViewControlelr() {
        if (self.fromCreateTopic){
            dismiss(animated: true, completion: nil);
        }else{
            if ((self.navigationController?.viewControllers.count)! > 1){
                self.navigationController!.popViewController(animated: true);
            }else{
                dismiss(animated: true, completion: nil);
            }
        }
    }
}
