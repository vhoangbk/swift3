/**
 * PinAnnotation
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import Foundation
import MapKit

class PinAnnotation: NSObject, MKAnnotation {
    private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0);
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
}
