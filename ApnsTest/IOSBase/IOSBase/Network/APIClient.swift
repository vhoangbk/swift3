/**
 * APIClient
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */


import Foundation
import Alamofire
import SwiftyJSON

let URL_BASE : String = Const.SERVER_URL + "/api/";

let URL_LOGIN : String = URL_BASE + "login";


class APIClient {
    
    static let sharedInstance = APIClient()
   
    /*
 
     var params : Dictionary = Dictionary<String, AnyObject>();
     params.updateValue("hoagnnv" as AnyObject, forKey: "email");
     params.updateValue("12345678" as AnyObject, forKey: "password");
     
     APIClient.sharedInstance.postRequest(Url: URL_LOGIN, Parameters: params, ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (sucess : AnyObject) in
     
     }) { (error : AnyObject?) in
     
     }
     
     */
    func postRequest(Url url : String, Parameters params : [String : AnyObject], ViewController viewController : UIViewController, ShowProgress isShowProgress : Bool, ShowAlert isShowAlert : Bool, Success success : @escaping (AnyObject) -> Void, Failure failure : @escaping (AnyObject?)->Void ) {
        
        NSLog("[URL] " + url);
        NSLog("[PARAM] \(JSON(params))");
        
        if (isShowAlert) {
            if ( !Utils.isInternetAvailable() ){
                DialogUtils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("message_error_network", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("ok", comment: ""), viewController: viewController, actionOK: nil);
                failure(nil)
                return;
            }
            
        }
        
        if isShowProgress {
            MBProgressHUD.showAdded(to: viewController.view, animated: true);
        }
        
        let headers = [
            "Accept": "application/json",
            "Content-Type" : "application/json"
        ]
    
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers : headers).responseJSON { (response : DataResponse<Any>) in
            DispatchQueue.main.async(execute: {
                MBProgressHUD.hide(for: viewController.view, animated: true);
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        let response = JSON(json);
                        NSLog("[RESPONSE] \(response)");
                        let result = response["result"];
                        if (result == 0){
                            success(json as AnyObject)
                        }else{
                            var mes : String? = response["message"].rawString()!;
                            let errorCode : String? = response["error_code"].rawString();
                            
                            if (errorCode != nil ){
                                let apiError = APIError();
                                if apiError.hasErrorCode(errorCode: errorCode!){
                                    mes = apiError.getMessage(errorCode: errorCode!);
                                }else{
                                    //error_code_common_with_error_code
                                    mes = String(format: StringUtilities.getLocalizedString("error_code_common_with_error_code", comment: ""), errorCode!);
                                }
                            }else{
                                mes = StringUtilities.getLocalizedString("error_code_common", comment: "");
                            }
                            
                            failure(json as AnyObject?)
                            if (isShowAlert){
                                DialogUtils.showAlertWithTitle("", message: mes!, titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("ok", comment: ""), viewController: viewController, actionOK: nil);                            }
                            
                        }
                    }
                    break;
                case .failure(let error):
                    NSLog("[RESPONSE ERROR] \(error)");
                    if (isShowProgress){
                        MBProgressHUD.hide(for: viewController.view, animated: true);
                    }
                    failure(nil)
                    if(isShowAlert){
                        DialogUtils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("error_code_common", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("ok", comment: ""), viewController: viewController, actionOK: nil);
                    }
                    
                    break;
                }
                
            });
        }
    }
    
    func getRequest(Url url : String, ViewController viewController : UIViewController, ShowProgress isShowProgress : Bool, ShowAlert isShowAlert : Bool, Success success : @escaping (AnyObject) -> Void, Failure failure : @escaping (AnyObject?)->Void ) {
        
        NSLog("[URL] Get: " + url);
        
        if (isShowAlert) {
            if ( !Utils.isInternetAvailable() ){
                DialogUtils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("message_error_network", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("ok", comment: ""), viewController: viewController, actionOK: nil);
                failure(nil)
                return;
            }
            
        }
        
        if isShowProgress {
            MBProgressHUD.showAdded(to: viewController.view, animated: true);
        }
        
        Alamofire.request(url, method: .get).responseJSON { (response : DataResponse<Any>) in
            DispatchQueue.main.async(execute: {
                MBProgressHUD.hide(for: viewController.view, animated: true);
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        NSLog("[RESPONSE] \(json)");
                        
                    }
                    break;
                case .failure(let error):
                    NSLog("[RESPONSE] error \(error)");
                    
                    break;
                }
                
            });
        }
        
    }
    
    
}
