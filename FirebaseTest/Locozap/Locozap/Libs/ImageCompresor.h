/*
 * ImageCompresor.h
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageCompresor : NSObject

@property UIImage *image;
@property NSData *data;

-(void)shrinkImage : (float) maxVal;

@end
