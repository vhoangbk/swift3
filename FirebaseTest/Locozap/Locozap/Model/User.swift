/**
 * User
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */


import UIKit
import ObjectMapper

class User:NSObject, Mappable {
    
    var id: String?
    var fistName: String?
    var lastName: String?
    var email: String?
    var birthday: Int?
    var sex: Int?
    var address: String?
    var avatar: String?
    var avatarMedium: String?
    var avatarSmall: String?
    var introduction: String?
    var language: [Language]?
    var like: Int?
    var apiKey: String?
    
    var latitude: Double?
    var longitude: Double?
    var isLike: String?
    
    var codeCountry: String?
    
    var isBlock : Bool?
    var topicId: String?
    
    var unReadTotal: Int?
    var premiumAccount: Bool?;
    
    var facebookAccount : Bool?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id    <- map["id"]
        fistName    <- map["first_name"]
        lastName    <- map["last_name"]
        email    <- map["email"]
        birthday    <- map["birthday"]
        sex    <- map["sex"]
        address    <- map["address"]
        
        avatar    <- map["avatar"]
        avatarMedium    <- map["avatar_medium"]
        avatarSmall    <- map["avatar_small"]
        
        introduction    <- map["introduction"]
        language    <- map["language"]
        like    <- map["like"]
        apiKey    <- map["api_key"]
        
        latitude    <- map["latitude"]
        longitude    <- map["longitude"]
        isLike    <- map["is_like"]
        
        codeCountry    <- map["country"]
        isBlock    <- map["is_block"]
        topicId    <- map["topic_id"]
        
        unReadTotal <- map["unread_total"]
        premiumAccount <- map["premium_account"]
        facebookAccount <- map["facebook_account"]

    }
    
    override init() {
        
    }

  
}
