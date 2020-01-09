#import "RNShare.h"
#import <React/RCTImageLoader.h>

@implementation RNShare

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static RNShare *_instance;
    
    dispatch_once(&onceToken, ^{
        _instance = [[RNShare alloc] init];
    });
    
    return _instance;
}

- (NSArray *)supportedEvents {
    return @[@"WeChat_Resp"];
}

+ (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)aURL {
    
    return [WXApi handleOpenURL:aURL delegate:[RNShare sharedInstance]];
}

+ (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity {
    
    return [WXApi handleOpenUniversalLink:userActivity delegate:[RNShare sharedInstance]];
}

RCT_EXPORT_METHOD(isWXAppInstalled:(RCTResponseSenderBlock)callback) {
    callback(@[[NSNull null], @([WXApi isWXAppInstalled])]);
}

RCT_EXPORT_METHOD(registerApp:(NSString *)registerAppID) {
    [self registerWxApp:registerAppID withUniversalLink:@""];
}

RCT_EXPORT_METHOD(registerApp:(NSString *)registerAppID universalLink:(NSString *)universalLink) {
    [self registerWxApp:registerAppID withUniversalLink:universalLink];
}

- (void)registerWxApp:(NSString *)registerAppID withUniversalLink:(NSString *)universalLink {
    
    [WXApi registerApp:registerAppID universalLink:universalLink];
}

//分享到朋友圈
RCT_EXPORT_METHOD(shareToTimeline:(NSDictionary *)data callback:(RCTResponseSenderBlock)callback) {
    [self shareToWeixinWithData:data scene:WXSceneTimeline callback:callback];
}

//分享到好友
RCT_EXPORT_METHOD(shareToSession:(NSDictionary *)data callback:(RCTResponseSenderBlock)callback) {
    [self shareToWeixinWithData:data scene:WXSceneSession callback:callback];
}

- (void)shareToWeixinWithData:(NSDictionary *)aData thumbImage:(UIImage *)aThumbImage scene:(int)aScene callBack:(RCTResponseSenderBlock)callback {
    NSString *type = aData[RCTWXShareType];
    
    if ([type isEqualToString:RCTWXShareTypeText]) {
        NSString *text = aData[RCTWXShareDescription];
        [self shareToWeixinWithTextMessage:aScene Text:text callBack:callback];
    }else {
        NSString * title = aData[RCTWXShareTitle];
        NSString * description = aData[RCTWXShareDescription];
        NSString * mediaTagName = aData[@"mediaTagName"];
        NSString * messageAction = aData[@"messageAction"];
        NSString * messageExt = aData[@"messageExt"];
        
        if (type.length <= 0 || [type isEqualToString:RCTWXShareTypeNews]) {
            NSString * webpageUrl = aData[RCTWXShareWebPageUrl];
            if (webpageUrl.length <= 0) {
                callback(@[@"webpageUrl required"]);
                return;
            }
            
            WXWebpageObject* webpageObject = [WXWebpageObject object];
            webpageObject.webpageUrl = webpageUrl;
            
            [self shareToWeixinWithMediaMessage:aScene
                                          Title:title
                                    Description:description
                                         Object:webpageObject
                                     MessageExt:messageExt
                                  MessageAction:messageAction
                                     ThumbImage:aThumbImage
                                       MediaTag:mediaTagName
                                       callBack:callback];
            
        }else if ([type isEqualToString:RCTWXShareTypeAudio]) {
            WXMusicObject *musicObject = [WXMusicObject new];
            musicObject.musicUrl = aData[@"musicUrl"];
            musicObject.musicLowBandUrl = aData[@"musicLowBandUrl"];
            musicObject.musicDataUrl = aData[@"musicDataUrl"];
            musicObject.musicLowBandDataUrl = aData[@"musicLowBandDataUrl"];
            
            [self shareToWeixinWithMediaMessage:aScene
                                          Title:title
                                    Description:description
                                         Object:musicObject
                                     MessageExt:messageExt
                                  MessageAction:messageAction
                                     ThumbImage:aThumbImage
                                       MediaTag:mediaTagName
                                       callBack:callback];
            
        }else if ([type isEqualToString:RCTWXShareTypeVideo]) {
            WXVideoObject *videoObject = [WXVideoObject new];
            videoObject.videoUrl = aData[@"videoUrl"];
            videoObject.videoLowBandUrl = aData[@"videoLowBandUrl"];
            
            [self shareToWeixinWithMediaMessage:aScene
                                          Title:title
                                    Description:description
                                         Object:videoObject
                                     MessageExt:messageExt
                                  MessageAction:messageAction
                                     ThumbImage:aThumbImage
                                       MediaTag:mediaTagName
                                       callBack:callback];
            
        }else if ([type isEqualToString:RCTWXShareTypeImageUrl] ||
                   [type isEqualToString:RCTWXShareTypeImageFile] ||
                   [type isEqualToString:RCTWXShareTypeImageResource]) {
            NSURL *url = [NSURL URLWithString:aData[RCTWXShareImageUrl]];
            NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url];
            [self.bridge.imageLoader loadImageWithURLRequest:imageRequest callback:^(NSError *error, UIImage *image) {
                if (!image) {
                    callback(@[@"fail to load image resource"]);
                } else {
                    WXImageObject *imageObject = [WXImageObject object];
                    imageObject.imageData = UIImagePNGRepresentation(image);
                    
                    [self shareToWeixinWithMediaMessage:aScene
                                                  Title:title
                                            Description:description
                                                 Object:imageObject
                                             MessageExt:messageExt
                                          MessageAction:messageAction
                                             ThumbImage:aThumbImage
                                               MediaTag:mediaTagName
                                               callBack:callback];
                    
                }
            }];
        }else if ([type isEqualToString:RCTWXShareTypeFile]) {
            NSString * filePath = aData[@"filePath"];
            NSString * fileExtension = aData[@"fileExtension"];
            
            WXFileObject *fileObject = [WXFileObject object];
            fileObject.fileData = [NSData dataWithContentsOfFile:filePath];
            fileObject.fileExtension = fileExtension;
            
            [self shareToWeixinWithMediaMessage:aScene
                                          Title:title
                                    Description:description
                                         Object:fileObject
                                     MessageExt:messageExt
                                  MessageAction:messageAction
                                     ThumbImage:aThumbImage
                                       MediaTag:mediaTagName
                                       callBack:callback];
            
        } else {
            callback(@[@"message type unsupported"]);
        }
    }
}

- (void)shareToWeixinWithData:(NSDictionary *)aData scene:(int)aScene callback:(RCTResponseSenderBlock)aCallBack {
    NSString *imageUrl = aData[RCTWXShareTypeThumbImageUrl];
    if (imageUrl.length && self.bridge.imageLoader) {
        NSURL *url = [NSURL URLWithString:imageUrl];
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url];
        [self.bridge.imageLoader loadImageWithURLRequest:imageRequest size:CGSizeMake(100, 100) scale:1 clipped:NO resizeMode:RCTResizeModeStretch progressBlock:nil partialLoadBlock:nil
                                     completionBlock:^(NSError *error, UIImage *image) {
                                         [self shareToWeixinWithData:aData thumbImage:image scene:aScene callBack:aCallBack];
                                     }];
    }else {
        [self shareToWeixinWithData:aData thumbImage:nil scene:aScene callBack:aCallBack];
    }
    
}

- (void)shareToWeixinWithTextMessage:(int)aScene Text:(NSString *)text callBack:(RCTResponseSenderBlock)callback {
    SendMessageToWXReq* req = [SendMessageToWXReq new];
    req.bText = YES;
    req.scene = aScene;
    req.text = text;
    
    [WXApi sendReq:req completion:^(BOOL success) {
        
    }];
}

- (void)shareToWeixinWithMediaMessage:(int)aScene
                                Title:(NSString *)title
                          Description:(NSString *)description
                               Object:(id)mediaObject
                           MessageExt:(NSString *)messageExt
                        MessageAction:(NSString *)action
                           ThumbImage:(UIImage *)thumbImage
                             MediaTag:(NSString *)tagName
                             callBack:(RCTResponseSenderBlock)callback {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.mediaObject = mediaObject;
    message.messageExt = messageExt;
    message.messageAction = action;
    message.mediaTagName = tagName;
    [message setThumbImage:thumbImage];
    
    SendMessageToWXReq* req = [SendMessageToWXReq new];
    req.bText = NO;
    req.scene = aScene;
    req.message = message;
    
    [WXApi sendReq:req completion:^(BOOL success) {

    }];
}

#pragma mark - wx WXApiDelegate
-(void)onReq:(BaseReq*)req {
    // TODO(Yorkie)
}

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp *r = (SendMessageToWXResp *)resp;
        
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        body[@"lang"] = r.lang;
        body[@"country"] = r.country;
        body[@"type"] = @"SendMessageToWX.Resp";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sendEventWithName:RCTWXEventName body:body];
        });
    }
}

@end
  
