//
//  KRELayoutManager.h
//  KoreApp
//
//  Created by developer@kore.com on 03/02/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KRELayoutManager : NSLayoutManager

@property (nonatomic, assign) UIEdgeInsets edgeInset;

- (id) initWithAttributedString:(NSAttributedString *)string andWidth:(CGFloat)width;
- (CGRect) boundingRectForCharacterRange:(NSRange)range;

@end
