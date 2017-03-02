/**
 * WebViewViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit

class WebViewViewController: BaseViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    public var url : URL?;
    public var textBack: String?;
    public var textTitle: String?;

    @IBOutlet weak var btnBackWeb: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    @IBOutlet weak var contraintHeightBottomBar: NSLayoutConstraint!

    var isShowNaviWeb : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.delegate = self;
        
        self.webView.scalesPageToFit = true;
        self.webView.scrollView.bounces = false;
        MBProgressHUD.showAdded(to: self.view, animated: true);
        if url != nil {
            self.webView.loadRequest(URLRequest(url: url!));
        }
        
        if (!isShowNaviWeb) {
            contraintHeightBottomBar.constant = 0;
        }
        
        self.btnBackWeb.setImage(UIImage.init(named: "back_yellow"), for: UIControlState.normal)
        self.btnBackWeb.setImage(UIImage.init(named: "back_gray"), for: UIControlState.disabled)
        self.btnForward.setImage(UIImage.init(named: "forward_yellow"), for: UIControlState.normal)
        self.btnForward.setImage(UIImage.init(named: "forward_gray"), for: UIControlState.disabled)
        
        updateStatusButton();
    }
    
    func updateStatusButton()  {
        btnBackWeb.isEnabled = self.webView.canGoBack;
        btnForward.isEnabled = self.webView.canGoForward;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.textBack != nil && !(self.textBack?.isEmpty)!) {
            self.btnBack.setTitle(self.textBack, for: .normal);
        } else {
            self.btnBack.setTitle("", for: .normal);
        }
        
        if (self.textTitle != nil && !(self.textTitle?.isEmpty)!) {
            self.lblTitle.text = self.textTitle;
        } else {
            self.lblTitle.text = "";
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func webViewDidStartLoad(_ webView: UIWebView) {
        print("webViewDidStartLoad")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webViewDidFinishLoad")
        MBProgressHUD.hide(for: self.view, animated: true);
        updateStatusButton();
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("didFailLoadWithError")
        MBProgressHUD.hide(for: self.view, animated: true);
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("shouldStartLoadWith \(request.url?.absoluteString)")
        return true;
    }
    
    @IBAction func pressBack(_ sender: AnyObject) {
        if (self.navigationController != nil){
            self.navigationController!.popViewController(animated: true);
        }else{
            self.dismiss(animated: true, completion: nil);
        }
    }

    @IBAction func pressBackWeb(_ sender: Any) {
        self.webView.goBack();
    }
    
    @IBAction func pressForwardWeb(_ sender: Any) {
        self.webView.goForward();
    }
}
