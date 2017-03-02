/**
 * NavigationSettingLanguageViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */


import UIKit

protocol DelegateSettingLanguageViewController {
    func didCompleteSettingLanguage();
}

class NavigationSettingLanguageViewController: UINavigationController {

     var delegateSettingLanguage : DelegateSettingLanguageViewController?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
