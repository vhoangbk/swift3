//
//  ChatOneViewController.swift
//  Locozap
//
//  Created by paraline on 10/12/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChatOneViewController: ChatViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ScreenShotMapViewControllerDelegate {

    var userAround : User?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        imagePicker.delegate = self;
        
        self.showViewLike = false;
        
        
        socketManager.getHistoryChatOne(sendTo: (userAround?.id)!) { (data, ick) -> Void in
            print("[ChatOneViewController] onHistoryChatOne")
            self.parserHistory(data: JSON(data[0]));
            self.finishSendingMessage(animated: true)
        }
        
        socketManager.onNewMessageUser { (data : Any) in
            self.parserNewMessage(data: JSON(data));
            self.finishSendingMessage(animated: true);
        }
        
        socketManager.onTypingGroup { (data : Any) in
            self.showTypingIndicator = true;
            
            let paserHelper = ParserHelper();
            let user = paserHelper.parserUser(data: JSON(data));
            self.userTyping = (user.fistName)! + " " + (user.lastName)!;
            
            self.finishSendingMessage(animated: true);
        }
        
        socketManager.onStopTypingGroup { (data : Any) in
            self.showTypingIndicator = false
            self.finishSendingMessage(animated: true);
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationItem.title = (self.userAround?.fistName)! + " " + (self.userAround?.lastName)!;
        
        self.viewHeaderContent.isHidden = true;
        self.viewExpand?.isHidden = true;
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        
        socketManager.offHistoryChatOne();
        socketManager.offMessageUser();
        socketManager.offTypingGroup();
        socketManager.offStopTypingGroup();
    }
    
    func parserNewMessage(data : JSON) {
        let parserHelper : ParserHelper = ParserHelper();
        let messageJson = data["message"];
        let message = parserHelper.parserMessage(data: messageJson);
        
        let userJson = data["user"];
        let user = parserHelper.parserUser(data: userJson);
        
        //add to get avatar
        historyList.append(History(user: user, message: message));
    }
    
    /*
     * parser history
     */
    func parserHistory(data : JSON) {
        for history in data.arrayValue {
            let parserHelper : ParserHelper = ParserHelper();
            let messageJson = history["message"];
            let message = parserHelper.parserMessage(data: messageJson);
            
            let userJson = history["user"];
            let user = parserHelper.parserUser(data: userJson);
            
            let history = History(user: user, message: message)
            historyList.append(history);
            
        }
    }
    /*
     * convert hitory to jsqmessage
     */
    func convertHistory2JSMessage(history : History) -> JSQMessage?{
        
        let user : User = history.user!;
        let message : Message = history.message!;
        
        var jsqMessage : JSQMessage?;
        if message.type == Message.MESSAGE_SERVER_TYPE_TEXT {
            jsqMessage = JSQMessage.init(senderId: user.id!, displayName: "\(user.fistName!) \(user.lastName!)", text: message.message!);
        }else if message.type == Message.MESSAGE_SERVER_TYPE_IMAGE {
            let JsqPhoto = JSQPhotoMediaItem(link: message.message);
            jsqMessage = JSQMessage(senderId: user.id!, displayName: "\(user.fistName!) \(user.lastName!)", media: JsqPhoto);
        }else if(message.type == Message.MESSAGE_SERVER_TYPE_LOCATION){
            //            let lat = message.latitude!;
            //            let lon = message.longitude!
            //            var location : CLLocation?;
            //            if (lat != "" && lon != ""){
            //                location = CLLocation(latitude: CLLocationDegrees(message.latitude!)!, longitude: CLLocationDegrees(message.longitude!)!)
            //
            //            }else{
            //                location = CLLocation();
            //            }
            
            let JsqPhoto = JSQPhotoMediaItem(link: message.message);
            
            //            let JsqLocation = JSQLocationMediaItem(location: location)
            jsqMessage = JSQMessage(senderId: user.id!, displayName: "\(user.fistName!) \(user.lastName!)", media: JsqPhoto);
        }
        
        if jsqMessage != nil {
            jsqMessage!.isLike = message.isLike!;
            jsqMessage!.numberLike = message.like!;
        }
        
        return jsqMessage;
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let locationAction = UIAlertAction(title: NSLocalizedString("choose_share_location", comment: ""), style: .default) { (action) in
            self.openShareLocation();
        }
        
        let takePhotoAction = UIAlertAction(title: NSLocalizedString("choose_camera", comment: ""), style: .default) { (action) in
            self.openCamera()
        }
        
        let photoAction = UIAlertAction(title: NSLocalizedString("choose_gallery", comment: ""), style: .default) { (action) in
            self.openPhoto();
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        
        sheet.addAction(locationAction)
        sheet.addAction(takePhotoAction)
        sheet.addAction(photoAction)
        
        sheet.addAction(cancelAction)
        
        sheet.popoverPresentationController?.sourceView = view
        sheet.popoverPresentationController?.sourceRect = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 50, width: 50, height: 50);
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    func openShareLocation() {
        let locationVC = ScreenShotMapViewController();
        locationVC.delegate = self;
        self.present(locationVC, animated: true, completion: nil);
    }
    
    func buildLocationItem() -> JSQLocationMediaItem {
        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)
        
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF) {
            self.collectionView!.reloadData()
        }
        
        return locationItem
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        //add to list history to get avarta
        let hisMessage = Message(id: "", topicId: "", message: text, like: 0, fileName: "", type: Message.MESSAGE_SERVER_TYPE_TEXT, size: "", createdTime: "", latitude: "", longitude: "", isLike: false)
        historyList.append(History(user: mUser!, message: hisMessage));
        
        self.finishSendingMessage(animated: true)
        self.sendMessageText(text: text);
    }
    
    //MARK: JSQMessages CollectionView DataSource
    override func senderId() -> String {
        return (mUser?.id)!;
    }
    
    override func senderDisplayName() -> String {
        return "\(mUser?.fistName) \(mUser?.lastName)"
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historyList.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return convertHistory2JSMessage(history: historyList[indexPath.row])!
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        return convertHistory2JSMessage(history: historyList[indexPath.row])?.senderId == self.senderId() ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        //        let message = messages[(indexPath as NSIndexPath).item]
        //        return getAvatar(message.senderId)
        
        let avatar = JSQMessagesAvatarImage(avatarLink: (historyList[indexPath.row].user?.avatar)!);
        
        return avatar;
        
        //        return JSQMessagesAvatarImage(avatarImage: UIImage(named: "avatar_no_image"), highlightedImage: UIImage(named: "avatar_no_image"), placeholderImage: UIImage(named: "avatar_no_image")!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        //show time
        
        //        if ((indexPath as NSIndexPath).item % 3 == 0) {
        //            let message = self.messages[(indexPath as NSIndexPath).item]
        //
        //            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        //        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let jsqMessage : JSQMessage = (convertHistory2JSMessage(history: historyList[indexPath.row]))!
        
        if jsqMessage.senderId == self.senderId() {
            return nil
        }
        
        return NSAttributedString(string: jsqMessage.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        //        if (indexPath as NSIndexPath).item % 3 == 0 {
        //            return kJSQMessagesCollectionViewCellLabelHeightDefault
        //        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        let jsqMessage : JSQMessage = (convertHistory2JSMessage(history: historyList[indexPath.row]))!
        
        if jsqMessage.senderId == self.senderId() {
            return 0.0
        }
        
        if (indexPath as NSIndexPath).item - 1 > 0 {
            let previousMessage = (convertHistory2JSMessage(history: historyList[indexPath.row - 1]))!
            if previousMessage.senderId == jsqMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    func sendMessageText(text : String) {
        socketManager.sendMessageTextToUser(text: text, userId: (userAround?.id)!)
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.hasText {
            if (self.isTyping == false){
                self.isTyping = true;
                socketManager.emitTypingUser(isTyping: true, sendTo: (userAround?.id)!)
            }
            timer?.invalidate();
            self.timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(ChatOneViewController.stopTyping), userInfo: nil, repeats: false);
            
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
        socketManager.emitTypingUser(isTyping: false, sendTo: (userAround?.id)!)
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let fileName = self.generateFileName();
            
            let message = Message(id: "", topicId: "", message: "", like: 0, fileName: fileName, type: Message.MESSAGE_SERVER_TYPE_IMAGE, size: "", createdTime: "", latitude: "", longitude: "", isLike: false);

            
            uploadImage(image: pickedImage, message: message)
            
            dismiss(animated:true, completion: nil)
        }
        
    }
    
    func sendImageToUser(url : String, fileName: String) {
        socketManager.sendImageToUser(url: url, fileName: fileName, sendTo: (userAround?.id)!)
    }
    
    func sendLocationToUser(url : String, fileName: String, latitude : String, lontitude : String) {
        socketManager.sendLocationToUser(url: url, fileName: fileName, sendTo: (userAround?.id)!, latitude: latitude, lontitude: lontitude)
    }
    
    func generateFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: Date());
    }
    
    //MARK: JSQMessagesCollectionViewDelegateFlowLayout
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapAvatarImageView avatarImageView: UIImageView, at indexPath: IndexPath) {
        print("didTapAvatarImageView");
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapLike likeView: UIView, at indexPath: IndexPath) {
        print("didTapLike");
        
        let messageId : String? = historyList[indexPath.row].message?.id;
        
        socketManager.sendLikeMessage(messageId: messageId!)
    }
    
    //MARK: ScreenShotMapViewControllerDelegate
    func didShareLocation(currentLocation: CLLocationCoordinate2D, image: UIImage) {
        let fileName = self.generateFileName();
        let message = Message(id: "", topicId: "", message: "", like: 0, fileName: fileName, type: Message.MESSAGE_SERVER_TYPE_LOCATION, size: "", createdTime: "", latitude: String(currentLocation.latitude), longitude: String(currentLocation.longitude), isLike: false);
        self.uploadImage(image: image, message: message);
    }
    
    func uploadImage(image : UIImage, message : Message) {
        let fileName = self.generateFileName();
        APIClient.sharedInstance.uploadImage(image: image, name: fileName, Success: { (success : AnyObject) in
            //emit,update ui
            
            let responseJson = JSON(success)["data"];
            let fileName = responseJson["file_name"].stringValue;
            let url = responseJson["url"].stringValue;
            
            message.fileName = fileName;
            message.message = url;
            if (Message.MESSAGE_SERVER_TYPE_LOCATION == message.type){
                self.sendLocationToUser(url: url, fileName: fileName, latitude: message.latitude!, lontitude: message.longitude!);
            }else{
                self.sendImageToUser(url: url, fileName: fileName);
            }
            
            self.historyList.append(History(user: self.mUser!, message: message));
            
            self.finishSendingMessage(animated: true)
            
            }, Failure: { (error : AnyObject?) in
                //error, update ui
        })
    }
    
}
