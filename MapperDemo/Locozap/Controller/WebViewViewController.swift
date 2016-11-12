//
//  WebViewViewController.swift
//  Locozap
//
//  Created by paraline on 11/4/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class WebViewViewController: BaseViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var url : URL?;

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.delegate = self;
        
        if url != nil {
            self.webView.loadRequest(URLRequest(url: url!));
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
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("didFailLoadWithError")
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("shouldStartLoadWith \(request.url?.absoluteString)")
        return true;
    }
    
    @IBAction func pressBack(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }

}
