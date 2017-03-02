/**
 * ChatOneViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON
import FacebookLogin

class ChatOneViewController: ChatViewController{

    var userAround : User?;
    var isBlock : Bool = false;
    var isGetHistory : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
		
        self.showViewLike = false;
        
        callApiStartChat();
		
        
        if (isBlock){
            self.inputToolbar.isHidden = true;
        }else{
            self.inputToolbar.isHidden = false;
        }
        
        listenRemove();
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        appDelegate.screenPosition = AppDelegate.CHAT_ONE_POSITION;
        
        if(isBlock) {
            self.inputToolbar.isHidden = true;
        } else {
            self.inputToolbar.isHidden = false;
        }
        self.navigationItem.title = Utils.getFullName(user: self.userAround!);
        
        self.lbtitleHeader.text = Utils.getFullName(user: self.userAround!);
        
        self.viewHeaderContent.isHidden = true;
        self.viewExpand?.isHidden = true;
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatOneViewController.onNewMessage), name: Const.KEY_NOTIFICATION_NEW_MESSAGE_USER, object: nil);
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
                    self.navigationController!.popViewController(animated: true);
                })
                
            }else if (APIError.UserIsDeleted == remover?.errorCode){
                //user is deleted
                //refresh home
                NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_RELOADS_TOP_WHEN_CREATE_TOPIC, object: nil);
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("user_is_deleted", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                    self.navigationController!.popViewController(animated: true);
                })
                
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        
    }
    
    func onNewMessage(notification: NSNotification) {
        if (self.isGetHistory == false){
            return;
        }
        let data = JSON(notification.object!);
        self.parserNewMessage(data: data);
        self.finishSendingMessage(animated: true);
    }
    
    override func deinitChat() {
        NSLog("ChatOneViewController deinitChat")
        NotificationCenter.default.removeObserver(self, name: Const.KEY_NOTIFICATION_NEW_MESSAGE_USER, object: nil)
    }
	
    
    func parserNewMessage(data : JSON) {
        let parserHelper : ParserHelper = ParserHelper();
        let messageChat = parserHelper.parserMessageChat(data: data);
        
        if (messageChat.message?.isLike == nil){
            messageChat.message?.isLike = false;
        }
        
        if (messageChat.user?.id == userAround?.id){
            messageChatList.append(messageChat);
            self.finishReceivingMessage();
            SocketIOManager.sharedInstance.readMessage(messageId: (messageChat.message?.id)!);
        }
        
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
        message.topicId = self.topicId;
        message.message = text;
        message.type = Message.MESSAGE_SERVER_TYPE_TEXT;
        message.like = 0;
        message.fileName = "";
        message.isLike = false;
        
        self.sendMessage(message: message, topicId: topicId!);
    }
    
    //MARK: JSQMessages CollectionView DataSource
    override func senderId() -> String {
        return (mUser?.id)!;
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
        print("didTapAvatarImageView");
        let userProfileVC = UserProfileViewController();
        userProfileVC.userAround = messageChatList[indexPath.row].user!;
        userProfileVC.isCanChat = false;
        dismissKeyboard();
        self.present(UINavigationController(rootViewController: userProfileVC), animated: true, completion: nil);
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapLike likeView: UIView, at indexPath: IndexPath) {
        print("didTapLike");
        
    }
    
    func callApiStartChat() {
        if (userAround == nil){
            return;
        }
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue((userAround?.id)!, forKey: Const.KEY_PARAMS_USER_ID);
        
        APIClient.sharedInstance.postRequest(Url: URL_USER_START_CHAT, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: false, ShowAlert: true, Success: { (success : AnyObject) in
            let responseJson = JSON(success)["data"];
            self.topicId = responseJson["id"].stringValue;
            
            if (SocketIOManager.sharedInstance.connected()) {
                self.getHistoryChat(topicId: self.topicId!, isGroup: false, loadMore: false)
                self.isGetHistory = true;
            }else{
                MBProgressHUD.showAdded(to: self.view, animated: true);
                let when = DispatchTime.now() + 10;
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.getHistoryChat(topicId: self.topicId!, isGroup: false, loadMore: false)
                    self.isGetHistory = true;
                }
            }
            
        }) { (error : AnyObject?) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.offChatGroup();
            
        }
    }
    
    override func offChatGroup() {
        super.offChatGroup();
        NSLog("ChatOneViewController offChatGroup")
        SocketIOManager.sharedInstance.offHistoryChatOne();
        SocketIOManager.sharedInstance.offRemoveTopicOrUser();
    }
    
    override func refreshCollectionView() {
        super.refreshCollectionView();
        
        print("[ChatOne] refreshCollectionView")
        
        self.offset = self.currentPage * Const.CHAT_LOAD_MORE;
        
        self.getHistoryChat(topicId: (self.topicId)!, isGroup: true, loadMore: true);
    }
    
    override func pressBack(_ sender: Any) {
        super.pressBack(sender);
        self.navigationController!.popViewController(animated: true);
    }
}
