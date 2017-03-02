/**
 * Message
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import ObjectMapper

class Message: Mappable {
    
    static let MESSAGE_SERVER_TYPE_TEXT = 1;
    static let MESSAGE_SERVER_TYPE_IMAGE = 3;
    static let MESSAGE_SERVER_TYPE_LOCATION = 2;
    
    static let STATUS_LOADED = 1;
    static let STATUS_UPLOADING = 2;
    static let STATUS_UPLOAD_FAILED = 3;
    
    var id : String?;
    var message: String?
    var topicId: String?
    var fileName: String?
    var createdTime: Int?
    var like: Int?
    var type: Int?
    var latitude: Double?
    var longitude: Double?
    var isLike: Bool?
    var size: String?
    var thumbnail: String?
    
    var image : UIImage?
    var status : Int = STATUS_LOADED;
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id    <- map["id"]
        message    <- map["message"]
        topicId    <- map["topic_id"]
        fileName    <- map["file_name"]
        createdTime    <- map["created_time"]
        like    <- map["like"]
        type    <- map["type"]
        latitude    <- map["latitude"]
        longitude    <- map["longitude"]
        isLike    <- map["is_like"]
        size    <- map["size"]
        thumbnail    <- map["thumbnail"]
    }
    
    init() {
        
    }
    
}
