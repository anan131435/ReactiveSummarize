//
//  ViewController.m
//  ReactiveCocoaLearn
//
//  Created by 韩志峰 on 2019/3/4.
//  Copyright © 2019 韩志峰. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "FlagItem.h"
@interface ViewController ()
@property (nonatomic, strong) RACCommand  *command;
@end
/*
 RACSignal:信号类，一般表示将来有数据传递，只要数据改变，信号内部接收到数据，就会马上发出数据，他本身不具备发送信号的能力，而是交给内部的订阅者去发出。
 默认一个信号都是冷信号，就是值改变了也不会触发，只有订阅了这个信号，这个信号才能变成热信号，值改变了才会触发。
 如何订阅信号：调用subscribeNext才能订阅
 
 RACSubscriber 表示订阅者，用于发送信号，这是一个协议，只要遵守这个协议，并且实现方法才能成为订阅者。
 RACDisposable 用于取消订阅或者清理资源，当信号发送完成或者发生错误的时候，就会自动触发他。使用场景： 不想监听某个信号时，可以通过他主动取消订阅信号。
 RACSubject 信号提供者，自己既可以充当信号，又能发送信号
 RACReplaySubject ：重复提供信号类， 继承于 RACSubject
 RACReplaySubject 和 RACSubject 的区别：
 RACReplaySubject可以先发送信号，后订阅信号。
 使用场景：如果一个信号每被订阅一次就需要把之前的值重复发送一遍，使用 RACReplaySubject
 使用场景二： 可以设置capacity的数量来限制缓存的value的数量，即只缓存最新的几个值。
 RACSubject可以代替代理，把回调先订阅上，然后发送信号的时候走回调代理。
 */
/*
 RACTuple 元组类：
 RACSequence： RAC中的集合类，用于代替array和dictionary，快速遍历数组和字典
 RACCommand RAC中处理事件的类，可以把事件如何处理，事件中的数据如何传递，包装到这个类中，很方便的监控事件的执行过程。
 
 */
/*
 
 
 */
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self createSignal];
    [self creatSubject];
}
- (void)createSignal {
    //1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //block调用时刻：每当有订阅者订阅信号，就会调用block
        //3.发送信号
        [subscriber sendNext:@1];
        //如果不再发送数据，最好发送信号完成，内部会调用[RACDisposable disposable]
        [subscriber sendCompleted];
        return  [RACDisposable disposableWithBlock:^{
            NSLog(@"信号被销毁");
        }];
        
    }];
    //2.订阅信号，订阅信号才能激活信号
    [signal subscribeNext:^(id x) {
        //block调用时刻：每当有信号发出，就会调用block
        NSLog(@"接收到数据%@",x);
    }];
    [signal subscribeNext:^(id x) {
        //block调用时刻：每当有信号发出，就会调用block
        NSLog(@"第二个订阅者接收到数据%@",x);
    }];
    

}
- (void)creatSubject{
    RACReplaySubject *subject = [RACReplaySubject subject];
    [subject subscribeNext:^(id x) {
        NSLog(@"第一个订阅者%@",x);
    }];
    [subject subscribeNext:^(id x) {
        NSLog(@"第二个订阅者%@",x);
    }];
    [subject sendNext:@"1"];
    [subject subscribeNext:^(id x) {
        NSLog(@"第三个订阅者%@",x);
    }];
}

- (void)qequenceTest{
    NSArray *number = @[@1,@2,@3,@4];
    [number.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    NSDictionary *dict = @{@"name":@"han",@"age":@"80"};
    [dict.rac_sequence.signal subscribeNext:^(RACTuple *x) {
        RACTupleUnpack(NSString *key,NSString *value) = x;
        NSLog(@"%@-%@",key,value);
    }];
    NSArray *flagls = [[number.rac_sequence map:^id(id value) {
        return [FlagItem flagWithDict:value];
    }] array];
    
}
- (void)racCommandTest{
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"执行命令");
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"请求数据"];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    //强引用命令，不要被销毁，否则接收不到数据
    self.command = command;
    //订阅RACCommand中的信号
    [command.executionSignals subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
}
@end
