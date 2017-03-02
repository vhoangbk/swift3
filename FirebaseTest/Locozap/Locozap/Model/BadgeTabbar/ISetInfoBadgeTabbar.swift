/**
 * ISetInfoBadgeTabbar
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import Foundation

protocol ISetInfoBadgeTabbar {
    var type: TypeSetInfoBadgeTabbar { get };
    
    func setViewController(view: UIViewController);
    
    func getValue() -> Int;
    
    func getData() -> Any?;
}
