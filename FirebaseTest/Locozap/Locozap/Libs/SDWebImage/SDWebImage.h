/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Florent Vilmart
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#if SD_UIKIT
#import <UIKit/UIKit.h>
#endif

//! Project version number for WebImage.
FOUNDATION_EXPORT double WebImageVersionNumber;

//! Project version string for WebImage.
FOUNDATION_EXPORT const unsigned char WebImageVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <WebImage/PublicHeader.h>

#import "SDWebImageManager.h"
#import "SDImageCacheConfig.h"
#import "SDImageCache.h"
#import "UIView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+HighlightedWebCache.h"
#import "SDWebImageDownloaderOperation.h"
#import "UIButton+WebCache.h"
#import "SDWebImagePrefetcher.h"
#import "UIView+WebCacheOperation.h"
#import "UIImage+MultiFormat.h"
#import "SDWebImageOperation.h"
#import "SDWebImageDownloader.h"
#if SD_MAC || SD_UIKIT
#import "MKAnnotationView+WebCache.h"
#endif
#import "SDWebImageDecoder.h"
#import "UIImage+WebP.h"
#import "UIImage+GIF.h"
#import "NSData+ImageContentType.h"
#if SD_MAC
#import "NSImage+WebCache.h"
#endif
#if SD_UIKIT
//#import "FLAnimatedImageView+WebCache.h"
#endif
