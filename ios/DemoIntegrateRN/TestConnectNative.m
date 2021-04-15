#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_REMAP_MODULE(TestConnectNative, TestConnectNativeModule, NSObject)


RCT_EXTERN_METHOD(goToKoreChatViewController: (nonnull NSNumber *)reactTag)
RCT_EXTERN_METHOD(initialize: (NSString *)bot_id bot_name:(NSString *)bot_name client_id:(NSString *)client_id client_secret:(NSString *)client_secret identity:(NSString *)identity)

@end
