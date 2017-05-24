//
//  ViewController.m
//  BoujourSocketServer
//
//  Created by 张树青 on 2017/5/24.
//  Copyright © 2017年 zsq. All rights reserved.
//

#import "ViewController.h"
#import "BoujourSocketServer.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textfield;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)sendMessage:(id)sender {
    [[BoujourSocketServer shareInstance] sendMessageToAll:self.textfield.text];
}
- (IBAction)start:(id)sender {
    [[BoujourSocketServer shareInstance] startWithName:@"zhangsan"];
}

- (IBAction)stop:(id)sender {
    [[BoujourSocketServer shareInstance] stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
