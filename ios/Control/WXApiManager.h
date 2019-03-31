
#import <Foundation/Foundation.h>
#import "WXApi.h"

typedef void(^onRespFunction)(NSArray *resultDict);

@interface WXApiManager : NSObject<WXApiDelegate>

+ (instancetype)sharedManager;

- (void)setRespFunction:(onRespFunction)respFunction;

@end
