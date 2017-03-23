//
//  NSMutableAttributedString+KREUtils.m
//  KoreApp
//
//  Created by developer@kore.com on 11/02/15.
//  Copyright (c) 2015 Kore Inc. All rights reserved.
//

#import "NSMutableAttributedString+KREUtils.h"

@implementation NSMutableAttributedString (KREUtils)

+ (NSAttributedString*) attributedString:(NSString*)string
            withSearchStringHighlighting:(NSString*)searchString
                       defaultAttributes:(NSDictionary*)defaultAttributes
                   highlightedAttributes:(NSDictionary*)highlightedAttributes{
    
    return [NSMutableAttributedString attributedString:string
                          withSearchStringHighlighting:searchString
                                     defaultAttributes:defaultAttributes
                                 highlightedAttributes:highlightedAttributes
                                      beginsWithSearch:YES
                                      withPhraseSearch:NO];
}
+ (NSAttributedString*) attributedString:(NSString*)string
            withSearchStringHighlighting:(NSString*)searchString
                       defaultAttributes:(NSDictionary*)defaultAttributes
                   highlightedAttributes:(NSDictionary*)highlightedAttributes
                        beginsWithSearch:(BOOL)isBeginsWithSearch
                        withPhraseSearch:(BOOL)detectPhrases{
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:defaultAttributes];
    
    [attributedString applySearchStringHighlighting:searchString
                              highlightedAttributes:highlightedAttributes
                                   beginsWithSearch:isBeginsWithSearch
                                   withPhraseSearch:detectPhrases];
    
    return attributedString;
}

+ (NSAttributedString*) attributedString:(NSString*)string
            withSearchStringHighlighting:(NSString*)searchString
                       defaultAttributes:(NSDictionary*)defaultAttributes
                   highlightedAttributes:(NSDictionary*)highlightedAttributes
                                   range:(NSRange)range{
    
    return [NSMutableAttributedString attributedString:string
                          withSearchStringHighlighting:searchString
                                     defaultAttributes:defaultAttributes
                                 highlightedAttributes:highlightedAttributes
                                                 range:range
                                      beginsWithSearch:YES
                                      withPhraseSearch:NO];
}

+ (NSAttributedString*) attributedString:(NSString*)string
            withSearchStringHighlighting:(NSString*)searchString
                       defaultAttributes:(NSDictionary*)defaultAttributes
                   highlightedAttributes:(NSDictionary*)highlightedAttributes
                                   range:(NSRange)range
                        beginsWithSearch:(BOOL)isBeginsWithSearch
                        withPhraseSearch:(BOOL)detectPhrases{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:defaultAttributes];
    if(range.length ==0)
        range =NSMakeRange(0,[string length]);
    [attributedString applySearchStringHighlighting:searchString
                              highlightedAttributes:highlightedAttributes
                                              range:range
                                   beginsWithSearch:isBeginsWithSearch
                                   withPhraseSearch:detectPhrases];
    
    return attributedString;
}

+ (NSAttributedString*) attributedString:(NSAttributedString*)attributedString
            withSearchStringHighlighting:(NSString*)searchString
                   highlightedAttributes:(NSDictionary*)highlightedAttributes{
    
    return [NSMutableAttributedString attributedString:attributedString
                          withSearchStringHighlighting:searchString
                                 highlightedAttributes:highlightedAttributes
                                      beginsWithSearch:YES
                                      withPhraseSearch:NO];
}
+ (NSAttributedString*) attributedString:(NSAttributedString*)attributedString
            withSearchStringHighlighting:(NSString*)searchString
                   highlightedAttributes:(NSDictionary*)highlightedAttributes
                        beginsWithSearch:(BOOL)isBeginsWithSearch
                        withPhraseSearch:(BOOL)detectPhrases{
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    [mutableAttributedString applySearchStringHighlighting:searchString highlightedAttributes:highlightedAttributes ];
    return mutableAttributedString;
}
- (void) applySearchStringHighlighting:(NSString*)searchString
                 highlightedAttributes:(NSDictionary*)highlightedAttributes
                      beginsWithSearch:(BOOL)isBeginsWithSearch
                      withPhraseSearch:(BOOL)detectPhrases{
    [self applySearchStringHighlighting:searchString
                  highlightedAttributes:highlightedAttributes
                                  range:NSMakeRange(0,[self.string length])
                       beginsWithSearch:isBeginsWithSearch
                       withPhraseSearch:detectPhrases];
}
- (void) applySearchStringHighlighting:(NSString*)searchString
                 highlightedAttributes:(NSDictionary*)highlightedAttributes{
    
    [self applySearchStringHighlighting:searchString
                  highlightedAttributes:highlightedAttributes
                                  range:NSMakeRange(0,[self.string length])];
}

- (void) applySearchStringHighlighting:(NSString*)searchString
                 highlightedAttributes:(NSDictionary*)highlightedAttributes
                                 range:(NSRange)range{
    [self applySearchStringHighlighting:searchString highlightedAttributes:highlightedAttributes range:range beginsWithSearch:YES withPhraseSearch:NO];
    
}
- (void) applySearchStringHighlighting:(NSString*)searchString
                 highlightedAttributes:(NSDictionary*)highlightedAttributes
                                 range:(NSRange)range
                      beginsWithSearch:(BOOL)isBeginsWithSearch
                      withPhraseSearch:(BOOL)detectPhrases{
    if ((([searchString length]<=0) && (searchString==nil)) || (self.string==nil && self.string.length <=0))
        return;
    NSMutableArray *spaceSeparatedSearchStrings = [[NSMutableArray alloc] init];
    NSString *editedSearchString = [searchString copy];
    if(detectPhrases){
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"(\".*?\"|\\[.*?\\])"
                                                                                    options:NSRegularExpressionCaseInsensitive
                                                                                      error:nil];
        for (NSTextCheckingResult *result in [expression matchesInString:searchString options:0 range:NSMakeRange(0,[searchString length])]) {
            NSRange resultRange = [result rangeAtIndex:0];
            NSString *phraseString = [searchString substringWithRange:resultRange];
            [spaceSeparatedSearchStrings addObject:[phraseString stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
            editedSearchString = [editedSearchString stringByReplacingOccurrencesOfString:phraseString withString:@" "];
        }
    }
    [spaceSeparatedSearchStrings addObjectsFromArray:[editedSearchString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    [spaceSeparatedSearchStrings filterUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    
    if(NSIntersectionRange(range,NSMakeRange(0,[self.string length])).length == 0)
        range= NSMakeRange(0,[self.string length]);
    
    for (NSString *subSearchString in spaceSeparatedSearchStrings) {
        NSString *pattern;
        if(isBeginsWithSearch)
            pattern= [NSString stringWithFormat:@"(\\b%@)",subSearchString];
        else
            pattern =[NSString stringWithFormat:@"(%@)",subSearchString];
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                    options:NSRegularExpressionCaseInsensitive
                                                                                      error:nil];
        
        
        [expression enumerateMatchesInString:self.string
                                     options:0
                                       range:range
                                  usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                      NSRange resultRange = [result rangeAtIndex:0];
                                      [self addAttributes:highlightedAttributes range:resultRange];
                                  }];
    }
}
@end
