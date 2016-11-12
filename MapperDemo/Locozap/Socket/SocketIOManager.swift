//
//  SocketIOManager.swift
//  SocketChat
//
//  Created by Gabriel Theodoropoulos on 1/31/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    
    static let CHAT_SERVER_URL : String = Const.SERVER_URL + ":3000";
    
    /* server node */
    static let ACTION_CONNECT : String = "sv.connect";
    static let ON_NEW_CONNECT : String = "cl.new_connection";
    static let ACTION_JOIN_GROUP_CHAT : String = "sv.join_group";
    static let ACTION_HISTORY_CHAT_CHAT_GROUP : String = "sv.get_chat_history";
    static let ON_SERVER_HISTORY_CHAT_CHAT_GROUP : String = "cl.get_chat_group_history";
    
    static let ACTION_SEND_MESSAGE : String = "sv.send_message";
    static let ON_SERVER_SEND_MESSAGE_GROUP : String = "cl.send_group_message";
    
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
    
    static let sharedInstance = SocketIOManager()
    
    let socket = SocketIOClient(socketURL: URL(string: SocketIOManager.CHAT_SERVER_URL)!, config: [.log(false), .forcePolling(false)])
    
    
    override init() {
        super.init()
        
        socket.on(SocketIOManager.ON_NEW_CONNECT) { ( data : [Any], ack : SocketAckEmitter) -> Void in
            self.connectSocket();
        }
    
        
    }
    
    /*
     * create connect socket
     */
    func connectSocket(){
        print("[SocketIOManager] connectSocket");
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.token)!, forKey: Const.KEY_PARAMS_TOKEN)
        socket.emit(SocketIOManager.ACTION_CONNECT, with: [params]);
        
    }
    
    
    func connect() {
        print("[SocketIOManager] connect")
        socket.connect()
    }
    
    
    func disconnect() {
        print("[SocketIOManager] disconnect")
        socket.disconnect()
    }
    
    /*
     * join group chat
     *
     * @param topicId
     */
    func joinGroup(topicId : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.token)!, forKey: Const.KEY_PARAMS_TOKEN)
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID)
        socket.emit(SocketIOManager.ACTION_JOIN_GROUP_CHAT, with: [params]);
    }
    
    /*
     * get history chat group
     *
     * @param topicId
     * @param callback
     */
    func getHistoryChatGroup(topicId : String, callback: @escaping NormalCallback) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.token)!, forKey: Const.KEY_PARAMS_TOKEN)
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID)
        socket.emit(SocketIOManager.ACTION_HISTORY_CHAT_CHAT_GROUP, with: [params]);
        
        socket.once(SocketIOManager.ON_SERVER_HISTORY_CHAT_CHAT_GROUP, callback: callback)
    }
    
    func offHistoryChatGroup() {
        socket.off(SocketIOManager.ON_SERVER_HISTORY_CHAT_CHAT_GROUP);
    }
    
    /*
     * send text messaget to group
     * @param text
     * @param topic_id
     */
    func sendMessageText(text : String, topicId : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.token)!, forKey: Const.KEY_PARAMS_TOKEN)
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID)
        params.updateValue(text, forKey: Const.KEY_PARAMS_MESSAGE)
        params.updateValue(String(Message.MESSAGE_SERVER_TYPE_TEXT), forKey: Const.KEY_PARAMS_TYPE)
        
        socket.emit(SocketIOManager.ACTION_SEND_MESSAGE, with: [params]);
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
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.token)!, forKey: Const.KEY_PARAMS_TOKEN);
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID);
        params.updateValue(String(isTyping), forKey: Const.KEY_PARAMS_TYPING);
        
        socket.emit(SocketIOManager.ACTION_GROUP_TYPING, with: [params]);
    }
    
    func onTypingGroup(onTyping : @escaping (_ data : Any?) -> Void) {
        socket.on(SocketIOManager.ON_SERVER_START_GROUP_TYPING) { (dataArray, socketAck) in
            onTyping(dataArray[0]);
        }
    }
    
    func offTypingGroup() {
        socket.off(SocketIOManager.ON_SERVER_START_GROUP_TYPING);
    }
    
    func onStopTypingGroup(onStopTyping : @escaping (_ data : Any?) -> Void) {
        socket.on(SocketIOManager.ON_SERVER_STOP_GROUP_TYPING) { (dataArray, socketAck) in
            onStopTyping(dataArray[0]);
        }
    }
    
    func offStopTypingGroup() {
        socket.off(SocketIOManager.ON_SERVER_STOP_GROUP_TYPING);
    }
    
    /*
     * send image to group
     */
    func sendImageToGroup(url : String, fileName : String, topicId : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.token)!, forKey: Const.KEY_PARAMS_TOKEN);
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID);
        params.updateValue(url, forKey: Const.KEY_PARAMS_MESSAGE)
        params.updateValue(String(Message.MESSAGE_SERVER_TYPE_IMAGE), forKey: Const.KEY_PARAMS_TYPE)
        params.updateValue(fileName, forKey: Const.KEY_PARAMS_FILE_NAME_IMAGE)
        
        socket.emit(SocketIOManager.ACTION_SEND_MESSAGE, with: [params]);
    }
    
    /*
     * send location to group
     */
    func sendLocationToGroup(url : String, fileName : String, topicId : String, latitude : String, lontitude : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.token)!, forKey: Const.KEY_PARAMS_TOKEN);
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID);
        params.updateValue(url, forKey: Const.KEY_PARAMS_MESSAGE)
        params.updateValue(String(Message.MESSAGE_SERVER_TYPE_LOCATION), forKey: Const.KEY_PARAMS_TYPE)
        params.updateValue(fileName, forKey: Const.KEY_PARAMS_FILE_NAME_IMAGE)
        params.updateValue(latitude, forKey: Const.KEY_PARAMS_LATITUDE)
        params.updateValue(lontitude, forKey: Const.KEY_PARAMS_LONGITUDE)
        
        socket.emit(SocketIOManager.ACTION_SEND_MESSAGE, with: [params]);
    }
    
    func sendLikeMessage(messageId : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.token)!, forKey: Const.KEY_PARAMS_TOKEN);
        params.updateValue(messageId, forKey: Const.KEY_PARAMS_MESSAGE_ID);
        
        socket.emit(SocketIOManager.ACTION_SEND_LIKE_MESSAGE, with: [params]);
    }
    
    /*
     * listener like message chat group
     */
    func onLikeMessage(onLikeMessage : @escaping (_ data : Any?) -> Void) {
        socket.on(SocketIOManager.ON_SERVER_SEND_LIKE_MESSAGE) { (dataArray, socketAck) in
            onLikeMessage(dataArray[0]);
        }
    }
    
    func offLikeMessage() {
        socket.off(SocketIOManager.ON_SERVER_SEND_LIKE_MESSAGE);
    }
    
    /*
     * listener new connect socket
     */
    func onNewConnect(onNewConnect : @escaping (_ data : Any?) -> Void) {
        print("[SocketIOManager] onNewConnect")
        socket.on(SocketIOManager.ON_NEW_CONNECT) { (dataArray, socketAck) in
            onNewConnect(dataArray[0]);
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
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.token)!, forKey: Const.KEY_PARAMS_TOKEN)
        params.updateValue(sendTo, forKey: Const.KEY_PARAMS_SEND_TO)
        socket.emit(SocketIOManager.ACTION_HISTORY_CHAT_CHAT_GROUP, with: [params]);
        
        socket.once(SocketIOManager.ON_SERVER_HISTORY_CHAT, callback: callback)
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
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.token)!, forKey: Const.KEY_PARAMS_TOKEN)
        params.updateValue(userId, forKey: Const.KEY_PARAMS_SEND_TO)
        params.updateValue(text, forKey: Const.KEY_PARAMS_MESSAGE)
        params.updateValue(String(Message.MESSAGE_SERVER_TYPE_TEXT), forKey: Const.KEY_PARAMS_TYPE)
        
        socket.emit(SocketIOManager.ACTION_SEND_MESSAGE, with: [params]);
    }
    
    /*
     * listen new message user
     */
    func onNewMessageUser(onNewMessage : @escaping (_ data : Any?) -> Void) {
        socket.on(SocketIOManager.ON_SERVER_SEND_MESSAGE_CHAT_ONE) { (dataArray, socketAck) in
            onNewMessage(dataArray[0]);
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
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.token)!, forKey: Const.KEY_PARAMS_TOKEN);
        params.updateValue(sendTo, forKey: Const.KEY_PARAMS_SEND_TO);
        params.updateValue(String(isTyping), forKey: Const.KEY_PARAMS_TYPING);
        
        socket.emit(SocketIOManager.ACTION_GROUP_TYPING, with: [params]);
    }
    
    /*
     * send image to user
     */
    func sendImageToUser(url : String, fileName : String, sendTo : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.token)!, forKey: Const.KEY_PARAMS_TOKEN);
        params.updateValue(sendTo, forKey: Const.KEY_PARAMS_SEND_TO);
        params.updateValue(url, forKey: Const.KEY_PARAMS_MESSAGE)
        params.updateValue(String(Message.MESSAGE_SERVER_TYPE_IMAGE), forKey: Const.KEY_PARAMS_TYPE)
        params.updateValue(fileName, forKey: Const.KEY_PARAMS_FILE_NAME_IMAGE)
        
        socket.emit(SocketIOManager.ACTION_SEND_MESSAGE, with: [params]);
    }
    
    /*
     * send location to user
     */
    func sendLocationToUser(url : String, fileName : String, sendTo : String, latitude : String, lontitude : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((appDelegate.mUser?.token)!, forKey: Const.KEY_PARAMS_TOKEN);
        params.updateValue(sendTo, forKey: Const.KEY_PARAMS_SEND_TO);
        params.updateValue(url, forKey: Const.KEY_PARAMS_MESSAGE)
        params.updateValue(String(Message.MESSAGE_SERVER_TYPE_LOCATION), forKey: Const.KEY_PARAMS_TYPE)
        params.updateValue(fileName, forKey: Const.KEY_PARAMS_FILE_NAME_IMAGE)
        params.updateValue(latitude, forKey: Const.KEY_PARAMS_LATITUDE)
        params.updateValue(lontitude, forKey: Const.KEY_PARAMS_LONGITUDE)
        
        socket.emit(SocketIOManager.ACTION_SEND_MESSAGE, with: [params]);
    }
}
