/**
 * Address
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import ObjectMapper

class Address: Mappable {

    var ja: String?
    var en: String?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        ja    <- map["ja"]
        en    <- map["en"]
        
        
    }
 
    init(ja: String, en: String){
        self.ja = ja;
        self.en = en;
    }
}
