//
//  Common.h
//  SpeechToText
//
//  Created by Shylaja Mamidala on 11/23/16.
//  Copyright © 2016 Kore. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kreSpeechServer = @"wss://%@/stream/kore/decode?content-type=%@&email=%@";
#define PRESENCE_SERVER @"speech.kore.ai"
#define VOICE_CONTENT_TYPE @"audio/x-raw,+layout=interleaved,+rate=16000,+format=S16LE,+channels=1"

@interface Common : NSObject

@end
