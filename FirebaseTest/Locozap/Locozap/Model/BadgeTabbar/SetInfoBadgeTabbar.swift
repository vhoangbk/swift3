/**
 * SetInfoBadgeTabbar
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */


import Foundation

class SetInfoBadgeTabbar: ISetInfoBadgeTabbar {
    public var type: TypeSetInfoBadgeTabbar;
    private var value: Int;
    
    init(type: TypeSetInfoBadgeTabbar, value: Int) {
        self.type = type;
        self.value = value;
    }
    
    public func setViewController(view: UIViewController) {
        
    }
    
    public func getValue() -> Int {
        return value;
    }
    
    public func getData() -> Any? {
        return nil;
    }
}
