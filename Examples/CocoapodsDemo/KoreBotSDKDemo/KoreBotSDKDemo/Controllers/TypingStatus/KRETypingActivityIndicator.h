//
//  KRETypingActivityIndicator.h
//  Kore
//
//  Created by developer@kore.com on 12/06/15.
//  Copyright (c) 2015 Kore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KRETypingActivityIndicator : UIView

@property (nonatomic) CGFloat dotSize;

- (void)startAnimation; 
- (void)stopAnimation;

@end
