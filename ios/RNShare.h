
#import <React/RCTBridgeModule.h>
#import <UIKit/UIKit.h>
#import <React/RCTEventEmitter.h>
#import "WXApi.h"

#define RCTWXShareTypeNews @"news"
#define RCTWXShareTypeThumbImageUrl @"thumbImage"
#define RCTWXShareTypeImageUrl @"imageUrl"
#define RCTWXShareTypeImageFile @"imageFile"
#define RCTWXShareTypeImageResource @"imageResource"
#define RCTWXShareTypeText @"text"
#define RCTWXShareTypeVideo @"video"
#define RCTWXShareTypeAudio @"audio"
#define RCTWXShareTypeFile @"file"

#define RCTWXShareType @"type"
#define RCTWXShareTitle @"title"
#define RCTWXShareDescription @"description"
#define RCTWXShareWebPageUrl @"webPageUrl"
#define RCTWXShareImageUrl @"imageUrl"

#define RCTWXEventName @"WeChat_Resp"

@interface RNShare : RCTEventEmitter <RCTBridgeModule,WXApiDelegate>

+ (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)aURL;

+ (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity;

@end
  
