//
//  RequestManager.h
//  SpeechToText
//
//  Created by developer@kore.com on 11/21/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KREWebSocket.h"
#import "MCAudioInputQueue.h"

@protocol SpeechToTextDelegate <NSObject>

-(void)SpeechToTextdataDictionary:(NSDictionary *)dataDictionary;

@end


@interface RequestManager : NSObject<KREWebSocketDelegate,MCAudioInputQueueDelegate>
{
    AudioStreamBasicDescription audioFormat;
}

@property (nonatomic, strong) KREWebSocket *webSocket;
@property (nonatomic, strong) MCAudioInputQueue * audioQueueRecorder;
@property (assign) BOOL isAudioQueueRecordingInProgress;
@property (strong, nonatomic) NSMutableData *audioBuffer;
@property (nonatomic, strong) NSData * recordedData;

@property (nonatomic, weak) id <SpeechToTextDelegate> sttdelegate;

-(instancetype)init;

-(void)intializeSocket;
-(void)intializeAudioQueue;
-(void) setUpAudioQueueFormat;
-(void)doAudioQueueRecording;
- (void) stopAudioQueueRecording;

@end
