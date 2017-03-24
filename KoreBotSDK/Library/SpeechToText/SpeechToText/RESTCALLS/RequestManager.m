//
//  RequestManager.m
//  SpeechToText
//
//  Created by developer@kore.com on 11/21/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

#import "RequestManager.h"
#import "KREWebSocket.h"
#import "MCAudioInputQueue.h"
#import "Common.h"
#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>
#import <AudioToolbox/AudioQueue.h>

@interface RequestManager()<MCAudioInputQueueDelegate>

@property (nonatomic, strong) NSString* speechServer;
@property (nonatomic, strong) NSString* identity;
@end


@implementation RequestManager

-(instancetype)init{
    self=[super init];
    return self;
}

-(void) intializeSocketWithUrl:(NSString*) url identity:(NSString*) identity {
    if (url.length > 0) {
        self.speechServer = url;
    } else {
        self.speechServer = SPEECH_SERVER;
    }
    if (identity.length > 0) {
        self.identity = identity;
    } else {
        self.identity = @"developer@kore.com";
    }
    self.webSocket = [[KREWebSocket alloc] initWithURLString:[self getSpeechServerUrl]];
    self.webSocket.delegate = self;
    [self.webSocket connect];
    [self setUpAudioQueueFormat];
    [self doAudioQueueRecording];
}

-(void)intializeAudioQueue{
    
}

-(void) setUpAudioQueueFormat{
    
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    audioFormat.mBitsPerChannel = 16;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBytesPerPacket = audioFormat.mBytesPerFrame = (audioFormat.mBitsPerChannel / 8) * audioFormat.mChannelsPerFrame;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mSampleRate = 16000.0f;
    audioFormat.mReserved = 0;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];

    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

-(void)doAudioQueueRecording{
    
    self.audioBuffer = [[NSMutableData alloc] initWithCapacity:0];
    
    self.recordedData = [[NSData alloc] init];

    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
        [session performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.audioQueueRecorder = [MCAudioInputQueue inputQueueWithFormat:audioFormat bufferDuration:0.25 delegate:self];
                    self.audioQueueRecorder.meteringEnabled = YES;
                    self.isAudioQueueRecordingInProgress=YES;
                });
                
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
#ifndef SHARE_EXTENSION
                    [[[UIAlertView alloc] initWithTitle:@"Microphone Access Denied"
                                                message:@"This app requires access to your device's Microphone.\n\nPlease enable Microphone access for this app in Settings / Privacy / Microphone"
                                               delegate:nil
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil] show];
#endif
                });
            }
        }];
        
    }
}

- (void) stopAudioQueueRecording{
    [self.webSocket sendEndOFSpeechMarker];
    [self.audioQueueRecorder stop];
    self.isAudioQueueRecordingInProgress=NO;
}

#pragma mark - webSocket

- (void) webSocketOpen:(SRWebSocket *)webSocket{
    
}
- (void) webSocket:(SRWebSocket *)webSocket onFailWithError:(NSError *)error{
    NSLog(@"*******%s********", __FUNCTION__);
    self.webSocket.delegate = nil;
    self.webSocket = nil;
    if (self.isAudioQueueRecordingInProgress) {
        self.webSocket = [[KREWebSocket alloc] initWithURLString:[self getSpeechServerUrl]];
        self.webSocket.delegate = self;
        [self.webSocket connect];
    }
    
    
}
- (void) webSocket:(SRWebSocket *)webSocket onCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"*******%s********", __FUNCTION__);
    self.webSocket.delegate = nil;
    self.webSocket = nil;
    if(self.isAudioQueueRecordingInProgress){
        self.webSocket = [[KREWebSocket alloc] initWithURLString:[self getSpeechServerUrl]];
        self.webSocket.delegate = self;
        [self.webSocket connect];
        
    }
    
}

- (void) webSocket:(SRWebSocket *)webSocket onReceivePong:(NSData *)pongPayload{
    
}
- (void) webSocket:(SRWebSocket *)webSocket onReceiveMessage:(id) message{
    NSJSONSerialization *jsonResult = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSNumber *status = [jsonResult valueForKey:@"status"];
//    NSLog(@"********* message %@*********", message);
    if ([status intValue] == 0) {
        
        NSDictionary * dataDictionary = [jsonResult valueForKey:@"result"];
        if(dataDictionary){
            dispatch_async(dispatch_get_main_queue(),^{
                [self.sttdelegate SpeechToTextdataDictionary:dataDictionary];
            });
        }
    } else if ([status intValue] == 1) {
        
    }
    
}

- (void)inputQueue:(MCAudioInputQueue *)inputQueue errorOccur:(NSError *)error {
    NSLog(@"error occured %@",error);
}

-(void)inputQueue:(MCAudioInputQueue *)inputQueue inputData:(NSData *)data numberOfPackets:(UInt32)numberOfPackets{
//    NSLog(@"*************%s %luu***********", __FUNCTION__,(unsigned long) (unsigned long)data.length);
//    NSLog(@"web socket State %ld",(long)self.webSocket.webSocket.readyState);
    if (self.webSocket.webSocket.readyState == SR_OPEN) {
        if(self.audioBuffer.length > 0){
            [self.webSocket sendData:self.audioBuffer];
            [self.audioBuffer setData:[NSData dataWithBytes:NULL length:0]];
        }else{
            [self.webSocket sendData:data];
        }
    }
    else{
        [self.audioBuffer appendData:data];
    }

}

#pragma mark - get speech server url 

- (NSString*) getSpeechServerUrl {
    return [NSString stringWithFormat:kreSpeechServer, self.speechServer, VOICE_CONTENT_TYPE, self.identity];
}

-(void)dealloc{
    NSLog(@"requestmanager dealloc");
}

@end
