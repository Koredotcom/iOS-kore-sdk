//
//  KREAttributedLabel.m
//  KoreApp
//
//  Created by Anoop on 21/11/14.
//  Copyright (c) 2014 Kore Inc. All rights reserved.
//

#import "KREAttributedLabel.h"
#import "KREUtilities.h"
#import "NSMutableAttributedString+KREUtils.h"
#import "KRELayoutManager.h"

@interface KREAttributedLabel()<UIGestureRecognizerDelegate>

@property(strong, nonatomic) NSMutableArray *touchableWords;
@property(strong, nonatomic) NSMutableArray *touchableWordsType;
@property(strong, nonatomic) NSMutableArray *touchableLocations;

@property(assign, nonatomic) KREAttributedHotWord currentSelectedType;
@property(strong, nonatomic) NSString *currentSelectedString;

@property(strong, nonatomic) NSMutableArray *touchableLayers;

@end

@implementation KREAttributedLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void) setUpView{
    if(self.textColor == nil)
        self.textColor = [UIColor lightGrayColor];
    _focusedHighlighting = NO;
    _mentionTextColor = [UIColor darkGrayColor];
    _hashtagTextColor = [UIColor darkGrayColor];
    _linkTextColor = UIColorRGB(0x0076FF);
    
    _touchableWords = [[NSMutableArray alloc] init];
    _touchableLocations = [[NSMutableArray alloc] init];
    _touchableWordsType = [[NSMutableArray alloc] init];
    _touchableLayers = [[NSMutableArray alloc] init];
    self.text = @"";
    self.lineBreakMode = NSLineBreakByWordWrapping;
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    singleTapGesture.numberOfTapsRequired = 1.0;
    singleTapGesture.delegate = self;
    [self addGestureRecognizer:singleTapGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognizer:)];
    doubleTapGesture.numberOfTapsRequired = 2.0;
    doubleTapGesture.delegate = self;
    [self addGestureRecognizer:doubleTapGesture];
    
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
}

- (void)prepareForReuse{
    [_touchableWords removeAllObjects];
    [_touchableWordsType removeAllObjects];
    [_touchableLocations removeAllObjects];
    [self removeAllTouchableLayers];
}

- (NSString *) replaceStringWithAsterisk:(NSString *)string inRange:(NSRange )range{
    NSString *originalString = string;
    NSString *nonspaceRegexp = @"\\S"; // = /\S/
    NSStringCompareOptions options = NSRegularExpressionSearch;
    NSString *replacedString = [originalString stringByReplacingOccurrencesOfString:nonspaceRegexp withString:@"*" options:options range:range];
    
    return replacedString;
}

- (void)setString:(NSString *)sString
{
    [_touchableWords removeAllObjects];
    [_touchableWordsType removeAllObjects];
    [_touchableLocations removeAllObjects];
    [self removeAllTouchableLayers];
    
    if(sString.length == 0)
        return;
    
    __weak typeof(self) weakSelf = self;
    NSString *originalString = sString;

    //converting and setting attributed string asyncronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSString *string = [KREUtilities getStringToDisplayFromString:originalString];
        string = [KREUtilities getHTMLStrippedStringFromString:string];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
        [attrString addAttribute:NSForegroundColorAttributeName value:self.textColor range:[string rangeOfString:string]];
        
        //initialize layout manager
        NSMutableAttributedString *layoutManagerString = [attrString mutableCopy];
        [layoutManagerString addAttributes:@{NSFontAttributeName:self.font} range:[string rangeOfString:string]];
        KRELayoutManager *layoutManager = [[KRELayoutManager alloc] initWithAttributedString:layoutManagerString andWidth:self.bounds.size.width];
        layoutManager.edgeInset = self.edgeInset;
        
        // get valid @mentions from the string
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@[\\w]+(?:\\s\\[.+?\\])|@Everyone" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *result = [regex matchesInString:originalString options:0 range:NSMakeRange(0, [originalString length])];
       __block NSMutableString *dupString = [[NSMutableString alloc] initWithString:string];

        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
            //Valid word detection changed componentsSeparatedByString:@" [" to @"["
            NSString *validWord = [(NSString *)[[[originalString substringWithRange:match.range] componentsSeparatedByString:@"["] firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if(validWord.length){
                NSRange range = [dupString rangeOfString:validWord];
                // mask the repeated word with asterisk to avaoid duplicates for highlighting.-> hack
                dupString = [[self replaceStringWithAsterisk:dupString inRange:range] mutableCopy];
                if(range.length){
                    [attrString addAttribute:NSForegroundColorAttributeName value:_mentionTextColor range:range];
                    CGRect pos = [layoutManager boundingRectForCharacterRange:range];
                    [_touchableWords addObject:validWord];
                    [_touchableWordsType addObject:[NSNumber numberWithInteger:KREAttributedHotWordMention]];
                    [_touchableLocations addObject:[NSValue valueWithCGRect:pos]];
                    [weakSelf addTouchableLayerWithRect:pos];
                }
            }
        }];
        // end
        
        if(weakSelf.enableHashtags){
            // get #hashtags from the string
            regex = [NSRegularExpression regularExpressionWithPattern:@"\\B#([A-Z0-9a-z(é|ë|ê|è|à|â|ä|á|ù|ü|û|ú|ì|ï|î|í)_]+)" options:NSRegularExpressionCaseInsensitive error:nil];
            result = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
            [result enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
                NSString *validWord = [string substringWithRange:match.range];
                [attrString addAttribute:NSForegroundColorAttributeName value:_hashtagTextColor range:match.range];
                
                CGRect pos = [layoutManager boundingRectForCharacterRange:match.range];
                [_touchableWords addObject:validWord];
                [_touchableWordsType addObject:[NSNumber numberWithInteger:KREAttributedHotWordHashtag]];
                [_touchableLocations addObject:[NSValue valueWithCGRect:pos]];
                [weakSelf addTouchableLayerWithRect:pos];
            }];
            //end
        }
        
        // get URL links from the string
        regex = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:nil];
        result = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
            [attrString addAttribute:NSForegroundColorAttributeName value:_linkTextColor range:match.range];
            [attrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:match.range];
            
            CGRect pos = [layoutManager boundingRectForCharacterRange:match.range];
            if ([match resultType] == NSTextCheckingTypeLink) {
                [_touchableWords addObject:[[match URL] absoluteString]];
                [_touchableWordsType addObject:[NSNumber numberWithInteger:KREAttributedHotWordLink]];
            } else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
                [_touchableWords addObject:[match phoneNumber]];
                [_touchableWordsType addObject:[NSNumber numberWithInteger:KREAttributedHotWordPhoneNumber]];
            }
            [_touchableLocations addObject:[NSValue valueWithCGRect:pos]];
            [weakSelf addTouchableLayerWithRect:pos];
        }];
        //end
        
        if(weakSelf.searchString != nil){
            NSDictionary *highlightAttributes;
            if(weakSelf.searchHighlightAttributes){
                highlightAttributes = weakSelf.searchHighlightAttributes;
            }else{
                highlightAttributes = [KREUtilities getSearchHighlightAttributes:0];
            }
            [attrString applySearchStringHighlighting:weakSelf.searchString highlightedAttributes:highlightAttributes range:NSMakeRange(0,[attrString length]) beginsWithSearch:NO withPhraseSearch:YES];
        }
        //setting attributed text on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.attributedText = attrString;
        });
    });
}

- (void) setString:(NSString *)string withHotwords:(NSArray *)hotwords
{
    [_touchableWords removeAllObjects];
    [_touchableWordsType removeAllObjects];
    [_touchableLocations removeAllObjects];
    [self removeAllTouchableLayers];
    
    if(string.length == 0)
        return;
    
    self.text = string;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    [attrString addAttribute:NSForegroundColorAttributeName value:self.textColor range:[string rangeOfString:string]];
    
    NSUInteger startLocation = 0;
    for(NSString *word in hotwords){
        NSRange wordSearchRange = NSMakeRange(startLocation, ([string length] - startLocation));
        NSRange matchRange = [string rangeOfString:word options:NSLiteralSearch range:wordSearchRange];
        if(matchRange.length > 0){
            [attrString addAttribute:NSForegroundColorAttributeName value:_mentionTextColor range:matchRange];
            if(_mentionTextFont)
                [attrString addAttribute:NSFontAttributeName value:_mentionTextFont range:matchRange];
            
            CGRect pos = [self boundingRectForCharacterRange:matchRange];
            [_touchableWords addObject:word];
            [_touchableWordsType addObject:[NSNumber numberWithInteger:KREAttributedHotWordUserDefined]];
            [_touchableLocations addObject:[NSValue valueWithCGRect:pos]];
        }
        startLocation += matchRange.location + matchRange.length;
    }
    
    self.attributedText = attrString;
}

- (void) setHTMLString:(NSString *)sString withWidth:(CGFloat)width
{
    [_touchableWords removeAllObjects];
    [_touchableWordsType removeAllObjects];
    [_touchableLocations removeAllObjects];
    [self removeAllTouchableLayers];
    
    if(sString.length == 0)
        return;
    
    __weak typeof(self) weakSelf = self;

    //converting and setting attributed string asyncronously
//    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        self.attributedText =  [[NSAttributedString alloc] initWithString:[KREUtilities getHTMLStrippedStringFromString:sString]];

        NSString *originalString = sString;
        NSString *string = [KREUtilities getHTMLStrippedStringFromString:sString];
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
        [attrString addAttribute:NSForegroundColorAttributeName value:self.textColor range:[string rangeOfString:string]];
        
        //initialize layout manager
        NSMutableAttributedString *layoutManagerString = [attrString mutableCopy];
        [layoutManagerString addAttributes:@{NSFontAttributeName:self.font} range:[string rangeOfString:string]];
        KRELayoutManager *layoutManager = [[KRELayoutManager alloc] initWithAttributedString:layoutManagerString andWidth:width];
        layoutManager.edgeInset = self.edgeInset;
        
        // get valid href links from the string
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<a href\\s*=(['\"]|)+([^'\"]+)[^<>]+>([^<>]+)<\\/a>" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *result = [regex matchesInString:originalString options:0 range:NSMakeRange(0, [originalString length])];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
            NSString *url = [originalString substringWithRange:(NSRange)[match rangeAtIndex:2]];
            NSString *tempString = [[originalString substringWithRange:(NSRange)[match rangeAtIndex:3]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if(tempString.length){
                NSRange range = [string rangeOfString:[KREUtilities getHTMLStrippedStringFromString:tempString]];
                if(range.length){
                    [attrString addAttribute:NSForegroundColorAttributeName value:_linkTextColor range:range];
                    [attrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
                    
                    CGRect pos = [layoutManager boundingRectForCharacterRange:range];
                    
                    //extended region
                    pos.origin.x -= 10;
                    pos.origin.y -= 5;
                    pos.size.width += 14;
                    pos.size.height += 10;
                    [_touchableWords addObject:url];
                    [_touchableWordsType addObject:[NSNumber numberWithInteger:KREAttributedHotWordLink]];
                    [_touchableLocations addObject:[NSValue valueWithCGRect:pos]];
                    [weakSelf addTouchableLayerWithRect:pos];
                }
            }
        }];
        //end
        
        // get URL links from the string
        regex = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:nil];
        result = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
            [attrString addAttribute:NSForegroundColorAttributeName value:_linkTextColor range:match.range];
            [attrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:match.range];
            
            CGRect pos = [layoutManager boundingRectForCharacterRange:match.range];
            if ([match resultType] == NSTextCheckingTypeLink) {
                [_touchableWords addObject:[[match URL] absoluteString]];
                [_touchableWordsType addObject:[NSNumber numberWithInteger:KREAttributedHotWordLink]];
            } else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
                [_touchableWords addObject:[match phoneNumber]];
                [_touchableWordsType addObject:[NSNumber numberWithInteger:KREAttributedHotWordPhoneNumber]];
            }
            [_touchableLocations addObject:[NSValue valueWithCGRect:pos]];
            [weakSelf addTouchableLayerWithRect:pos];
        }];
        //end
        
        if(weakSelf.searchString != nil){
            NSDictionary *highlightAttributes;
            if(weakSelf.searchHighlightAttributes){
                highlightAttributes = weakSelf.searchHighlightAttributes;
            }else{
                highlightAttributes = [KREUtilities getSearchHighlightAttributes:0];
            }
            [attrString applySearchStringHighlighting:weakSelf.searchString highlightedAttributes:highlightAttributes range:NSMakeRange(0,[attrString length]) beginsWithSearch:NO withPhraseSearch:YES];
        }
        //setting attributed text on main thread
//        dispatch_async(dispatch_get_main_queue(), ^{
            self.attributedText = attrString;
//        });
//    });
}

//for debugging purpose
- (void) addTouchableLayerWithRect:(CGRect)rect{
//    __weak typeof(self) weakSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        CALayer *layer = [CALayer layer];
//        layer.frame = rect;
//        layer.backgroundColor = UIColorRGBA(0xffff00, 0.5).CGColor;
//        [self.layer addSublayer:layer];
//        [self.touchableLayers addObject:layer];
//    });
}

- (void) removeAllTouchableLayers{
    [self.touchableLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.touchableLayers removeAllObjects];
}

- (CGRect)boundingRectForCharacterRange:(NSRange)range{
    return [self boundingRectForCharacterRange:range withWidth:self.bounds.size.width];
}

//Thanks to Luke Rogers http://stackoverflow.com/questions/19417776/how-do-i-locate-the-cgrect-for-a-substring-of-text-in-a-uilabel
- (CGRect)boundingRectForCharacterRange:(NSRange)range withWidth:(CGFloat)width
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:[self attributedText]];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(width, CGFLOAT_MAX)];
    textContainer.lineFragmentPadding = 0;
    textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    NSRange glyphRange;
    
    // Convert the range for glyphs.
    [layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
    CGRect rect = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
    
    return rect;
}

#pragma mark - methods override
- (CGSize)sizeThatFits:(CGSize)size{
    CGSize parentSize = [super sizeThatFits:size];
    if(parentSize.width > 0)
        parentSize.height += self.edgeInset.top + self.edgeInset.bottom;
    return parentSize;
}

- (CGSize) intrinsicContentSize
{
    CGSize parentSize = [super intrinsicContentSize];
    if(parentSize.width > 0)
        parentSize.height += self.edgeInset.top + self.edgeInset.bottom;
    return parentSize;
}

- (void)drawTextInRect:(CGRect)rect {
    if(UIEdgeInsetsEqualToEdgeInsets(self.edgeInset, UIEdgeInsetsZero))
        [super drawTextInRect:rect];
    else
        [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInset)];
}

#pragma mark - UIResponder methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_currentSelectedString == nil)
    {
        [super touchesEnded:touches withEvent:event];
    }
}

- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [(UITapGestureRecognizer*)gestureRecognizer numberOfTapsRequired] == 1){
        CGPoint touchLocation = [gestureRecognizer locationInView:self];
        __block BOOL shouldDetect = NO;
        [_touchableLocations enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSValue *location = obj;
            if(CGRectContainsPoint([location CGRectValue], touchLocation)){
                _currentSelectedType = (KREAttributedHotWord)[[_touchableWordsType objectAtIndex:idx] integerValue];
                _currentSelectedString = [_touchableWords objectAtIndex:idx];
                shouldDetect = YES;
                *stop = YES;
            }
        }];
        return shouldDetect;
    }else{
        return YES;
    }
}

- (void) singleTapGestureRecognizer:(UITapGestureRecognizer *) gesture{
    if(_currentSelectedString != nil && _detectionBlock){
        _detectionBlock(_currentSelectedType, _currentSelectedString);
    }
    _currentSelectedString = nil;
}

- (void) doubleTapGestureRecognizer:(UITapGestureRecognizer *) gesture{
    if (![self canBecomeFirstResponder]) {
        return;
    }
    CGRect rect = CGRectZero;
    rect.origin = [gesture locationInView:self];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:rect inView:self];
    [menu setMenuVisible:YES animated:YES];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.text];
    [self resignFirstResponder];
}

- (void) dealloc{
    
    self.mentionTextColor = nil;
    self.hashtagTextColor = nil;
    self.linkTextColor = nil;
    self.mentionTextFont = nil;
    self.searchString = nil;
    self.searchHighlightAttributes = nil;
    
    [_touchableWords removeAllObjects];
    [_touchableWordsType removeAllObjects];
    [_touchableLocations removeAllObjects];
    [_touchableLayers removeAllObjects];
    
    self.touchableWords = nil;
    self.touchableWordsType = nil;
    self.touchableLocations = nil;
    self.touchableLayers = nil;
}

@end
