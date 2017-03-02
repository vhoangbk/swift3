/**
 * HistoryChat
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */


import UIKit
import ObjectMapper

class HistoryChat: Mappable {

    var length: Int?
    var messages: [MessageChat]?

    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        length    <- map["length"]
        messages    <- map["messages"]
        
    }
    
    init() {
        
    }
    
}
