//
//  AdBrix.h
//  AdBrixLib
//
//  Created by wonje,song on 2015. 5. 21..
//  Copyright (c) 2015년 wonje,song. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "AdBrixItem.h"
#import "AdBrixCommerceProductModel.h"
#import "AdBrixCommerceProductCategoryModel.h"
#import "AdBrixCommerceProductAttrModel.h"


typedef NS_ENUM(NSInteger, AdBrixCustomCohortType)
{
    AdBrixCustomCohort_1 = 1,
    AdBrixCustomCohort_2 = 2,
    AdBrixCustomCohort_3 = 3
};

typedef NS_ENUM(NSInteger, AdBrixCurrencyType)
{
    AdBrixCurrencyKRW = 1,
    AdBrixCurrencyUSD = 2,
    AdBrixCurrencyJPY = 3,
    AdBrixCurrencyEUR = 4,
    AdBrixCurrencyGBP = 5,
    AdBrixCurrencyCHY = 6,
    AdBrixCurrencyTWD = 7,
    AdBrixCurrencyHKD = 8
};

typedef NS_ENUM(NSInteger, AdbrixPaymentMethod)
{
    AdBrixPaymentCreditCard = 1,
    AdBrixPaymentBankTransfer,
    AdBrixPaymentMobilePayment,
    AdBrixPaymentETC
};

typedef NS_ENUM(NSInteger, AdBrixSharingChannel)
{
    AdBrixSharingFacebook,
    AdBrixSharingKakaoTalk,
    AdBrixSharingKakaoStory,
    AdBrixSharingLine,
    AdBrixSharingWhatsApp,
    AdBrixSharingQQ,
    AdBrixSharingWeChat,
    AdBrixSharingSMS,
    AdBrixSharingEmail,
    AdBrixSharingCopyUrl,
    AdBrixSharingETC
};




@interface AdBrix : NSObject

/*!
 @abstract
 singleton AdBrix 객체를 반환한다.
 */
+ (AdBrix *)shared;

/*!
 @abstract
 first time experience의 Activity에 해당할때 호출한다.
 
 @param activityName              activity name.
 */
+ (void)firstTimeExperience:(NSString *)activityName;


/*!
 @abstract
 first time experience의 Activity에 해당할때 호출한다.
 
 @param activityName              activity name.
 @param param                     parameter.
 */
+ (void)firstTimeExperience:(NSString *)activityName param:(NSString *)param;

/*!
 @abstract
 retension의 Activity에 해당할때 호출한다.
 
 @param activityName              activity name.
 */
+ (void)retention:(NSString *)activityName;

/*!
 @abstract
 retension의 Activity에 해당할때 호출한다.
 
 @param activityName              activity name.
 @param param                     parameter.
 */
+ (void)retention:(NSString *)activityName param:(NSString *)param;

/*!
 @abstract
 buy의 Activity에 해당할때 호출한다.
 
 @param activityName              activity name.
 */
+ (void)buy:(NSString *)activityName  __attribute__((deprecated("use -purchase: instead")));

/*!
 @abstract
 buy의 Activity에 해당할때 호출한다.
 
 @param activityName              activity name.
 @param param                     parameter.
 */
+ (void)buy:(NSString *)activityName param:(NSString *)param  __attribute__((deprecated("use -purchase: instead")));


+ (void)showViralCPINotice:(UIViewController *)viewController;

/*!
 @abstract
 cohort 분석시 호출한다.
 
 @param customCohortType          cohort type : AdBrixCustomCohortType
 @param filterName                filter Name
 */
+ (void)setCustomCohort:(AdBrixCustomCohortType)customCohortType filterName:(NSString *)filterName;


#pragma mark - Commerce

+ (void)purchase:(NSString*)orderId productId:(NSString*)productId productName:(NSString*)productName price:(double)price quantity:(NSUInteger)quantity currencyString:(NSString *)currencyString category:(NSString*)categories __attribute__((deprecated("use -commercePurchase: instead")));

+ (void)purchaseList:(NSArray*)orderInfo __attribute__((deprecated("use -commercePurchase: instead")));

+ (void)purchase:(NSString*)purchaseDataJsonString __attribute__((deprecated("use -commercePurchase api: instead")));

+ (NSString *)currencyName:(NSUInteger)currency;

+ (NSString *)paymentMethod:(NSUInteger)method;

+ (NSString *)sharingChannel:(NSUInteger)channel;

+ (AdBrixItem*)createItemModel :(NSString*)orderId productId:(NSString*)productId productName:(NSString*)productName price:(double)price quantity:(NSUInteger)quantity currencyString:(NSString *)currencyString category:(NSString*)categories __attribute__((deprecated("use -createCommerceProductModel with commercePurchase api: instead")));
    
+ (AdBrixItem*)PurchaseItemModel :(NSString*)orderId productId:(NSString*)productId productName:(NSString*)productName price:(double)price quantity:(NSUInteger)quantity currencyString:(NSString *)currencyString category:(NSString*)categories __attribute__((deprecated("use -createCommerceProductModel with commercePurchase api: instead")));

#pragma mark - CommerceV2

+ (AdBrixCommerceProductModel*)createCommerceProductModel :(NSString*)productId productName:(NSString*)productName price:(double)price discount:(double)discount quantity:(NSUInteger)quantity currencyString:(NSString *)currencyString category:(AdBrixCommerceProductCategoryModel*)categories extraAttrsMap:(AdBrixCommerceProductAttrModel *)extraAttrs;

+ (void)purchase:(NSString *)prodictId price:(double)price currency:(NSString*)currency paymentMethod:(NSString *)paymentMethod;

+ (void)purchase:(NSString *)orderId product:(AdBrixCommerceProductModel *)product paymentMethod:(NSString *)paymentMethod;

+ (void)purchase:(NSString *)orderId productsInfos:(NSArray *)productsInfos paymentMethod:(NSString *)paymentMethod;

+ (void)commercePurchase:(NSString *)prodictId price:(double)price currency:(NSString*)currency paymentMethod:(NSString *)paymentMethod;

+ (void)commercePurchase:(NSString *)orderId product:(AdBrixCommerceProductModel *)product discount:(double)discount deliveryCharge:(double)deliveryCharge paymentMethod:(NSString *)paymentMethod;

+ (void)commercePurchase:(NSString *)orderId productsInfos:(NSArray *)productsInfos discount:(double)discount deliveryCharge:(double)deliveryCharge paymentMethod:(NSString *)paymentMethod;

+ (void)commerceDeeplinkOpen : (NSString *)deeplinkUrl;

+ (void)commerceLogin : (NSString *)userId;

+ (void)commerceRefund:(NSString *)orderId product:(AdBrixCommerceProductModel *)product penaltyCharge:(double)penaltyCharge;

+ (void)commerceRefundBulk:(NSString *)orderId productsInfos:(NSArray *)productsInfos penaltyCharge:(double)penaltyCharge;

+ (void)commerceAddToCart:(AdBrixCommerceProductModel *)product;

+ (void)commerceAddToCartBulk:(NSArray *)productsInfos;

+ (void)commerceAddToWishList:(AdBrixCommerceProductModel *)product;

+ (void)commerceProductView:(AdBrixCommerceProductModel*)product;

+ (void)commerceCategoryView:(AdBrixCommerceProductCategoryModel*)category;

+ (void)commerceReviewOrder:(NSString *)orderId product:(AdBrixCommerceProductModel *)product discount:(double)discount deliveryCharge:(double)deliveryCharge;

+ (void)commerceReviewOrderBulk:(NSString *)orderId productsInfos:(NSArray *)productsInfos discount:(double)discount deliveryCharge:(double)deliveryCharge;

+ (void)commercePaymentView:(NSString *)orderId productsInfos:(NSArray *)productsInfos discount:(double)discount deliveryCharge:(double)deliveryCharge;

+ (void)commerceSearch:(NSArray *)productsInfos keyword:(NSString *) keyword;

+ (void)commerceShare:(NSString*)channel product:(AdBrixCommerceProductModel *)product;
@end
