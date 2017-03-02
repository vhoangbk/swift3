/**
 * UnReadTotal
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import ObjectMapper

class UnReadTotal: Mappable {
    var notification: Int = 0;
    var topic: Int = 0;
    var total: Int = 0;
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        notification    <- map["unread_notification"]
        topic    <- map["unread_topic"]
        total    <- map["unread_total"]
    }
}
