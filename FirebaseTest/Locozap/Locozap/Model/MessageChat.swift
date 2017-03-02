/**
 * MessageChat
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import ObjectMapper

class MessageChat: Mappable {

    var message: Message?
    var user: User?

    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        message    <- map["message"]
        user    <- map["user"]
 
    }
    
    init() {
        
    }
}
