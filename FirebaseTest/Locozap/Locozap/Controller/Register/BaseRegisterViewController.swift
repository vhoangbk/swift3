/**
 * BaseRegisterViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit

class BaseRegisterViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    override func initNavigationBar() {
        super.initNavigationBar();
        
        let nextBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30));
        nextBtn.setTitle(getRightTitle(), for: UIControlState.normal);
        nextBtn.setBackgroundImage(getRightImage(), for: UIControlState.normal);
        nextBtn.addTarget(self, action: #selector(BaseRegisterViewController.didPressNext), for: UIControlEvents.touchUpInside);
        let next = UIBarButtonItem(customView: nextBtn);
        self.navigationItem.rightBarButtonItem = next;
 
    }
    
    func getRightTitle() -> String {
        return StringUtilities.getLocalizedString("next", comment: "");
    }
    
    func getRightImage() -> UIImage {
        return UIImage.init(named: "button_bg_corner")!;
    }

    func didPressNext() {

    }
    
}
