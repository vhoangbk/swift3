/**
 * SocketIOManager
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SocketIO
import SwiftyJSON

class SocketIOManager: NSObject {
    
    static let CHAT_SERVER_URL : String = Const.SERVER_URL + ":3000";
    
    /* server node */
    static let ACTION_CONNECT : String = "sv.connect";
    static let ON_NEW_CONNECT : String = "cl.new_connection";
    static let ON_DISCONNECT : String = "cl.disconnect";
    static let ACTION_JOIN_GROUP_CHAT : String = "sv.join_group";
    static let ACTION_HISTORY_CHAT_CHAT_GROUP : String = "sv.get_chat_history";
    static let ACTION_LEAVE_GROUP_CHAT : String = "sv.leave_group";
    static let ACTION_READ_MESSAGE : String = "sv.to_read_message";
    static let ACTION_GET_LOST_MESSAGE : String = "sv.get_lost_message";
    
    static let ON_SERVER_HISTORY_CHAT_CHAT_GROUP : String = "cl.get_chat_group_history";
    
    static let ACTION_SEND_MESSAGE : String = "sv.send_message";
    static let ON_SERVER_SEND_MESSAGE_GROUP : String = "cl.send_group_message";
    
    // Search map
    static let ACTION_SHARE_LOCATION : String = "sv.share_location";
    static let ON_SERVER_SHARE_LOCATION : String = "cl.share_location";
    static let ON_SERVER_SHARE_LOCATION_RESULT : String = "cl.share_location_result";
    static let ON_SERVER_NEW_SHARE_TOPIC = "cl.share_topic";
    static let ACTION_NEW_GROUP_CHAT = "sv.share_topic"
    
    //
    static let ON_SERVER_REMOVE_TOPIC_OR_USER = "cl.error";
    
    //like
    static let ACTION_SEND_LIKE_MESSAGE : String = "sv.like_message";
    static let ON_SERVER_SEND_LIKE_MESSAGE : String = "cl.like_message";
    
    
    //typing group
    static let ACTION_GROUP_TYPING : String = "sv.group_typing";
    static let ON_SERVER_START_GROUP_TYPING : String = "cl.start_group_typing";
    static let ON_SERVER_STOP_GROUP_TYPING : String = "cl.stop_group_typing";
    
    //chat one
    static let ON_SERVER_SEND_MESSAGE_CHAT_ONE : String = "cl.send_message";
    static let ON_SERVER_HISTORY_CHAT : String = "cl.get_chat_history";
    
    //block user
    static let ON_SERVER_BLOCK_USER : String = "cl.block_user";
    static let ACTION_BLOCK_USER : String = "sv.block_user";
    static let ON_SERVER_BLOCK_USER_RESULT : String = "cl.block_user_result";
    
    static let sharedInstance = SocketIOManager()
    
    let socket = SocketIOClient(socketURL: URL(string: SocketIOManager.CHAT_SERVER_URL)!, config: [.log(false), .forcePolling(false)])
    
    private var registerManager: Set<String> = Set<String>();
    
    override init() {
        super.init()
		
		//initTimer();
		
    }
	
	
	func initTimer(){
		Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(SocketIOManager.checkSocketConnect), userInfo: nil, repeats: true);
	}
	
	func checkSocketConnect() {
		        print("checkSocketConnect \(connected())")
	}
	
    
    func connected() -> Bool{
        return socket.status == .connected;
    }
	
    /*
     * create connect socket
     */
    func emitActionConnect(){
        NSLog("[SocketIOManager] emitActionConnect");
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser == nil){
            return;
        }
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY)
        socket.emit(SocketIOManager.ACTION_CONNECT, with: [params]);
        
    }
	
	
	func listenerGlobal() {
		onNewConnect { (data : Any) in
            NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_SOCKET_NEW_CONNECT, object: data, userInfo: nil);
		}
		
		onTypingGroup { (data : Any) in
            NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_ON_TYPING, object: data, userInfo: nil);
		}
		
		onStopTypingGroup { (data : Any) in
            NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_ON_STOP_TYPING, object: data, userInfo: nil);
		}
		
		onNewMessageUser { (data : Any) in
            NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_NEW_MESSAGE_USER, object: data, userInfo: nil);
		}
        
        onDisconnect { (data : Any) in

        }
        
        
	}
    
    func offListenerGlobal() {
        self.offListenner(event: SocketIOManager.ON_NEW_CONNECT);
        self.offListenner(event: SocketIOManager.ON_SERVER_START_GROUP_TYPING);
        self.offListenner(event: SocketIOManager.ON_SERVER_STOP_GROUP_TYPING);
        self.offListenner(event: SocketIOManager.ON_SERVER_SEND_MESSAGE_CHAT_ONE);
        self.offListenner(event: SocketIOManager.ON_DISCONNECT);
    }
    
    private func offListenner(event: String) {
        if (registerManager.contains(event)) {
            registerManager.remove(event);
            socket.off(event);
        }
    }
	
    /*
     * join group chat
     *
     * @param topicId
     */
    func joinGroup(topicId : String, reConect : Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser == nil){
            return;
        }
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY)
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID)
        socket.emit(SocketIOManager.ACTION_JOIN_GROUP_CHAT, with: [params]);
        
        NSLog("[SocketIOManager] joinGroup \(params)");
        
        if (reConect == true){
            getLostMessage(topicId: topicId);
        }
    }
    
    /*
     * get history chat group
     *
     * @param topicId
     * @param callback
     */
    func getHistoryChatGroup(topicId : String, isGroup : Bool, offset : Int, callback: @escaping NormalCallback) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        var params : Dictionary = Dictionary<String, Any>();
        if ( appDelegate.mUser != nil ){
            params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY)
        }
        
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID)
        params.updateValue(offset, forKey: Const.KEY_PARAMS_OFFSET)
        params.updateValue(Const.CHAT_LOAD_MORE, forKey: Const.KEY_PARAMS_LIMIT)
        
        NSLog("[SocketIOManager] getHistoryChatGroup \(params)")
        
        socket.emit(SocketIOManager.ACTION_HISTORY_CHAT_CHAT_GROUP, with: [params]);
        
        if (isGroup){
            socket.once(SocketIOManager.ON_SERVER_HISTORY_CHAT_CHAT_GROUP, callback: callback)
        }else{
            socket.once(SocketIOManager.ON_SERVER_HISTORY_CHAT, callback: callback)
        }
        
    }
    
    func offHistoryChatGroup() {
        socket.off(SocketIOManager.ON_SERVER_HISTORY_CHAT_CHAT_GROUP);
    }
    
    /*
     * leave Group
     */
    func leaveGroupChat(topicId : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        var params : Dictionary = Dictionary<String, Any>();
        if ( appDelegate.mUser != nil ){
            params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY)
        }
        
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID)
        
        NSLog("[SocketIOManager] leaveGroupChat \(params)");
        
        socket.emit(SocketIOManager.ACTION_LEAVE_GROUP_CHAT, with: [params]);
    }
    
    /*
     * read message chat
     */
    func readMessage(messageId : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        var params : Dictionary = Dictionary<String, Any>();
        if ( appDelegate.mUser != nil ){
            params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY)
        }
        
        params.updateValue(messageId, forKey: Const.KEY_PARAMS_MESSAGE_ID)
        
        NSLog("[SocketIOManager] readmesage \(params)");
        
        socket.emit(SocketIOManager.ACTION_READ_MESSAGE, with: [params]);
    }
    
    /*
     * send text messaget to group
     * @param text
     * @param topic_id
     */
    func sendMessageText(text : String, topicId : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser == nil){
            return;
        }
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY)
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID)
        params.updateValue(text, forKey: Const.KEY_PARAMS_MESSAGE)
        params.updateValue(String(Message.MESSAGE_SERVER_TYPE_TEXT), forKey: Const.KEY_PARAMS_TYPE)
        
        socket.emit(SocketIOManager.ACTION_SEND_MESSAGE, with: [params]);
        
        NSLog("[SocketIOManager] sendMessageText \(params)");
    }
    
    func onNewMessageGroup(onNewMessage : @escaping (_ data : Any?) -> Void) {
        socket.on(SocketIOManager.ON_SERVER_SEND_MESSAGE_GROUP) { (dataArray, socketAck) in
            onNewMessage(dataArray[0]);
        }
    }

    func offNewMessageGroup() {
        socket.off(SocketIOManager.ON_SERVER_SEND_MESSAGE_GROUP);
    }
    
    func emitTyping(isTyping : Bool, topicId : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser == nil){
            return;
        }
        var params : Dictionary = Dictionary<String, Any>();
        params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID);
        params.updateValue(isTyping, forKey: Const.KEY_PARAMS_TYPING);
        
        socket.emit(SocketIOManager.ACTION_GROUP_TYPING, with: [params]);
        
        NSLog("[SocketIOManager] emitTyping \(params)");
    }
    
    func onTypingGroup(onTyping : @escaping (_ data : Any?) -> Void) {
        let event: String = SocketIOManager.ON_SERVER_START_GROUP_TYPING;
        
        if (!registerManager.contains(event)) {
            registerManager.insert(event);
            
            socket.on(event) { (dataArray, socketAck) in
                onTyping(dataArray[0]);
                NSLog("[SocketIOManager] onTypingGroup \(dataArray[0])");
            }
        }
    }
    
    func offTypingGroup() {
        socket.off(SocketIOManager.ON_SERVER_START_GROUP_TYPING);
    }
    
    func onStopTypingGroup(onStopTyping : @escaping (_ data : Any?) -> Void) {
        let event: String = SocketIOManager.ON_SERVER_STOP_GROUP_TYPING;
        
        if (!registerManager.contains(event)) {
            registerManager.insert(event);
            
            socket.on(event) { (dataArray, socketAck) in
                onStopTyping(dataArray[0]);
                NSLog("[SocketIOManager] onStopTypingGroup \(dataArray[0])");
            }
        }
    }
    
    func offStopTypingGroup() {
        socket.off(SocketIOManager.ON_SERVER_STOP_GROUP_TYPING);
    }
    
    /*
     * send image to group
     */
    func sendImageToGroup(url : String, paththumbnail : String, fileName : String, topicId : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser == nil){
            return;
        }
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID);
        params.updateValue(url, forKey: Const.KEY_PARAMS_MESSAGE)
        params.updateValue(String(Message.MESSAGE_SERVER_TYPE_IMAGE), forKey: Const.KEY_PARAMS_TYPE)
        params.updateValue(fileName, forKey: Const.KEY_PARAMS_FILE_NAME_IMAGE)
        params.updateValue(paththumbnail, forKey: Const.KEY_PARAMS_THUMBNAIL)
                
        socket.emit(SocketIOManager.ACTION_SEND_MESSAGE, with: [params]);
        
        NSLog("[SocketIOManager] sendImageToGroup \(params)");
    }
    
    /*
     * send location to group
     */
    func sendLocationToGroup(url : String, paththumbnail : String, fileName : String, topicId : String, latitude : String, lontitude : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser == nil){
            return;
        }
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID);
        params.updateValue(url, forKey: Const.KEY_PARAMS_MESSAGE)
        params.updateValue(String(Message.MESSAGE_SERVER_TYPE_LOCATION), forKey: Const.KEY_PARAMS_TYPE)
        params.updateValue(fileName, forKey: Const.KEY_PARAMS_FILE_NAME_IMAGE)
        params.updateValue(latitude, forKey: Const.KEY_PARAMS_LATITUDE)
        params.updateValue(lontitude, forKey: Const.KEY_PARAMS_LONGITUDE)
        params.updateValue(paththumbnail, forKey: Const.KEY_PARAMS_THUMBNAIL)
        
        socket.emit(SocketIOManager.ACTION_SEND_MESSAGE, with: [params]);
        
        NSLog("[SocketIOManager] sendLocationToGroup \(params)");
    }
    
    func sendLikeMessage(messageId : String, isLike : Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser == nil){
            return;
        }
        var params : Dictionary = Dictionary<String, Any>();
        params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(messageId, forKey: Const.KEY_PARAMS_MESSAGE_ID);
        params.updateValue(isLike, forKey: Const.KEY_PARAMS_IS_LIKE);
        
        NSLog("[SocketIOManager] sendLikeMessage \(params)" );
        
        socket.emit(SocketIOManager.ACTION_SEND_LIKE_MESSAGE, with: [params]);
    }
    
    /*
     * listener like message chat group
     */
    func onLikeMessage(onLikeMessage : @escaping (_ data : Any?) -> Void) {
        socket.on(SocketIOManager.ON_SERVER_SEND_LIKE_MESSAGE) { (dataArray, socketAck) in
            onLikeMessage(dataArray[0]);
            NSLog("[SocketIOManager] onLikeMessage \(dataArray[0])");
        }
    }
    
    func offLikeMessage() {
        socket.off(SocketIOManager.ON_SERVER_SEND_LIKE_MESSAGE);
    }
    
    /*
     * listener new connect socket
     */
    func onNewConnect(onNewConnect : @escaping (_ data : Any?) -> Void) {
        let event: String = SocketIOManager.ON_NEW_CONNECT;
        
        if (!registerManager.contains(event)) {
            registerManager.insert(event);
            
            socket.on(event) { (dataArray, socketAck) in
                NSLog("[SocketIOManager] onNewConnect")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate;
                if ( appDelegate.mUser != nil){
                    self.emitActionConnect();
                }
                
                onNewConnect(dataArray[0]);
            }
        }
    }
    
    /*
     * listener disconnect socket
     */
    func onDisconnect(onDisconnect : @escaping (_ data : Any?) -> Void) {
        let event: String = SocketIOManager.ON_DISCONNECT;
        
        if (!registerManager.contains(event)) {
            registerManager.insert(event);
            
            socket.on(event) { (dataArray, socketAck) in
                NSLog("[SocketIOManager] onDisconnect")
                onDisconnect(dataArray[0]);
                self.socket.disconnect();
            }
        }
    }

    /*
     * get history chat one
     *
     * @param sendTo : id user
     * @param callback
     */
    func getHistoryChatOne(sendTo : String, callback: @escaping NormalCallback) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser == nil){
            return;
        }
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY)
        params.updateValue(sendTo, forKey: Const.KEY_PARAMS_SEND_TO)
        socket.emit(SocketIOManager.ACTION_HISTORY_CHAT_CHAT_GROUP, with: [params]);
        
        socket.once(SocketIOManager.ON_SERVER_HISTORY_CHAT, callback: callback)
        
        NSLog("[SocketIOManager] getHistoryChatOne \(params)" );
    }
    
    func offHistoryChatOne() {
        socket.off(SocketIOManager.ON_SERVER_HISTORY_CHAT);
    }
    
    
    /*
     * send text messaget to user
     * @param text
     * @param topic_id
     */
    func sendMessageTextToUser(text : String, userId : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser == nil){
            return;
        }
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY)
        params.updateValue(userId, forKey: Const.KEY_PARAMS_SEND_TO)
        params.updateValue(text, forKey: Const.KEY_PARAMS_MESSAGE)
        params.updateValue(String(Message.MESSAGE_SERVER_TYPE_TEXT), forKey: Const.KEY_PARAMS_TYPE)
        
        socket.emit(SocketIOManager.ACTION_SEND_MESSAGE, with: [params]);
        
        NSLog("[SocketIOManager] sendMessageTextToUser \(params)" );
    }
    
    /*
     * listen new message user
     */
    func onNewMessageUser(onNewMessage : @escaping (_ data : Any?) -> Void) {
        let event: String = SocketIOManager.ON_SERVER_SEND_MESSAGE_CHAT_ONE;
        
        if (!registerManager.contains(event)) {
            registerManager.insert(event);
            
            socket.on(event) { (dataArray, socketAck) in
                onNewMessage(dataArray[0]);
                NSLog("[SocketIOManager] onNewMessageUser \(dataArray[0])");
            }
        }
    }
    
    func offMessageUser() {
        socket.off(SocketIOManager.ON_SERVER_SEND_MESSAGE_CHAT_ONE);
    }
    
    /*
     * emit tying to user
     */
    func emitTypingUser(isTyping : Bool, sendTo : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser == nil){
            return;
        }
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(sendTo, forKey: Const.KEY_PARAMS_SEND_TO);
        params.updateValue(String(isTyping), forKey: Const.KEY_PARAMS_TYPING);
        
        socket.emit(SocketIOManager.ACTION_GROUP_TYPING, with: [params]);
        
        NSLog("[SocketIOManager] emitTypingUser \(params)" );
    }
    
    /*
     * send image to user
     */
    func sendImageToUser(url : String, fileName : String, sendTo : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser == nil){
            return;
        }
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(sendTo, forKey: Const.KEY_PARAMS_SEND_TO);
        params.updateValue(url, forKey: Const.KEY_PARAMS_MESSAGE)
        params.updateValue(String(Message.MESSAGE_SERVER_TYPE_IMAGE), forKey: Const.KEY_PARAMS_TYPE)
        params.updateValue(fileName, forKey: Const.KEY_PARAMS_FILE_NAME_IMAGE)
        
        socket.emit(SocketIOManager.ACTION_SEND_MESSAGE, with: [params]);
        
        NSLog("[SocketIOManager] sendImageToUser \(params)" );
    }
    
    /*
     * send location to user
     */
    func sendLocationToUser(url : String, fileName : String, sendTo : String, latitude : String, lontitude : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser == nil){
            return;
        }
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(sendTo, forKey: Const.KEY_PARAMS_SEND_TO);
        params.updateValue(url, forKey: Const.KEY_PARAMS_MESSAGE)
        params.updateValue(String(Message.MESSAGE_SERVER_TYPE_LOCATION), forKey: Const.KEY_PARAMS_TYPE)
        params.updateValue(fileName, forKey: Const.KEY_PARAMS_FILE_NAME_IMAGE)
        params.updateValue(latitude, forKey: Const.KEY_PARAMS_LATITUDE)
        params.updateValue(lontitude, forKey: Const.KEY_PARAMS_LONGITUDE)
        
        socket.emit(SocketIOManager.ACTION_SEND_MESSAGE, with: [params]);
        
        
        NSLog("[SocketIOManager] sendLocationToUser \(params)" );
    }
    
    /*
     * reconnect when onNewConnect
     */
    func getLostMessage(topicId : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        var params : Dictionary = Dictionary<String, Any>();
        if ( appDelegate.mUser != nil ){
            params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY)
        }
        
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID)
        
        NSLog("[SocketIOManager] getLostMessage \(params)");
        
        socket.emit(SocketIOManager.ACTION_GET_LOST_MESSAGE, with: [params]);
    }
    
    func connect() {
        socket.connect()
    }
    
    
    func disconnect() {
        socket.disconnect()
    }
    
    /**
     * Action emit get location share;
     *
     */
    func actionShareLocation(latitude: Double, lontitude: Double){
        var params : Dictionary = Dictionary<String, String>();
         let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser != nil && appDelegate.mUser?.apiKey != nil){
            params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        }
        params.updateValue(String(latitude), forKey: Const.KEY_PARAMS_LATITUDE);
        params.updateValue(String(lontitude), forKey: Const.KEY_PARAMS_LONGITUDE);
        
        NSLog("[SocketIOManager] Share location \(params)");
        
        socket.emit(SocketIOManager.ACTION_SHARE_LOCATION, with: [params]);
    }
    
    func onNewShareUser(onNewShareUser : @escaping (_ data : Any?) -> Void) {
        socket.on(SocketIOManager.ON_SERVER_SHARE_LOCATION) { (dataArray, socketAck) in
            onNewShareUser(dataArray[0]);
        }
    }
    
    func offNewShareUser() {
        socket.off(SocketIOManager.ACTION_SHARE_LOCATION);
    }
    
    func onServerShareLocationResult(onResultShareLocation : @escaping (_ data : Any?) -> Void) {
        socket.on(SocketIOManager.ON_SERVER_SHARE_LOCATION_RESULT) { (dataArray, socketAck) in
            onResultShareLocation(dataArray[0]);
        }
    }
    
    func offServerShareLocationResult() {
        socket.off(SocketIOManager.ON_SERVER_SHARE_LOCATION_RESULT);
    }
    
    func onNewTopicCreateShareMap(onResultTopic : @escaping (_ data : Any?) -> Void) {
        socket.on(SocketIOManager.ON_SERVER_NEW_SHARE_TOPIC) { (dataArray, socketAck) in
            onResultTopic(dataArray[0]);
        }
    }
    
    func offNewTopicCreateShareMap() {
        socket.off(SocketIOManager.ON_SERVER_NEW_SHARE_TOPIC);
    }
    
    func emitNewTopic(topicId : String) {
        var params : Dictionary = Dictionary<String, String>();
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser != nil && appDelegate.mUser?.apiKey != nil){
            params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        }
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID)
        NSLog("[SocketIOManager] Share location \(params)");
        socket.emit(SocketIOManager.ACTION_NEW_GROUP_CHAT, with: [params]);
    }
    
    /*
     * listen block user
     */
    func onBlockUser(onBlockUser : @escaping (_ data : Any?) -> Void) {
        socket.on(SocketIOManager.ON_SERVER_BLOCK_USER) { (dataArray, socketAck) in
            NSLog("[SocketIOManager] onBlockUser \(dataArray[0])");
            onBlockUser(dataArray[0]);
        }
    }
    
    func offBlockUser() {
        socket.off(SocketIOManager.ON_SERVER_BLOCK_USER);
    }
    
    func emitDoBlockUser(isBlock : Bool, userId : String, onSuccess : @escaping (_ data : Any?) -> Void) {
        NSLog("[SocketIOManager] emitDoBlockUser \(isBlock)");
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser == nil){
            return;
        }
        var params : Dictionary = Dictionary<String, Any>();
        params.updateValue((appDelegate.mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(userId, forKey: Const.KEY_PARAMS_USER_ID);
        params.updateValue(isBlock, forKey: Const.KEY_PARAMS_BLOCK_USER)
        
        socket.emit(SocketIOManager.ACTION_BLOCK_USER, with: [params]);
        
        socket.once(SocketIOManager.ON_SERVER_BLOCK_USER_RESULT) { (dataArray, socketAck) in
            NSLog("[SocketIOManager] ON_SERVER_BLOCK_USER_RESULT \(dataArray[0])");
            onSuccess(JSON(dataArray[0]));
        }
    }
    
    /*
     * listener remove topic or user
     */
    func onRemoveTopicOrUser(onRemove : @escaping (_ data : Any?) -> Void) {
        let event: String = SocketIOManager.ON_SERVER_REMOVE_TOPIC_OR_USER;
        
        socket.on(event) { (dataArray, socketAck) in
            NSLog("[SocketIOManager] onRemoveTopicOrUser \(dataArray[0])")
            onRemove(dataArray[0]);
        }
    }
    
    /*
     * off listen remove topic or user
     */
    func offRemoveTopicOrUser() {
        socket.off(SocketIOManager.ON_SERVER_REMOVE_TOPIC_OR_USER);
    }
    
}
