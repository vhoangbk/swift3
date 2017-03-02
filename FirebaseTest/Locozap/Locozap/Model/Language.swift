/**
 * Language
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import ObjectMapper

class Language: NSObject, Mappable {
    
    var codeLanguage: String?
    var level: Int?
    var nameLanguage : String?
    var descriptionLanguage : String?
    
    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        codeLanguage    <- map["country"]
        level         <- map["level"]
        nameLanguage    <- map["name_language"]
        descriptionLanguage    <- map["description_language"]
    }

    init(codeLanguage : String, nameLanguage : String, descriptionLanguage : String) {
        self.codeLanguage = codeLanguage;
        self.nameLanguage = nameLanguage;
        self.descriptionLanguage = descriptionLanguage;
    }
    
    init(codeLanguage : String, nameLanguage : String, descriptionLanguage : String, level : Int) {
        self.codeLanguage = codeLanguage;
        self.nameLanguage = nameLanguage;
        self.descriptionLanguage = descriptionLanguage;
        self.level = level;
    }
}
