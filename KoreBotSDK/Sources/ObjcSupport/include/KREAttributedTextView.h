//
//  KREAttributedTextView.h
//  react-native-kore-bot-sdk
//
//  Created by Kartheek.Pagidimarri on 20/01/22.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "TSMarkdownParser.h"
#import "KREAttributedLabel.h"
NS_ASSUME_NONNULL_BEGIN

@interface KREAttributedTextView : UITextView
@property (nonatomic, strong) UIColor *mentionTextColor;
@property (nonatomic, strong) UIColor *hashtagTextColor;
@property (nonatomic, strong) UIColor *linkTextColor;
@property (nonatomic, strong) UIFont *mentionTextFont;

@property (nonatomic, assign) UIEdgeInsets edgeInset;
@property (nonatomic, assign) BOOL focusedHighlighting;
@property (nonatomic, assign) BOOL enableHashtags;
@property (nonatomic, assign) BOOL enableCopy;

@property (nonatomic, copy) void (^detectionBlock)(KREAttributedHotWord hotWord, NSString *string);
@property (nonatomic, copy) void (^imageDetectionBlock)(BOOL reload);

- (void) prepareForReuse;
- (void) setString:(NSString *)string withWidth:(CGFloat)width;
- (void) setString:(NSString *)string withHotwords:(NSArray *)hotwords;
- (void) setHTMLString:(NSString *)string withWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
