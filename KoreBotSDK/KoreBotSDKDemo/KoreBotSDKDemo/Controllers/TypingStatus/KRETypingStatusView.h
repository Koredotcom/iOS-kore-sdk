//
//  KRETypingStatusView.h
//  KoreApp
//
//  Created by developer@kore.com on 03/06/15.
//  Copyright (c) 2015 Kore Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KRETypingStatusView : UIView

- (void)addTypingStatusForContact:(NSMutableDictionary *)contactInfo forTimeInterval:(NSTimeInterval)timeInterval;

@end
