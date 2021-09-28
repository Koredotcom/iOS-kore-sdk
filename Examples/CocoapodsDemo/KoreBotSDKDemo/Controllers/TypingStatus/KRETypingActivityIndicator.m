//
//  KRETypingActivityIndicator.m
//  Kore
//
//  Created by developer@kore.com on 12/06/15.
//  Copyright (c) 2015 Kore. All rights reserved.
//

#import "KRETypingActivityIndicator.h"
#import "CALayer+MBAnimationPersistence.h"
#import "KREUtilities.h"

#define MAXDOTS                 3
#define kMinAnimationValue      -2
#define kMaxAnimationValue      2
#define kDelay                  0.2
#define kDuration               1.0
#define kAnimationSpeed         3
#define kSpacingMultiplier      1.5
@implementation KRETypingActivityIndicator

- (instancetype)init {
    self = [super init];
    if(self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    for (int i=0; i<MAXDOTS; i++) {
        CALayer *layer = [CALayer layer];
        layer.contentsScale = [UIScreen mainScreen].scale;
        NSString *colorStr =  [[NSUserDefaults standardUserDefaults] valueForKey:@"ThemeColor"];
        layer.backgroundColor =  [KREUtilities colorWithHexString:[NSString stringWithFormat:@"%@",colorStr]].CGColor;
        [self.layer addSublayer:layer];
    }
    self.clipsToBounds = YES;
}

- (void)layoutSubviews {
    CGFloat xpos = kSpacingMultiplier*self.dotSize;
    for (CALayer *layer in [self.layer sublayers]) {
        layer.position = CGPointMake(xpos, self.bounds.size.height/2);
        layer.bounds = CGRectMake(xpos, self.bounds.size.height/2, self.dotSize, self.dotSize);
        layer.cornerRadius = self.dotSize/2.0;
        xpos += kSpacingMultiplier*self.dotSize;
    }
}

- (void)setDotSize:(CGFloat)dotSize {
    _dotSize = dotSize;
    [self setNeedsLayout];
}

- (void)startAnimation {
    int itr = 0;
    if(self.layer && self.layer.sublayers.count && ![[[self.layer sublayers] firstObject] animationKeys]) {
        for (CALayer *layer in self.layer.sublayers) {
            CAKeyframeAnimation *animation1 = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
            animation1.duration = kDuration;
            animation1.speed = kAnimationSpeed;
            animation1.values = @[@(self.dotSize+kMaxAnimationValue),@(self.dotSize+kMinAnimationValue)];
            animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            animation1.autoreverses = YES;
            animation1.repeatCount = INFINITY;
            animation1.fillMode = kCAFillModeForwards;
            animation1.beginTime = CACurrentMediaTime() + kDelay*itr;
            [layer addAnimation:animation1 forKey:@"position.y"];
            itr++;
            [layer MB_setCurrentAnimationsPersistent];
        }
    }
}

- (void)stopAnimation {
    [[self.layer sublayers] makeObjectsPerformSelector:@selector(removeAllAnimations)];
}

@end
