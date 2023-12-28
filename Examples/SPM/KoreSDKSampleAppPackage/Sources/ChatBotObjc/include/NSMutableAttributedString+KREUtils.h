//
//  NSMutableAttributedString+KREUtils.h
//  KoreApp
//
//  Created by developer@kore.com on 11/02/15.
//  Copyright (c) 2015 Kore Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (KREUtils)

+ (NSAttributedString*) attributedString:(NSString*)string
            withSearchStringHighlighting:(NSString*)searchString
                       defaultAttributes:(NSDictionary*)defaultAttributes
                   highlightedAttributes:(NSDictionary*)highlightedAttributes;

+ (NSAttributedString*) attributedString:(NSString*)string
            withSearchStringHighlighting:(NSString*)searchString
                       defaultAttributes:(NSDictionary*)defaultAttributes
                   highlightedAttributes:(NSDictionary*)highlightedAttributes
                        beginsWithSearch:(BOOL)isBeginsWithSearch
                        withPhraseSearch:(BOOL)detectPhrases;

+ (NSAttributedString*) attributedString:(NSString*)string
            withSearchStringHighlighting:(NSString*)searchString
                       defaultAttributes:(NSDictionary*)defaultAttributes
                   highlightedAttributes:(NSDictionary*)highlightedAttributes
                                   range:(NSRange)range;

+ (NSAttributedString*) attributedString:(NSString*)string
            withSearchStringHighlighting:(NSString*)searchString
                       defaultAttributes:(NSDictionary*)defaultAttributes
                   highlightedAttributes:(NSDictionary*)highlightedAttributes
                                   range:(NSRange)range
                        beginsWithSearch:(BOOL)isBeginsWithSearch
                        withPhraseSearch:(BOOL)detectPhrases;

+ (NSAttributedString*) attributedString:(NSAttributedString*)attributedString
            withSearchStringHighlighting:(NSString*)searchString
                   highlightedAttributes:(NSDictionary*)highlightedAttributes;

+ (NSAttributedString*) attributedString:(NSAttributedString*)attributedString
            withSearchStringHighlighting:(NSString*)searchString
                   highlightedAttributes:(NSDictionary*)highlightedAttributes
                        beginsWithSearch:(BOOL)isBeginsWithSearch
                        withPhraseSearch:(BOOL)detectPhrases;

- (void) applySearchStringHighlighting:(NSString*)searchString
                 highlightedAttributes:(NSDictionary*)highlightedAttributes;

- (void) applySearchStringHighlighting:(NSString*)searchString
                 highlightedAttributes:(NSDictionary*)highlightedAttributes
                      beginsWithSearch:(BOOL)isBeginsWithSearch
                      withPhraseSearch:(BOOL)detectPhrases;

- (void) applySearchStringHighlighting:(NSString*)searchString
                 highlightedAttributes:(NSDictionary*)highlightedAttributes
                                 range:(NSRange)range
                      beginsWithSearch:(BOOL)isBeginsWithSearch
                      withPhraseSearch:(BOOL)detectPhrases;
@end
