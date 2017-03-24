//
//  Common.h
//  SpeechToText
//
//  Created by developer@kore.com on 11/23/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kreSpeechServer = @"%@?content-type=%@&email=%@";
#define SPEECH_SERVER @"wss://speech.kore.ai/speechcntxt/verizon"

#define VOICE_CONTENT_TYPE @"audio/x-raw,+layout=interleaved,+rate=16000,+format=S16LE,+channels=1"

@interface Common : NSObject

@end
