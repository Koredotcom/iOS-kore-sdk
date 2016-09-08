//
//  KREAttributedLabel.h
//  KoreApp
//
//  Created by Anoop on 21/11/14.
//  Copyright (c) 2014 Kore Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

typedef enum {
    KREAttributedHotWordMention = 0,
    KREAttributedHotWordHashtag,
    KREAttributedHotWordLink,
    KREAttributedHotWordPhoneNumber,
    KREAttributedHotWordUserDefined,
    KREAttributedHotWordPlainText
} KREAttributedHotWord;

/*
    lineBreakMode = NSLineBreakByWordWrapping; // doesn't work with any other mode
 */

@interface KREAttributedLabel : UILabel

@property (nonatomic, strong) UIColor *mentionTextColor;
@property (nonatomic, strong) UIColor *hashtagTextColor;
@property (nonatomic, strong) UIColor *linkTextColor;
@property (nonatomic, strong) UIFont *mentionTextFont;
@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) NSDictionary *searchHighlightAttributes;

@property (nonatomic, assign) UIEdgeInsets edgeInset;
@property (nonatomic, assign) BOOL focusedHighlighting;
@property (nonatomic, assign) BOOL enableHashtags;
@property (nonatomic, assign) BOOL enableCopy;

@property (nonatomic, copy) void (^detectionBlock)(KREAttributedHotWord hotWord, NSString *string);

- (void) prepareForReuse;
- (void) setString:(NSString *)string;
- (void) setString:(NSString *)string withHotwords:(NSArray *)hotwords;
- (void) setHTMLString:(NSString *)string withWidth:(CGFloat)width;

@end
