//
//  MarkdownParser.m
//  MarkdownParser
//
//  Created by Srinivas Vasadi on 09/11/16.
//  Copyright © 2016 Kore. All rights reserved.
//

#import "MarkdownParser.h"

@interface MarkdownParser ()

@property (nonatomic, strong) NSArray *markdownTextParsers;

@end

@implementation MarkdownParser

- (NSArray *)textParsers
{
    if (self.markdownTextParsers) {
        return self.markdownTextParsers;
    }
    
    NSMutableArray *textParsers = [NSMutableArray array];
    
    // Merge the client properties into the default ones and create the normal font
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithName:self.fontName size:self.fontSize];
    UIFont *font = [UIFont fontWithDescriptor:fontDescriptor size:fontDescriptor.pointSize];
    
    // Bold text: `**`
    UIFontDescriptor *boldFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFont *boldFont = [UIFont fontWithDescriptor:boldFontDescriptor size:fontDescriptor.pointSize];
    NSDictionary *boldAttributes = @{NSFontAttributeName: boldFont};
    
    KMTextParser *boldMarkdownParser = [KMTextParser textParserWithDelimiter:@"**" attributes:boldAttributes];
    [textParsers addObject:boldMarkdownParser];
    
    // Italic text: `~`
    UIFontDescriptor *italicFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    UIFont *italicFont = [UIFont fontWithDescriptor:italicFontDescriptor size:fontDescriptor.pointSize];
    NSDictionary *italicAttributes = @{NSFontAttributeName: italicFont};
    
    KMTextParser *italicMarkdownParser = [KMTextParser textParserWithDelimiter:@"~" attributes:italicAttributes];
    [textParsers addObject:italicMarkdownParser];
    
    // Underlined text: `_`
    NSDictionary *underlineAttributes = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSFontAttributeName: font};
    
    KMTextParser *underlineMarkdownParser = [KMTextParser textParserWithDelimiter:@"_" attributes:underlineAttributes];
    [textParsers addObject:underlineMarkdownParser];
    
    // Monospace text: `\``
    // iOS only has two monospace fonts by default: Courier and AmericanTypewriter
    UIFont *monospaceFont = [UIFont fontWithName:@"Courier" size:font.pointSize];
    NSDictionary *monospaceAttributes = @{NSFontAttributeName: monospaceFont};
    
    KMTextParser *monospaceMarkdownParser = [KMTextParser textParserWithDelimiter:@"`" attributes:monospaceAttributes];
    [textParsers addObject:monospaceMarkdownParser];
    
    // URLs: `<...>`
    NSString *URLPattern = @"(<)(.+?)(>)";
    
    KMTextParserProcessingBlock URLProcessingBlock = ^ NSArray * (NSArray *results) {
        NSString *URLString = [results objectAtIndex:2];
        NSDictionary *attributes = @{NSLinkAttributeName: URLString};
        return @[URLString, attributes];
    };
    
    KMTextParser *URLMarkdownParser = [KMTextParser textParserWithPattern:URLPattern processingBlock:URLProcessingBlock];
    [textParsers addObject:URLMarkdownParser];
    
    // Headers: `=`, `==`, etc.
    NSString *headerPattern = @"(=+)( ?)(.+?)(\n)";
    
    KMTextParserProcessingBlock headerProcessingBlock = ^ NSArray * (NSArray *results) {
        NSString *hashes = [results objectAtIndex:1];
        NSUInteger hashCount = [hashes length];
        NSString *headerString = [results objectAtIndex:3];
        
        CGFloat size = boldFontDescriptor.pointSize + 24 - 6 * MIN(hashCount, 4);
        UIFont *headerFont = [UIFont fontWithDescriptor:boldFontDescriptor size:size];
        
        CGFloat baselineOffset = 10.0 - MAX(hashCount, 4);
        
        NSDictionary *attributes = @{NSFontAttributeName: headerFont, NSBaselineOffsetAttributeName: @(baselineOffset)};
        return @[headerString, attributes];
    };
    
    KMTextParser *headerMarkdownParser = [KMTextParser textParserWithPattern:headerPattern processingBlock:headerProcessingBlock];
    [textParsers addObject:headerMarkdownParser];
    
    // Headers: `#.`
    NSString *orderListPattern = @"(#+)(\.?)(.+?)(\n)";
    KMTextParserProcessingBlock orderListProcessingBlock = ^ NSArray * (NSArray *results) {
        NSString *hashes = [results objectAtIndex:1];
        NSUInteger hashCount = [hashes length];
        NSString *listString = [results objectAtIndex:3];
        
        CGFloat size = boldFontDescriptor.pointSize;
        UIFont *headerFont = [UIFont fontWithDescriptor:boldFontDescriptor size:size];
        
        CGFloat baselineOffset = 0;
        NSDictionary *attributes = @{NSFontAttributeName: headerFont, NSBaselineOffsetAttributeName: @(baselineOffset)};
        return @[listString, attributes];
    };
    
    KMTextParser *orderListMarkdownParser = [KMTextParser textParserWithPattern:orderListPattern processingBlock:orderListProcessingBlock];
    [textParsers addObject:orderListMarkdownParser];
    
    // URLs: `[...](...)`
    NSString *URLPattern_ = @"(\\[)(.+?)(])(\\()(.+?)(\\))";
    
    KMTextParserProcessingBlock URLProcessingBlock_ = ^ NSArray * (NSArray *results) {
        NSString *URLString = [results objectAtIndex:5];
        NSDictionary *attributes = @{NSLinkAttributeName: URLString};
        NSString *replacementString = [results objectAtIndex:2];
        return @[replacementString, attributes];
    };
    
    KMTextParser *URLMarkdownParser_ = [KMTextParser textParserWithPattern:URLPattern_ processingBlock:URLProcessingBlock_];
    [textParsers addObject:URLMarkdownParser_];
    
    self.markdownTextParsers = [NSArray arrayWithArray:textParsers];
    
    return self.markdownTextParsers;
}

@end
