//
//  KREWebSocket.m
//  KoreApp
//
//  Created by developer@kore.com on 9/1/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

#import "KREWebSocket.h"

@implementation KREWebSocket


- (id) initWithURLString:(NSString*)strWebSocketUrl
{
    if (self = [super init]) {
        
        self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strWebSocketUrl]]];
        self.webSocket.delegate = self;
    }
    return self;
}

- (void)connect{
    [self.webSocket open];
}

-(void)close{
    [self.webSocket close];
}
- (void)sendData:(NSData*) data{
    [self.webSocket send:data];
}

- (void)sendEndOFSpeechMarker {
    if (self.webSocket.readyState==SR_OPEN) {
        NSString *eosString=@"EOS";
        NSData *data=[eosString dataUsingEncoding:NSASCIIStringEncoding];
        [self.webSocket send:data];
    }
}

#pragma mark - Web Socket Delegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if([self.delegate respondsToSelector:@selector(webSocket:onReceiveMessage:)]){
        [self.delegate webSocket:webSocket onReceiveMessage:message];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    if([self.delegate respondsToSelector:@selector(webSocketOpen:) ]){
        [self.delegate webSocketOpen:webSocket];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    if([self.delegate respondsToSelector:@selector(webSocket:onFailWithError:)]){
        [self.delegate webSocket:webSocket onFailWithError:error];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    if([self.delegate respondsToSelector:@selector(webSocket:onCloseWithCode:reason:wasClean:)]){
        [self.delegate webSocket:webSocket onCloseWithCode:code reason:reason wasClean:wasClean];
    }
}
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"got some data: %lu", (unsigned long)pongPayload.length);
    if([self.delegate respondsToSelector:@selector(webSocket:onReceivePong:)]){
        [self.delegate webSocket:webSocket onReceivePong:pongPayload];
    }
}

-(void)dealloc{
    self.webSocket.delegate = nil;
    self.webSocket = nil;
}




@end
