//
//  ParserHelper.swift
//  Locozap
//
//  Created by paraline on 10/13/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit
import SwiftyJSON

class ParserHelper: NSObject {

    func parserUser(data : JSON) -> User {
        let id = data["id"].stringValue;
        let fistName = data["firstname"].stringValue;
        let lastName = data["lastname"].stringValue;
        let email = data["email"].stringValue;
        let token = data["api_key"].stringValue;
        let avatar = data["avatar"].stringValue;
        let birthday = data["birthday"].stringValue;
        let country = data["country"].stringValue;
        var latitude = data["latitude"].stringValue;
        if (latitude == "") {
            latitude = "0";
        }
        var longitude = data["longitude"].stringValue;
        if (longitude == "") {
            longitude = "0";
        }
        
        let user = User(id: id, fistName: fistName, lastName: lastName, email: email, country: country, avatar: avatar, birthday: birthday, token: token, latitude: latitude, longitude: longitude);
        
        if (data["is_like"] != nil && data["is_like"].stringValue != ""){
            let isLike =  data["is_like"].boolValue;
            user.isLike = isLike;
        }
        
        return user;
        
    }
    
    func parserMessage(data : JSON) -> Message {
        let id = data["id"].stringValue;
        let topicId = data["topic_id"].stringValue;
        let createTime = data["created_time"].stringValue;
        let fileName = data["file_name"].stringValue;
        let latitude = data["latitude"].stringValue;
        let longitude = data["longitude"].stringValue;
        var like = 0;
        if (data["like"] != nil && data["like"].stringValue != ""){
            like =  Int(data["like"].stringValue)!;
        }
        let isLike = data["is_like"].boolValue;
        let messag = data["message"].stringValue;
        let size = data["size"].stringValue;
        let type = Int(data["type"].stringValue);
        return Message(id: id, topicId: topicId, message: messag, like: like, fileName: fileName, type: type!, size: size, createdTime: createTime, latitude: latitude, longitude: longitude, isLike: isLike);
    }
    
    func parserTopic(data : JSON) -> Topic {
        let content = data["content"].stringValue;
        let distance = data["distance"].stringValue;
        let icon = data["icon"].stringValue;
        let latitude = data["latitude"].stringValue;
        let longitude = data["longitude"].stringValue;
        let id = data["id"].stringValue;
        var messageCount = 0;
        if(data["message_count"] != nil && data["message_count"].stringValue != ""){
            messageCount = Int(data["message_count"].stringValue)!;
        }
        let title = data["title"].stringValue;
        return Topic.init(content: content, distance: distance, icon: icon, id: id, latitude: latitude, longitude: longitude, messageCount: messageCount, title: title);
    }
    
    func parserResponseLikeMessage(data : JSON) -> ResponseLikeMessage {
        let numberLike = Int(data["like"].stringValue);
        let messageId = data["message_id"].stringValue;
        let topicId = data["topic_id"].stringValue;
        let userJson = data["user"];
        let user = parserUser(data: userJson);
        return ResponseLikeMessage(numberLike: numberLike!, messageId: messageId, topicId: topicId, user: user);
    }
}
