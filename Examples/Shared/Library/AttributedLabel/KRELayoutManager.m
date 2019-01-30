//
//  KRELayoutManager.m
//  KoreApp
//
//  Created by developer@kore.com on 03/02/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

#import "KRELayoutManager.h"

@interface KRELayoutManager ()

@property (nonatomic, strong) NSTextContainer *textContainer;
@property (nonatomic, strong) NSTextStorage *kTextStorage;

@end

@implementation KRELayoutManager

- (id) initWithAttributedString:(NSAttributedString *)string andWidth:(CGFloat)width{
    self = [super init];
    if(self){
        self.textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(width, CGFLOAT_MAX)];
        self.textContainer.lineFragmentPadding = 0;
        [self addTextContainer:self.textContainer];
        
        self.kTextStorage = [[NSTextStorage alloc] initWithAttributedString:string];
        [self.kTextStorage addLayoutManager:self];
    }
    return self;
}

- (CGRect) boundingRectForCharacterRange:(NSRange)range{
    NSRange glyphRange;
    
    // Convert the range for glyphs.
    [self characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
    CGRect rect = [self boundingRectForGlyphRange:glyphRange inTextContainer:self.textContainer];
    rect.origin.x += self.edgeInset.left;
    rect.origin.y += self.edgeInset.top;
    
    return rect;
}

- (void) dealloc{
    self.textContainer = nil;
    self.kTextStorage = nil;
}

@end
