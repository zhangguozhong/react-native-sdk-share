//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import "WXApiManager.h"

@interface WXApiManager ()

@property (nonatomic, copy) onRespFunction respFunction;

@end

@implementation WXApiManager

#pragma mark - LifeCycle
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

- (void)setRespFunction:(onRespFunction)respFunction {
    self.respFunction = respFunction;
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp *r = (SendMessageToWXResp *)resp;
        
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        body[@"lang"] = r.lang;
        body[@"country"] =r.country;
        body[@"type"] = @"SendMessageToWX.Resp";
        
        if (self.respFunction) {
            self.respFunction(r.errCode == WXSuccess ? @[[NSNull null]] : @[body]);
        }
    } else if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *r = (PayResp *)resp;
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        body[@"type"] = @(r.type);
        body[@"returnKey"] =r.returnKey;
        body[@"type"] = @"PayReq.Resp";
        
        if (self.respFunction) {
            self.respFunction(r.errCode == WXSuccess ? @[[NSNull null]] : @[body]);
        }
    }
}

@end
