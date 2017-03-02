/*
 * ImageCompresor.m
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

#import "ImageCompresor.h"

@implementation ImageCompresor

-(void)shrinkImage : (float) maxVal{
    
    
    //IMPORTANT!!! THIS CODE WAS CREATED WITH "ARC" IN MIND... DO NOT USE WITHOUT ARC UNLESS YOU ALTER THIS CODE TO MANAGE MEMORY
    
    
    float compressionVal = 1.0;
   // float maxVal = 5.0;//MB
    
    UIImage *compressedImage = self.image; //get UIImage from imageView
    
    int iterations = 0;
    int totalIterations = 0;
    
    float initialCompressionVal = 0.00000000f;
    
    while (((((float)(UIImageJPEGRepresentation(compressedImage, compressionVal).length))/(1048576.000000000f)) > maxVal) && (totalIterations < 1024)) {
        
        NSLog(@"Image is %f MB", (float)(((float)(UIImageJPEGRepresentation(compressedImage, compressionVal)).length)/(1048576.000000f)));//converts bytes to MB
        
        compressionVal = (((compressionVal)+((compressionVal)*((float)(((float)maxVal)/((float)(((float)(UIImageJPEGRepresentation(compressedImage, compressionVal).length))/(1048576.000000000f)))))))/(2));
        compressionVal *= 0.97;//subtracts 3% of it's current value just incase above algorithm limits at just above MaxVal and while loop becomes infinite.
        
        if (initialCompressionVal == 0.00000000f) {
            initialCompressionVal = compressionVal;
        }
        
        iterations ++;
        
        if ((iterations >= 3) || (compressionVal < 0.1)) {
            iterations = 0;
            NSLog(@"%f", compressionVal);
            
            compressionVal = 1.0f;
            
            compressedImage = [UIImage imageWithData:UIImageJPEGRepresentation(compressedImage, compressionVal)];
            
            float resizeAmount = 1.0f;
            resizeAmount = (resizeAmount+initialCompressionVal)/(2);//percentage
            resizeAmount *= 0.97;//3% boost just incase image compression algorithm reaches a limit.
            resizeAmount = 1/(resizeAmount);//value
            initialCompressionVal = 0.00000000f;
            
            
            UIView *imageHolder = [[UIView alloc] initWithFrame:CGRectMake(0,0,(int)floorf((float)(compressedImage.size.width/(resizeAmount))), (int)floorf((float)(compressedImage.size.height/(resizeAmount))))];//round down to ensure frame isnt larger than image itself
            
            UIImageView *theResizedImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,(int)ceilf((float)(compressedImage.size.width/(resizeAmount))), (int)ceilf((float)(compressedImage.size.height/(resizeAmount))))];//round up to ensure image fits
            theResizedImage.image = compressedImage;
            
            
            [imageHolder addSubview:theResizedImage];
            
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageHolder.frame.size.width, imageHolder.frame.size.height), YES, 1.0f);
            CGContextRef resize_context = UIGraphicsGetCurrentContext();
            [imageHolder.layer renderInContext:resize_context];
            compressedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            //after 3 compressions, if we still haven't shrunk down to maxVal size, apply the maximum compression we can, then resize the image (90%?), then re-start the process, this time compressing the compressed version of the image we were checking.
            
        }
        
        totalIterations ++;
        
    }
    
    if (totalIterations >= 1024) {
        NSLog(@"Image was too big, gave up on trying to re-size");//too many iterations failsafe. Gave up on trying to resize.
    } else {
        NSData *imageData = UIImageJPEGRepresentation(compressedImage, compressionVal);
        NSLog(@"FINAL Image is %f MB ... iterations: %i", (float)(((float)imageData.length)/(1048576.000000f)), totalIterations);//converts bytes to MB
        
        self.data = imageData;//save new image to UIImageView.
    }
}
@end
