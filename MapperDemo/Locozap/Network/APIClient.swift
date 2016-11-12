//
//  APIClient.swift
//  Uema
//
//  Created by paraline on 6/6/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let URL_BASE : String = Const.SERVER_URL + "/api/";

let URL_LOGIN : String = URL_BASE + "login";

let URL_TOPICS : String = URL_BASE + "topics";

let URL_REGISTER : String = URL_BASE + "add_user";

let URL_USER_AROUND : String = URL_BASE + "user_nearby";

let URL_UPLOAD_IMAGE : String = URL_BASE + "upload_image";

class APIClient {
    
    static let sharedInstance = APIClient()
   
    func postRequest(Url url : String, Parameters params : [String : AnyObject], ViewController viewController : UIViewController, ShowProgress isShowProgress : Bool, ShowAlert isShowAlert : Bool, Success success : @escaping (AnyObject) -> Void, Failure failure : @escaping (AnyObject?)->Void ) {
        
        print("[PARAM] \(JSON(params))");
        
        
        if isShowProgress {
            MBProgressHUD.showAdded(to: viewController.view, animated: true);
        }
        
        let headers = [
            "Accept": "application/json"
        ]
        
        //ParameterEncoding
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers : headers).responseJSON { (response : DataResponse<Any>) in
            DispatchQueue.main.async(execute: {
                MBProgressHUD.hide(for: viewController.view, animated: true);
            });

            switch response.result {
                case .success:
                    if let json = response.result.value {
                        print("[RESPONSE] \(json)");
                        let response = JSON(json);
                        let result = response["result"];
                        if (result == 0){
                            success(json as AnyObject)
                        }else{
                            let mes = response["message"].rawString()!;
                            failure(json as AnyObject?)
                            if (isShowAlert){
                                Utils.showAlertWithTitle("", message: mes, titleButtonClose: "", titleButtonOk: NSLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: nil);
                            }
                            
                        }
                    }
                    break;
            case .failure( _):
                failure(nil)
                if(isShowAlert){
                    Utils.showAlertWithTitle("", message: NSLocalizedString("message_error_network", comment: ""), titleButtonClose: "", titleButtonOk: NSLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: nil);
                }

                break;
            }
        }
        
    }
    
    func uploadImage(image : UIImage, name : String, Success success : @escaping (AnyObject) -> Void, Failure failure : @escaping (AnyObject?)->Void ) {
        let imageData = UIImagePNGRepresentation(image)
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData!, withName: "mypicture", fileName: name, mimeType: "image");
            },
            to: URL_UPLOAD_IMAGE,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        let jsonResponse = JSON(response.result.value);
                        let result = jsonResponse["result"].intValue;
                        if (result == 0){
                            success(response.result.value as AnyObject)
                        }else{
                            failure(response.result.value as AnyObject?)
                        }
                    }
                case .failure( _):
                    failure(nil)
                }
            }
        )
    }
	
	/*
	 * resquest api with object
	 */
	func postRequestObject(Url url : String, Parameters params : AnyObject, ViewController viewController : UIViewController, ShowProgress isShowProgress : Bool, ShowAlert isShowAlert : Bool, Success success : @escaping (AnyObject) -> Void, Failure failure : @escaping (AnyObject?)->Void) {
		
		let dict : Dictionary<String, String> = ObjectMapper.sharedInstance().dictionary(from: params as! NSObject) as! Dictionary<String, String>
		
		print("[PARAM] \(JSON(dict))");
		
		if isShowProgress {
			MBProgressHUD.showAdded(to: viewController.view, animated: true);
		}
		
		let headers = [
			"Accept": "application/json"
		]
		
		//ParameterEncoding
		Alamofire.request(url, method: .post, parameters: dict, encoding: JSONEncoding.default, headers : headers).responseJSON { (response : DataResponse<Any>) in
			DispatchQueue.main.async(execute: {
				MBProgressHUD.hide(for: viewController.view, animated: true);
			});
			
			switch response.result {
			case .success:
				if let json = response.result.value {
					
					print("[RESPONSE] \(json)");
					
					let baseRespone = ObjectMapper.sharedInstance().object(fromSource: json, toInstanceOf: BaseResponse.self) as? BaseResponse
					
					if (Int((baseRespone?.result)!) == 0){
						
						success(baseRespone?.data as AnyObject)
						
					}else{
						var mes : String? = baseRespone?.message;
						let errorCode : String? = baseRespone?.error_code;
						if (errorCode != nil){
							let apiError = APIError();
							if apiError.hasErrorCode(errorCode: errorCode!){
								mes = apiError.getMessage(errorCode: errorCode!);
							}
						}
						failure(json as AnyObject?)
						if (isShowAlert){
							Utils.showAlertWithTitle("", message: mes!, titleButtonClose: "", titleButtonOk: NSLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: nil);
						}
					}
				}
				break;
			case .failure( _):
				failure(nil)
				if(isShowAlert){
					Utils.showAlertWithTitle("", message: NSLocalizedString("message_error_network", comment: ""), titleButtonClose: "", titleButtonOk: NSLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: nil);
				}
				
				break;
			}
		}
		
	}

	
	
}
