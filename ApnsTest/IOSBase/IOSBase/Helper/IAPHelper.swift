//
//  IAPHelper.swift
//  IOSBase
//
//  Created by paraline on 2/24/17.
//  Copyright © 2017 paraline. All rights reserved.
//

import UIKit
import StoreKit

class IAPHelper: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var listProduct = [SKProduct]();
    
    static let BUNDLE_ID_REMOVE_ADS = "jp.co.locobee.app.hideadds";
    
    func getListProduct() {
        if (SKPaymentQueue.canMakePayments()) {
            let productId : NSSet = NSSet(objects: IAPHelper.BUNDLE_ID_REMOVE_ADS);
            let request : SKProductsRequest = SKProductsRequest(productIdentifiers: productId as! Set<String>);
            request.delegate = self;
            request.start();
            
            SKPaymentQueue.default().add(self);
        }
    }
    
    /*
     *
     */
    func removeListenner() {
        SKPaymentQueue.default().remove(self)
    }
    
    /*
     * restore
     */
    func restoreProduct() {
        SKPaymentQueue.default().add(self);
        SKPaymentQueue.default().restoreCompletedTransactions();
    }
    
    /*
     * restore product
     */
    func buyProduct() {
        for product in listProduct {
            let productId = product.productIdentifier;
            if (productId == IAPHelper.BUNDLE_ID_REMOVE_ADS ) {
                let pay = SKPayment(product: product);
                SKPaymentQueue.default().add(self);
                SKPaymentQueue.default().add(pay);
            }
        }
        
        
    }
    
    //MARK: - SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("productsRequest");
        let myProduct = response.products;
        for product in myProduct {
            listProduct.append(product);
        }
        
    }

    //MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("updatedTransactions")
        for transaction in transactions {
            let trans = transaction as SKPaymentTransaction;
            switch trans.transactionState {
            case .purchased:
                print("buy ok")
                queue.finishTransaction(trans);
                break;
            case .failed:
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
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("paymentQueueRestoreCompletedTransactionsFinished")
    }

}




