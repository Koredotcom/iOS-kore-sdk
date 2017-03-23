//
//  KREWebSocket.h
//  KoreApp
//
//  Created by developer@kore.com on 9/1/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

#import <SocketRocket/SRWebSocket.h>

@protocol KREWebSocketDelegate <NSObject>

@optional
- (void) webSocketOpen:(SRWebSocket *)webSocket;
- (void) webSocket:(SRWebSocket *)webSocket onFailWithError:(NSError *)error;
- (void) webSocket:(SRWebSocket *)webSocket onCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void) webSocket:(SRWebSocket *)webSocket onReceivePong:(NSData *)pongPayload;
- (void) webSocket:(SRWebSocket *)webSocket onReceiveMessage:(id) message;

@end

@interface KREWebSocket : NSObject<SRWebSocketDelegate>
{
    
}

@property (nonatomic, strong) SRWebSocket * webSocket;
@property (weak, nonatomic) id<KREWebSocketDelegate> delegate;


- (id) initWithURLString:(NSString*)strWebSocketUrl;
- (void)connect;
- (void)close;
- (void)sendData:(NSData*) data;
- (void)sendEndOFSpeechMarker;

@end
