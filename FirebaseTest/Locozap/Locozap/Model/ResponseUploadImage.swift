/**
 * ResponseUploadImage
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import ObjectMapper

class ResponseUploadImage: Mappable {

    var size: String?
    var fileName: String?
    var url: String?
    var urlSmall: String?
    var urlMedium: String?
    var thumbnail: String?
 
    
    required init?(map: Map) {
        
    }

    
    func mapping(map: Map) {
        size    <- map["size"]
        fileName    <- map["file_name"]
        url    <- map["url"]
        urlSmall    <- map["url_small"]
        urlMedium    <- map["url_medium"]
        thumbnail    <- map["thumbnail"]

    }
}
