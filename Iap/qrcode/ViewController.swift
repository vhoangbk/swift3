//
//  ViewController.swift
//  qrcode
//
//  Created by Hoang Nguyen on 1/6/17.
//  Copyright © 2017 Hoang Nguyen. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
	
	var listProduct = [SKProduct]();
	var product = SKProduct();

	override func viewDidLoad() {
		super.viewDidLoad()
		
		if (SKPaymentQueue.canMakePayments()) {
			let productId : NSSet = NSSet(objects: "com.paraline.qrcode.removeads");
			let request : SKProductsRequest = SKProductsRequest(productIdentifiers: productId as! Set<String>);
			request.delegate = self;
			request.start();
		}else{
			print("please enable IAP")
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	//MARK: SKProductsRequestDelegate
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		print("productsRequest");
		let myProduct = response.products;
		for product in myProduct {
			print(product.productIdentifier);
			print(product.localizedTitle);
			print(product.price);
			listProduct.append(product);
		}
	}
	
	//MARK: SKPaymentTransactionObserver
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		print("updatedTransactions")
		for transaction in transactions {
			let trans = transaction as SKPaymentTransaction;
			print(trans.error);
			switch trans.transactionState {
			case .purchased:
				print("buy ok")
				queue.finishTransaction(trans);
				break;
			case .failed:
				print("buy error")
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

		for transaction in queue.transactions {
			var t : SKPaymentTransaction = transaction as SKPaymentTransaction;
			let productId = t.payment.productIdentifier as String;
			
		}
		
	}
	
	func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
		print("restoreCompletedTransactionsFailedWithError");
	}

	@IBAction func pressRemoveAds(_ sender: AnyObject) {
		for product in listProduct {
			let productId = product.productIdentifier;
			if (productId == "com.paraline.qrcode.removeads" ) {
				self.product = product;
				buyProduct();
			}
		}
	}
	
	func buyProduct() {
		let pay = SKPayment(product: self.product);
		SKPaymentQueue.default().add(self);
		SKPaymentQueue.default().add(pay);
	}

}

