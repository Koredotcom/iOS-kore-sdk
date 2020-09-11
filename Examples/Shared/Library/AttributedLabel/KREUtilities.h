//
//  KREUtilities.h
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 9/8/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef KoreApp_KRECommon_h
#define KoreApp_KRECommon_h

#define UIColorRGB(rgb) ([[UIColor alloc] initWithRed:(((rgb >> 16) & 0xff) / 255.0f) green:(((rgb >> 8) & 0xff) / 255.0f) blue:(((rgb) & 0xff) / 255.0f) alpha:1.0f])
#define UIColorRGBA(rgb,a) ([[UIColor alloc] initWithRed:(((rgb >> 16) & 0xff) / 255.0f) green:(((rgb >> 8) & 0xff) / 255.0f) blue:(((rgb) & 0xff) / 255.0f) alpha:a])
#endif

@interface KREUtilities : NSObject {
    
}

+ (NSString *)getStringToDisplayFromString:(NSString *)string;
+ (NSString *)getHTMLStrippedStringFromString:(NSString *)string;
+ (NSDictionary*)getSearchHighlightAttributesForTableCell:(NSUInteger)type;
+ (NSDictionary*)getSearchHighlightAttributes:(NSUInteger)type;
+ (NSString *) formatHTMLEscapedString: (NSString *)string;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
@end
