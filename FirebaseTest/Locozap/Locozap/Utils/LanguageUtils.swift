/**
 * LanguageUtils
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit

class LanguageUtils: NSObject {
        class func getLocaleList() -> [NSLocale]{
        
        var result = [NSLocale]();
        
        for i in 0..<Const.arrayCountries.count {
            result.append(NSLocale.init(localeIdentifier: Const.arrayLanguages[i]+"_"+Const.arrayCountries[i]));
        }
        
        return result;
    }
    
    class func getLocaleFromLanguageCodeCountryCode(languageCode : String, countryCode : String) -> NSLocale{
        return NSLocale.init(localeIdentifier: languageCode+"_"+countryCode);
    }
    
    class func getCurrentLocale() -> NSLocale{
        let identity = NSLocale.preferredLanguages.first
        let currentLocale = NSLocale.init(localeIdentifier: identity!);
        return currentLocale;
    }
    
    class func getCountryCode(LanguageCode : String) -> String{
        let listLocale = getLocaleList();
        for locale in listLocale{
            let lang = locale.object(forKey: NSLocale.Key.languageCode) as? String;
            if (lang == LanguageCode){
                return (locale.object(forKey: NSLocale.Key.countryCode) as? String)!;
            }
        }
        return "US";
    }

    
    class func getLanguageCode(countryCode : String) -> String{
        let listLocale = getLocaleList();
        for locale in listLocale{
            let contry = locale.object(forKey: NSLocale.Key.countryCode) as? String;
            if (contry == countryCode){
                return (locale.object(forKey: NSLocale.Key.languageCode) as? String)!;
            }
        }
        return "en";
    }
    
    class func getLanguageNameFromLanguageCode(languageCode : String) -> String{
        let currentLocale = getCurrentLocale();
        let languageName = currentLocale.displayName(forKey: NSLocale.Key.languageCode, value: languageCode);
        return languageName!;
    }
    
    class func getListLanguageNameFromListLanguageCodeCurrentLocale(arrayLanguageCode : [Language]) -> Array<Language>{
        var arrayResult = Array<Language>();
        for language in arrayLanguageCode {
            language.nameLanguage = getLanguageNameFromLanguageCodeLocale(languageCode: language.codeLanguage!);
            language.descriptionLanguage = getLanguageNameFromLanguageCode(languageCode: language.codeLanguage!);
            arrayResult.append(language);
        }
        return arrayResult;
    }
    
    class func getLanguageNameFromLanguageCodeLocale(languageCode : String) -> String{
        let locale = NSLocale.init(localeIdentifier: languageCode+"_"+getCountryCode(LanguageCode: languageCode));
        let languageName = locale.displayName(forKey: NSLocale.Key.languageCode, value: languageCode);
        return languageName!;
    }
    
    class func getCountryNameFromCountryCode(countryCode : String) -> String{
        let currentLocale = getCurrentLocale();
        let countryName = currentLocale.displayName(forKey: NSLocale.Key.countryCode, value: countryCode);
        if countryName == nil {
            return "";
        }
        return countryName!;
    }
    
    class func getListLanguageNameFromListLanguageCode(arrayLanguageCode : [Language]) -> Array<Language>{
        var arrayResult = Array<Language>();
        for objLanguageCode in arrayLanguageCode {
            let countryCode = LanguageUtils.getCountryCode(LanguageCode: objLanguageCode.codeLanguage!);
            let locale = LanguageUtils.getLocaleFromLanguageCodeCountryCode(languageCode: objLanguageCode.codeLanguage!, countryCode: countryCode);
            let nameLanguage = locale.displayName(forKey: NSLocale.Key.languageCode, value: objLanguageCode.codeLanguage!);
            objLanguageCode.nameLanguage = nameLanguage;
            objLanguageCode.descriptionLanguage = getLanguageNameFromLanguageCode(languageCode: objLanguageCode.codeLanguage!);
            arrayResult.append(objLanguageCode);
        }
        return arrayResult;
    }
    
    class func getListLanguageNameNotExistListLanguageCode(arrayLanguageCode : [Language]) -> Array<Language>{
        var arrayResult = Array<Language>();
        for objectLanguage in getAllLanguage() {
            if(!checkLanguageExist(languageCode: objectLanguage.codeLanguage!, arrayCheck: arrayLanguageCode)) {
                arrayResult.append(objectLanguage);
            }
        }
        return arrayResult;
    }
    
    class func getAllLanguage() -> Array<Language> {
        var arrayResult = Array<Language>();
        let currentLocale = getCurrentLocale();
        for i in 0..<Const.arrayCountries.count {
            let descriptionLanguage = currentLocale.displayName(forKey: NSLocale.Key.languageCode, value: getLanguageCode(countryCode: Const.arrayCountries[i]));
            let nameLanguage = getLanguageNameFromLanguageCodeLocale(languageCode: getLanguageCode(countryCode: Const.arrayCountries[i]));
            let language = Language.init(codeLanguage: Const.arrayLanguages[i], nameLanguage: nameLanguage, descriptionLanguage: descriptionLanguage!);
            if (!checkLanguageExist(languageCode: Const.arrayLanguages[i], arrayCheck: arrayResult)) {
                arrayResult.append(language);
            }
        }
        return arrayResult;
    }
    
    class func checkLanguageExist(languageCode : String, arrayCheck : Array<Language>) -> Bool{
        for language in arrayCheck {
            if (language.codeLanguage == languageCode) {
                return true;
            }
        }
        return false;
    }
    
    class func getCountryCodeByContryNameFB(countryName : String) -> String{
        var result : String = "";
        for i in 0..<Const.arrayCountryNameFb.count {
            if (Const.arrayCountryNameFb[i] == countryName){
                result = Const.arrayCountries[i];
                break;
            }
        }
        return result;
    }    
}
