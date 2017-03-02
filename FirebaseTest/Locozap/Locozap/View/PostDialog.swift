/**
 * PostDialogDelegate
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit

/**
 *  Delegate onclick menu
 */
protocol PostDialogDelegate {
    func didPressMenuFood();
    func didPressMenuPlay();
    func didPressMenuDrink();
    func didPressMenuHelp();
    func didDismiss();
}


class PostDialog: UIView {
    @IBOutlet weak var lbMenuFood: UILabel!
    @IBOutlet weak var lbMenuDrink: UILabel!
    @IBOutlet weak var lbMenuPlay: UILabel!
    @IBOutlet weak var lbMenuHelp: UILabel!
    var delegate : PostDialogDelegate?;
    
    
    @IBOutlet weak var viewFood: UIView!
    @IBOutlet weak var viewDrink: UIView!
    @IBOutlet weak var viewPlay: UIView!
    @IBOutlet weak var viewHelp: UIView!
    
    class func sharedInstance() -> PostDialog{
        let postDialog = Bundle.main.loadNibNamed("PostDialog", owner: self, options: nil)?.last as! PostDialog;
        postDialog.initView();
        return postDialog;
    }
    

    func dismiss(){
        self.removeFromSuperview();
        if delegate != nil {
            delegate?.didDismiss();
        }
    }
    
    func show(tabBarController: UITabBarController){
        self.frame = UIScreen.main.bounds
        tabBarController.view.addSubview(self);
        self.translateFromBottom(view: viewFood);
        self.translateFromBottom(view: viewDrink);
        self.translateFromBottom(view: viewPlay);
        self.translateFromBottom(view: viewHelp);
    }
    
    // MARK: Init view
   private func initView() {
        self.lbMenuFood.text = StringUtilities.getLocalizedString("post_food", comment: "");
        self.lbMenuDrink.text = StringUtilities.getLocalizedString("post_drink", comment: "");
        self.lbMenuHelp.text = StringUtilities.getLocalizedString("post_help", comment: "");
        self.lbMenuPlay.text = StringUtilities.getLocalizedString("post_play", comment: "");
    }

    @IBAction func pressClosePost(_ sender: AnyObject) {
        dismiss();
    }
    
    @IBAction func pressMenuFood(_ sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.didPressMenuFood();
        }
        dismiss();
    }
    
    @IBAction func pressMenuDrik(_ sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.didPressMenuDrink();
        }
        dismiss();
    }
    
    @IBAction func pressMenuPlay(_ sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.didPressMenuPlay();
        }
        dismiss();
    }
   
    @IBAction func pressMenuHelp(_ sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.didPressMenuHelp()
        }
        dismiss();
    }
    
    func translateFromBottom(view: UIView) {
        let animation = CATransition();
        animation.duration = 0.3;
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromTop;
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
        view.layer.add(animation, forKey: "TransitionToActionSheet");
    }
}
