/**
 * Topic
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import ObjectMapper

class Topic: NSObject, Mappable {
    var id: String?
    var content: String?
    var distance: Int?
    var title: String?
    var category: Int?
    var messageCount: Int?
    var createdTime: Int?
    var limitCategory: Int?
    var limitTime: Int?
    var language: String?
    var latitude: Double?
    var longitude: Double?
    var userCreate : User?
    var address: Address?
    var isOld: Bool?
    
    required init?(map: Map) {
        
    }
    
    init(id : String, title: String, content: String, category: Int, latitude : Double, longitude : Double){
        self.id = id;
        self.title = title;
        self.content = content;
        self.category = category;
        self.latitude = latitude;
        self.longitude = longitude;
    }
    
    init(id : String, title: String, content: String, category: Int){
        self.id = id;
        self.title = title;
        self.content = content;
        self.category = category;
    }
    
    init(id : String){
        self.id = id;
    }
    
    func mapping(map: Map) {
        id    <- map["id"]
        content    <- map["content"]
        distance    <- map["distance"]
        title    <- map["title"]
        category    <- map["category"]
        messageCount    <- map["message_count"]
        createdTime    <- map["created_time"]
        limitCategory    <- map["limit_category"]
        limitTime    <- map["limit_time"]
        language    <- map["language"]
        latitude    <- map["latitude"]
        longitude    <- map["longitude"]
        userCreate <- map["user_create"];
        address <- map["address"];
        isOld <- map["is_old"];
        
    }
    
    override init() {
        
    }
    
}
