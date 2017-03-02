/**
 * ResponseLikeMessage
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import ObjectMapper

class ResponseLikeMessage: Mappable {
    
    var isLike: Bool?
    var messageId: String?
    var topicId: String?
    var like: Int?
    
    var user : User?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        isLike    <- map["is_like"]
        messageId    <- map["message_id"]
        topicId    <- map["topic_id"]
        like    <- map["like"]
        user    <- map["user"]
       
    }
}
