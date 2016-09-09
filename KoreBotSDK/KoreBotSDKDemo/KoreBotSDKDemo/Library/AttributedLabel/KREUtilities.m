//
//  KREUtilities.m
//  KoreBotSDKDemo
//
//  Created by Vijay Rayudu on 9/8/16.
//  Copyright © 2016 Kore. All rights reserved.
//

#import "KREUtilities.h"
#import "NSString+HTML.h"

@implementation KREUtilities

+ (NSString *)getStringToDisplayFromString:(NSString *)string{
    if(!string) return @"";
    NSString *objUnicodeRemovedString = [self removeOBJUniCodeFromString:string];
    NSMutableString *str = [objUnicodeRemovedString mutableCopy];
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"@[\\w]+(\\s\\[.+?\\])"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:NULL];
    NSArray *result = [regex matchesInString:str options:0 range:NSMakeRange(0, [string length])];
    [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        NSRange range = [match rangeAtIndex:1];
        [str replaceCharactersInRange:range withString:@""];
    }];
    return [str copy];
}
+ (NSString *)getHTMLStrippedStringFromString:(NSString *)string{
    if(!string) return nil;
    
    NSMutableString *str = [[NSMutableString alloc] initWithString:string];
    
    //replace <br> or <br/> characters with newline charcater
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"(<br/>)|(<br>|<br />)"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:NULL];
    [regex replaceMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@"\n"];
    
    //filtering all other html characters
    regex = [NSRegularExpression
             regularExpressionWithPattern:@"(<[^>]+>)"
             options:NSRegularExpressionCaseInsensitive
             error:NULL];
    [regex replaceMatchesInString:str
                          options:0
                            range:NSMakeRange(0, [str length])
                     withTemplate:@""];
    NSString *sString = [str copy];
    sString = [[sString stringByReplacingHTMLEntities] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    sString = [KREUtilities getMarkdownStringFromString:sString];
    return sString;
}

+ (NSString *)getMarkdownStringFromString:(NSString *)string{
    if(!string) return nil;
    //    __block NSString *originalString = @"First date: \\dt(2016-01-08T13:36:56.060-0530,\"ddd, MMM dd, yyyy\") \nSecond date: \\dt(2016-01-08T13:36:56.060Z, \"dddd, MMMM dd, yyyy\" ) \nThird date: \\dt(2016-01-08T13:36:56.060-0530  ,'ddd., MMM. dd, yyyy') \nFourth date: \\dt( 2016-01-08T13:36:56.060Z, \"ddd., MMM. dd, yyyy \") \nFifth maybe date: \\dt(2016-01-08T13:36:56.060z   ,  'ddd., MMM. dd, yyyy' ) \n\\d(2016-01-08,\"MMMM dd, yyyy\") \n\\d(2016-01-08) \\t(13:36:56.060) \\t(13:36:56.060, \"a mm:h\") \\#(12345.67) \\#(12345.67,\"#,##0.000\") \\$(12345.67,\"USD\",\"#,##0.000\") \n\\$(12345.67,\"USD\") \n\\$(12000,\"USD\")";
    
    __block NSString *originalString = [string copy];
    __block NSMutableString *sString = [[NSMutableString alloc] initWithString:originalString];
    NSString *optionRegexString = @"(?:,\\s*[\"'](.+?)[\"']\\s*)?";
    NSString *regexString = nil;
    NSRegularExpression *regex = nil;
    NSArray *result = nil;
    
    //check for datetime strings
    regexString = [NSString stringWithFormat:@"\\\\(d|t|dt)\\(\\s*(?:(.{10}[T].{12}(?:z|[+-]\\d{4}))|(.{10})|(.{8}(?:\\.\\d{0,3})?))\\s*%@\\)",optionRegexString];
    regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:NULL];
    result = [regex matchesInString:originalString options:0 range:NSMakeRange(0, [originalString length])];
    [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        NSString *checkString = [originalString substringWithRange:(NSRange)[match rangeAtIndex:1]];
        NSString *stringToReplace = nil;
        
        //get dateTime string if available
        NSRange range = [match rangeAtIndex:2];
        NSString *dateTimeString = (range.length)?[originalString substringWithRange:range]:nil;
        //get date string if available
        range = [match rangeAtIndex:3];
        NSString *dateString = (range.length)?[originalString substringWithRange:range]:nil;
        //get time string if available
        range = [match rangeAtIndex:4];
        NSString *timeString = (range.length)?[originalString substringWithRange:range]:nil;
        //get option string if available
        range = [match rangeAtIndex:5];
        NSString *optionString = (range.length)?[originalString substringWithRange:range]:nil;
        if(optionString)
            optionString = [KREUtilities parseOptionStringForProperFormat:optionString];
        
        if(dateTimeString.length){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
            [dateFormatter setLocale:[NSLocale systemLocale]];
            NSDate *date = [dateFormatter dateFromString:dateTimeString];
            
            if(optionString.length){
                dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:optionString];
                stringToReplace = [dateFormatter stringFromDate:date];
                
            }else if([checkString isEqualToString:@"d"]){
                stringToReplace = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
                
            }else if([checkString isEqualToString:@"t"]){
                stringToReplace = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
                
            }else if([checkString isEqualToString:@"dt"]){
                stringToReplace = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
                
            }
        }else if(dateString.length){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            [dateFormatter setLocale:[NSLocale systemLocale]];
            NSDate *date = [dateFormatter dateFromString:dateString];
            
            if(optionString.length){
                dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:optionString];
                stringToReplace = [dateFormatter stringFromDate:date];
            }else{
                stringToReplace = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
            }
        }else if (timeString.length){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            if(timeString.length == 8)
                [dateFormatter setDateFormat:@"HH:mm:ss"];
            else
                [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
            [dateFormatter setLocale:[NSLocale systemLocale]];
            NSDate *date = [dateFormatter dateFromString:timeString];
            
            if(optionString.length){
                dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:optionString];
                stringToReplace = [dateFormatter stringFromDate:date];
            }else{
                stringToReplace = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
            }
        }
        
        if(stringToReplace)
            [sString replaceCharactersInRange:match.range withString:stringToReplace];
    }];
    
    originalString = [sString copy];
    //check for numbers strings
    regexString = [NSString stringWithFormat:@"\\\\(#|\\$)\\(\\s*([\\d.]*)\\s*(?:,\\s*[\"'](\\w{3})[\"']\\s*)?%@\\)",optionRegexString];
    regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:NULL];
    result = [regex matchesInString:originalString options:0 range:NSMakeRange(0, [originalString length])];
    [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        NSString *checkString = [originalString substringWithRange:(NSRange)[match rangeAtIndex:1]];
        NSString *stringToReplace = nil;
        
        NSString *numberString = [originalString substringWithRange:(NSRange)[match rangeAtIndex:2]];
        NSRange optionStringRange = [match rangeAtIndex:4];
        NSString *optionString = (optionStringRange.length)?[originalString substringWithRange:optionStringRange]:nil;
        
        if([checkString isEqualToString:@"#"]){
            NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
            numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            if(optionString.length){
                [numberFormatter setPositiveFormat:optionString];
            }
            
            stringToReplace = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:numberString.floatValue]];
            
        }else if([checkString isEqualToString:@"$"]){
            NSRange range = [match rangeAtIndex:3];
            NSString *currencyCode = (range.length)?[originalString substringWithRange:range]:nil;
            
            NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
            numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
            if(optionString.length){
                [numberFormatter setPositiveFormat:optionString];
            }
            numberFormatter.currencyCode = currencyCode;
            stringToReplace = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:numberString.floatValue]];
            
        }
        
        if(stringToReplace)
            [sString replaceCharactersInRange:match.range withString:stringToReplace];
    }];
    
    return sString;
}

+(NSString *)removeOBJUniCodeFromString:(NSString *)text{
    static NSString * const OBJECT_REPLACEMENT_CHARACTER = @"\uFFFC";
    NSString *objReplaceCharacter = [text stringByReplacingOccurrencesOfString:OBJECT_REPLACEMENT_CHARACTER withString:@""];
    return objReplaceCharacter;
}
+ (NSString *)parseOptionStringForProperFormat:(NSString *)string{
    NSMutableString *str = [string mutableCopy];
    //replace 'ddd' with 'EEE' characters
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\bddd\\b" options:0 error:NULL];
    [regex replaceMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@"EEE"];
    
    //replace 'dddd' with 'EEEE' characters
    regex = [NSRegularExpression regularExpressionWithPattern:@"\\bdddd\\b" options:0 error:NULL];
    [regex replaceMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@"EEEE"];
    
    //replace 'A' with 'a' characters
    regex = [NSRegularExpression regularExpressionWithPattern:@"\\bA\\b" options:0 error:NULL];
    [regex replaceMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@"a"];
    
    return str;
}
+ (NSDictionary*)getSearchHighlightAttributesForTableCell:(NSUInteger)type{
    switch (type) {
        case 0:
            return @{NSForegroundColorAttributeName:UIColorRGB(0x2D78FB)};
            break;
        case 1:
            return @{NSForegroundColorAttributeName:UIColorRGB(0x000000)};
            break;
        case 2:
            return @{NSFontAttributeName:[UIFont fontWithName:@"Lato-Bold" size:14]};
            break;
    }
    return nil;
}

+ (NSDictionary*)getSearchHighlightAttributes:(NSUInteger)type{
    switch (type) {
        case 0:
            return @{NSForegroundColorAttributeName:UIColorRGB(0x000000), NSBackgroundColorAttributeName:[UIColor lightGrayColor]};
            break;
        case 1:
            return @{NSForegroundColorAttributeName:UIColorRGB(0x000000), NSBackgroundColorAttributeName:[UIColor whiteColor]};
        case 2:
            return @{NSFontAttributeName:[UIFont fontWithName:@"Lato-Bold" size:14]};
            break;
        case 3:
            return @{NSForegroundColorAttributeName:UIColorRGB(0x000000), NSBackgroundColorAttributeName:[UIColor yellowColor]};;
            break;
    }
    return nil;
}
@end
