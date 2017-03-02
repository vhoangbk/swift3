/**
 * PremiumViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import StoreKit
import SwiftyJSON

class PremiumViewController: BaseViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var lbHideAds: UILabel!
    @IBOutlet weak var lbPurchasing: UILabel!
    @IBOutlet weak var btnPurchasePrice: UIButton!
    
    @IBOutlet weak var btnRestore: UIButton!
    
    var listProduct = [SKProduct]();
    
    var productRemoveAds = SKProduct();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        iniView();
        
        _ = self.showViewPremium(isShow: nil);
        
        if (SKPaymentQueue.canMakePayments()) {
            MBProgressHUD.showAdded(to: self.view, animated: true);
            let productId : NSSet = NSSet(objects: Const.BUNDLE_ID_REMOVE_ADS);
            let request : SKProductsRequest = SKProductsRequest(productIdentifiers: productId as! Set<String>);
            request.delegate = self;
            request.start();
            
            SKPaymentQueue.default().add(self);
        }
        
        AdBrix.retention("OpenInAppActivity")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SKPaymentQueue.default().remove(self)
    }
    
    func iniView() {
        btnBack.setTitle(StringUtilities.getLocalizedString("header_activity_setting", comment: ""), for: UIControlState.normal);
        lbTitle.text = StringUtilities.getLocalizedString("premium_service", comment: "");
        
        lbHideAds.text = StringUtilities.getLocalizedString("hide_ads", comment: "");
        lbPurchasing.text = StringUtilities.getLocalizedString("by_purchasing_it", comment: "");
        btnPurchasePrice.setTitle(StringUtilities.getLocalizedString("purchase_price", comment: ""), for: UIControlState.normal);
        
        self.btnPurchasePrice.isEnabled = false;
        self.btnPurchasePrice.layer.cornerRadius = 5.0;
        
        btnRestore.setTitle(StringUtilities.getLocalizedString("restore_purchase", comment: ""), for: UIControlState.normal);
        btnRestore.layer.cornerRadius = 5.0;
    }
    
    private func showViewPremium(isShow: Bool?) -> Bool {
        var isPremium: Bool = isShow != nil ? !isShow! : false;
        let isPremiumNotLogin = Utils.getPremium();
        
        if (isShow == nil && self.mUser != nil && self.mUser?.premiumAccount != nil) {
            isPremium = (self.mUser?.premiumAccount)!;
        }
        
        if (isPremium == false && isPremiumNotLogin == false){
            
        }else if(isPremium == true && isPremiumNotLogin == false){
            updateUIBuyRestoreSucess()
        }else {
            updateUIBuyRestoreSucess()
        }
        
        return isPremium;
    }
    
    func updateUIBuyRestoreSucess() {
        btnPurchasePrice.isHidden = true;
        lbHideAds.isHidden = true;
        lbPurchasing.text = StringUtilities.getLocalizedString("by_purchasing_it_success", comment: "");
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationController?.setNavigationBarHidden(true, animated: true);
    }
    
    @IBAction func pressBack(_ sender: Any) {
        self.navigationController!.popViewController(animated: true);
    }
    
    @IBAction func pressPurchase(_ sender: Any) {
        for product in listProduct {
            let productId = product.productIdentifier;
            if (productId == Const.BUNDLE_ID_REMOVE_ADS ) {
                self.productRemoveAds = product;
                NetworkActivityIndicatorManager.NetworkOperationStarted();
                btnPurchasePrice.isEnabled = false;
                buyProduct();
            }
        }
    }
    
    //MARK: SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("productsRequest");
        let myProduct = response.products;
        for product in myProduct {
            listProduct.append(product);
        }
        
        updateUI();
        
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    //MARK: SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("updatedTransactions")
        MBProgressHUD.hide(for: self.view, animated: true);
        for transaction in transactions {
            let trans = transaction as SKPaymentTransaction;
            switch trans.transactionState {
            case .purchased:
                NetworkActivityIndicatorManager.networkOperationFinished();
                print("buy ok")
                queue.finishTransaction(trans);
                    
                if (mUser != nil){
                    Utils.setUserPremium(userId: (self.mUser?.id)!, isPremium: true);
                    callApiActivePremiumWhenSuccess(activeSuccess: setUserWhenSuccess, activeError: {
                            
                    });
                }else{
                    Utils.setPremium(isPremium: true)
                }
                    
                self.updateUIBuyRestoreSucess();
                
                NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_RELOADS_TOP_WHEN_ACTIVE_ACCOUNT_PREMIUM, object: nil);
                    
                AdBrix.purchase("oid_1", productId: trans.payment.productIdentifier, productName: productRemoveAds.localizedTitle, price: 360, quantity: 1, currencyString: AdBrix.currencyName(UInt(AdBrixCurrencyType.JPY.rawValue)), category: "Hidden_Ads")
                AdBrix.retention("inAppPurchasePaymentSucess")
                AdBrix.buy("purchase_360_yen")
                break;
            case .failed:
                btnPurchasePrice.isEnabled = true;
                NetworkActivityIndicatorManager.networkOperationFinished();
                queue.finishTransaction(trans);
                break;
            case .restored:
                queue.finishTransaction(trans);
                break;
            default:
                break;
            }
            
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("removedTransactions");
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("paymentQueueRestoreCompletedTransactionsFinished")
        MBProgressHUD.hide(for: self.view, animated: true);
        //        for transaction in queue.transactions{
        //            let t : SKPaymentTransaction = transaction as SKPaymentTransaction;
        //            let prodId = t.payment.productIdentifier as String;
        //
        //            if (Const.BUNDLE_ID_REMOVE_ADS == prodId){
        //
        //                if (mUser != nil){
        //                    Utils.setUserPremium(userId: (self.mUser?.id)!, isPremium: true);
        //
        //                    if (!(mUser?.premiumAccount)!){
        //                        callApiActivePremiumWhenSuccess(activeSuccess: setUserWhenSuccess, activeError: {
        //
        //                        });
        //                    }
        //
        //                }else{
        //                    Utils.setPremium(isPremium: true)
        //                }
        //
        //                self.restoreSuccess();
        //
        //            }
        //        }
        
        if (mUser != nil){
            Utils.setUserPremium(userId: (self.mUser?.id)!, isPremium: true);
            
            if (!(mUser?.premiumAccount)!){
                callApiActivePremiumWhenSuccess(activeSuccess: setUserWhenSuccess, activeError: {
                
                });
            }
            
        }else{
            Utils.setPremium(isPremium: true)
        }
        
        self.updateUIBuyRestoreSucess();
        
        NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_RELOADS_TOP_WHEN_ACTIVE_ACCOUNT_PREMIUM, object: nil);
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        MBProgressHUD.hide(for: self.view, animated: true);
    }
    
    func buyProduct() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let pay = SKPayment(product: self.productRemoveAds);
        SKPaymentQueue.default().add(pay);
    }
    
    func updateUI() {
        for product in listProduct {
            let productId = product.productIdentifier;
            if (productId == Const.BUNDLE_ID_REMOVE_ADS ) {
                self.btnPurchasePrice.isEnabled = true;
            }
        }
    }
    
    private func setUserWhenSuccess(response: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        appDelegate.mUser?.premiumAccount = true;
        
        Utils.setInfoAccount(infoAccount: NSKeyedArchiver.archivedData(withRootObject: response) as AnyObject?);
    }
    
    private func callApiActivePremiumWhenSuccess(activeSuccess : @escaping (_ response: Any) -> Void, activeError : @escaping () -> Void) {
        var params : Dictionary = Dictionary<String, String>();
        if (mUser == nil) {
            return;
        }
        params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        
        APIClient.sharedInstance.postRequest(Url: URL_ACTIVE_PREMIUM, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: false, Success: { (success : AnyObject) in
            let responseJson = JSON(success)["data"];
            Utils.setInfoAccount(infoAccount: NSKeyedArchiver.archivedData(withRootObject: responseJson.rawValue) as AnyObject?);
            
            activeSuccess(responseJson.rawValue);
        }) { (error : AnyObject?) in
            activeError();
        }
    }
    
    @IBAction func pressRestore(_ sender: Any) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        SKPaymentQueue.default().restoreCompletedTransactions();
    }
    
}

class NetworkActivityIndicatorManager : NSObject {
    
    private static var loadingCount = 0
    
    class func NetworkOperationStarted() {
        if loadingCount == 0 {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingCount += 1
    }
    class func networkOperationFinished(){
        if loadingCount > 0 {
            loadingCount -= 1
            
        }
        
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
}
