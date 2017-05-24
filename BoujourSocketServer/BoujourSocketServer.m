//
//  BoujourSocketServer.m
//  BoujourSocketServer
//
//  Created by 张树青 on 2017/5/24.
//  Copyright © 2017年 zsq. All rights reserved.
//

#import "GCDAsyncSocket.h"

#import "BoujourSocketServer.h"

@interface BoujourSocketServer ()<NSNetServiceDelegate, GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
@property (nonatomic, assign) UInt16 port;
@property (nonatomic, copy) NSString *serverName;
@property (nonatomic, strong) dispatch_queue_t serverQueue;
@property (nonatomic, strong) NSNetService *netService;
@property (nonatomic, strong) NSMutableArray *clintSockets;
@property (nonatomic, strong) NSDate *sendDate;

@end


@implementation BoujourSocketServer

+ (instancetype)shareInstance{
    static BoujourSocketServer *_socketServer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _socketServer = [[BoujourSocketServer alloc] init];
        _socketServer.serverQueue = dispatch_queue_create("BoujourSocketServer", NULL);
        _socketServer.clintSockets = [NSMutableArray array];
    });
    return _socketServer;
}

- (void)startWithName:(NSString *)name{
    
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.serverQueue];
   // self.port = [self.asyncSocket localPort];
    self.port = 5566;
    self.serverName = name;
    //@"_chatty._tcp." inDomain:@""];
    self.netService = [[NSNetService alloc] initWithDomain:@"local." type:@"_chatty._tcp." name:name port:self.port];
    [self.netService scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSRunLoopCommonModes];
    self.netService.delegate = self;
    [self.netService publish];
}

- (void)stop{
    for (GCDAsyncSocket *socket in self.clintSockets) {
        [socket setDelegate:nil];
        [socket disconnect];
    }
    [self.clintSockets removeAllObjects];
    
    self.asyncSocket.delegate = nil;
    [self.asyncSocket disconnect];
    
    [self.netService stop];
    self.netService = nil;

}

- (void)sendMessageToAll:(NSString *)message{
    self.sendDate = [NSDate date];
    for (GCDAsyncSocket *socket in self.clintSockets) {
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        [socket writeData:data withTimeout:-1 tag:100];
    }
}

- (void)sendMessageToPhone:(NSString *)phoneNumber message:(NSString *)message{
//    GCDAsyncSocket *socket = [self.clintSockets objectForKey:phoneNumber];
//    if (socket) {
//        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
//        [socket writeData:data withTimeout:5 tag:300];
//    }
    
}

#pragma mark - NSNetService 代理

- (void)netServiceDidPublish:(NSNetService *)sender{
    NSLog(@"Bonjour服务发布成功: %@", sender.name);
    
    //打开端口监听
    NSError *error = nil;
    [self.asyncSocket acceptOnPort:self.port error:&error];
    if (error) {
        NSLog(@"服务端口开启失败:%@", error);
    } else {
        NSLog(@"服务端口开启成功");
    }
}
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary<NSString *, NSNumber *> *)errorDict{
    NSLog(@"Bonjour服务发布失败: %@,\n error:%@", sender.name, errorDict);
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *, NSNumber *> *)errorDict{
    NSLog(@"Bonjour服务解析失败: %@,\n error:%@", sender.name, errorDict);
}

- (void)netServiceDidStop:(NSNetService *)sender{
    NSLog(@"Bonjour服务停止: %@", sender.name);
}

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream NS_AVAILABLE(10_9, 7_0){
    NSLog(@"开始访问字节流");
}


#pragma mark - GCDAsyncSocket 代理

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    NSLog(@"发现新的连接%@", newSocket.userData);
    newSocket.delegate = self;
    [newSocket readDataWithTimeout:-1 tag:100];
    [self.clintSockets addObject:newSocket];
    [[NSRunLoop currentRunLoop] run];
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"socket连接到host: %@", host);
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"BonjourSocket收到消息: %@", str);
    NSDate *receiveDate = [NSDate date];
    double t = [receiveDate timeIntervalSinceDate:self.sendDate]/2.0 * 1000;
    NSLog(@"%f", t);
}


- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    [sock readDataWithTimeout:-1 tag:tag];
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock{
    NSLog(@"读字节流关闭");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    NSLog(@"socket断开连接: %@", sock.userData);
    
}

@end
