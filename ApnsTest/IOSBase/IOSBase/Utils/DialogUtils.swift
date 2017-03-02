//
//  DialogUtils.swift
//  IOSBase
//
//  Created by paraline on 2/22/17.
//  Copyright © 2017 paraline. All rights reserved.
//

import UIKit

class DialogUtils: NSObject {

    @available(iOS 8.0, *)
    class func showAlertWithTitle(_ title: String!, message: String, titleButtonClose : String, titleButtonOk : String, viewController: UIViewController, actionOK: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: titleButtonOk, style: .default, handler: actionOK);
        alert.addAction(action)
        if(!titleButtonClose.isEmpty){
            let actionCancel = UIAlertAction(title: titleButtonClose, style: .cancel, handler: nil);
            alert.addAction(actionCancel);
        }
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
