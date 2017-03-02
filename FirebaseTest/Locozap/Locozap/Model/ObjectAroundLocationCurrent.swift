/**
 * ObjectAroundLocationCurrent
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */


import UIKit
import ObjectMapper

class ObjectAroundLocationCurrent: Mappable {
    var arrayUser : [User]!;
    var arrayTopic : [Topic]!;
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        arrayUser    <- map["users"];
        arrayTopic    <- map["topics"];
    }
    
    init() {
        
    }
}
