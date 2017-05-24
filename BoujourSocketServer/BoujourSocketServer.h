//
//  BoujourSocketServer.h
//  BoujourSocketServer
//
//  Created by 张树青 on 2017/5/24.
//  Copyright © 2017年 zsq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoujourSocketServer : NSObject

+ (instancetype)shareInstance;

- (void)startWithName:(NSString *)name;
- (void)stop;
- (void)sendMessageToAll:(NSString *)message;
- (void)sendMessageToPhone:(NSString *)phoneNumber message:(NSString *)message;

@end
