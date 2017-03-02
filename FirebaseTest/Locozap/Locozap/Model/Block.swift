/**
 * Block
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import ObjectMapper

class Block: Mappable {

    var joinTopic: Bool?
    var doBlock: Bool?
    var success: Bool?
   
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        joinTopic    <- map["join_topic"]
        doBlock    <- map["do_block"]
        success    <- map["success"]
        
        
    }
    
}
