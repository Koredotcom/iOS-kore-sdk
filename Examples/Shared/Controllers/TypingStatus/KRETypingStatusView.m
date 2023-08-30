//
//  KRETypingStatusView.m
//  KoreApp
//
//  Created by developer@kore.com on 03/06/15.
//  Copyright (c) 2015 Kore Inc. All rights reserved.
//

#import "KRETypingStatusView.h"
#import "KRETypingCollectionViewCell.h"
#import "KRETypingActivityIndicator.h"
#import "KREUtilities.h"

@interface KRETypingStatusView () <UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) KRETypingActivityIndicator *dancingDots;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIImage *loaderImage;

@end

@implementation KRETypingStatusView

- (instancetype)init {
    self = [super init];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(30.0, 30.0);
        layout.minimumInteritemSpacing = 5.0;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                 collectionViewLayout:layout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.dataSource = self;
        NSString *bundle = [NSBundle bundleForClass: [KRETypingStatusView self]];
        
        [self.collectionView registerNib:[UINib nibWithNibName:@"KRETypingCollectionViewCell" bundle: [bundle self]] forCellWithReuseIdentifier:@"TypingCell"];
        [self addSubview:self.collectionView];
        
        //self.statusLabel = [[UILabel alloc] init];
        //self.statusLabel.backgroundColor = [UIColor clearColor];
        //self.statusLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
        //self.statusLabel.textColor = [UIColor grayColor];
        //[self addSubview:self.statusLabel];
        
        self.dancingDots = [[KRETypingActivityIndicator alloc] init];
        self.dancingDots.dotSize = 4.5;
//        [self.dancingDots startAnimation];
        [self addSubview:self.dancingDots];

        self.dataSource = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addTypingStatusForContact:(NSMutableDictionary *)contactInfo  forTimeInterval:(NSTimeInterval)timeInterval loaderImage:(UIImage *)loaderImage{
    
    NSDate *fireDate = [NSDate dateWithTimeInterval:timeInterval sinceDate:[NSDate date]];
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:fireDate
                                              interval:0
                                                target:self
                                              selector:@selector(timerFiredToRemoveTypingStatus:)
                                              userInfo:@""
                                               repeats:NO];
    //[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    self.loaderImage = loaderImage;
    if(![self.dataSource containsObject:contactInfo]){
        [contactInfo setValue:timer forKey:@"timer"];
        [self.dataSource addObject:contactInfo];
    }
    [self.collectionView reloadData];
    [self updateStatusLabel];
    [self setNeedsLayout];
    self.hidden = NO;
    
    [self.dancingDots startAnimation];
    [self setHidden:NO];
}

- (void)updateStatusLabel {
    NSString *string = nil;
    if([self.dataSource count]>1) {
        string = @" are typing...";
    } else {
        string = @" is typing...";
    }
    self.statusLabel.text = string;
}

- (void)timerFiredToRemoveTypingStatus:(NSTimer*)timer {
    [timer invalidate];
    [self.dataSource removeAllObjects];
    if([self.dataSource count]==0) {
        self.hidden = YES;
    }
    [self.collectionView reloadData];
    //[self updateStatusLabel];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    CGFloat width = self.frame.size.width/2;
    CGFloat kCollectionViewLeftPadding = 5.0;
    CGFloat kCollectionViewEndPadding = 5.0;
    CGFloat kDancingDotsWidth = 27.0;
    CGFloat kDancingDotsPadding = 5.0;
    if([self.dataSource count]>0) {
        width = [self.dataSource count]*40.0 - kCollectionViewEndPadding;
    }
    if(width+kDancingDotsWidth+kCollectionViewLeftPadding+kDancingDotsPadding > self.frame.size.width){
        width = self.frame.size.width-kDancingDotsWidth-kCollectionViewLeftPadding-kDancingDotsPadding;
    }
    self.collectionView.frame = CGRectMake(kCollectionViewLeftPadding, 0, width, self.frame.size.height);
    self.dancingDots.frame = CGRectMake(0,
                                        (self.frame.size.height-10.0)/2,
                                        kDancingDotsWidth,
                                        10.0);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ([self.dataSource count] > 0) ? 1 :0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KRETypingCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"TypingCell"
                                                                                       forIndexPath:indexPath];
    
    NSString *bundle = [NSBundle bundleForClass: [KRETypingStatusView self]];
//    NSDictionary *dict = [self.dataSource objectAtIndex:indexPath.row];
//    NSString *url = dict[@"imageName"];
    //[cell.customImageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@""]];
    
//    NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
//    if ( data == nil ){
//        NSString *bundle = [NSBundle bundleForClass: [KRETypingStatusView self]];
//        cell.customImageView.image = [UIImage imageNamed:@"kora" inBundle:[bundle self] withConfiguration:nil];
//    }else{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            cell.customImageView.image = [UIImage imageWithData: data];
//        });
//    }
    
    if (_loaderImage != nil){
        cell.customImageView.image = self.loaderImage;
    }else{
        if (@available(iOS 13.0, *)) {
            cell.customImageView.image = [UIImage imageNamed:@"kora" inBundle:[bundle self] withConfiguration: nil];
        } else {
            // Fallback on earlier versions
        }
    }
    cell.layer.cornerRadius = cell.frame.size.height/2;
    return cell;
}


- (void)dealloc {
    for (NSDictionary *dict in self.dataSource) {
        NSTimer *timer = dict[@"timer"];
        [timer invalidate];
    }
    
    [self.dancingDots stopAnimation];
    [self.dataSource removeAllObjects];
    self.dataSource = nil;
    [self.collectionView removeFromSuperview];
    [self.statusLabel removeFromSuperview];
    self.collectionView = nil;
    self.statusLabel = nil;
}

@end
