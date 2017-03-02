/*
 * StringUtilities.m
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

#import "StringUtilities.h"

@implementation StringUtilities

+ (NSString*) getLocalizedString:(NSString*)key comment:(NSString*)comment {
    
    NSString *locale = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *lang = [locale componentsSeparatedByString:@"-"][0];

    NSString *path = [[NSBundle mainBundle] pathForResource:lang ofType:@"lproj"];
    if (path == nil){
        path = [[NSBundle mainBundle] pathForResource:@"Base" ofType:@"lproj"];
    }
    
    NSBundle * bundle = nil;
    if(path == nil){
        bundle = [NSBundle mainBundle];
    }else{
        bundle = [NSBundle bundleWithPath:path];
    }
    
    return [bundle localizedStringForKey:key value:comment table:nil];

}

@end
