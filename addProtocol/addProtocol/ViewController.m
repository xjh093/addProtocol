//
//  ViewController.m
//  addProtocol
//
//  Created by HaoCold on 2020/9/9.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/runtime.h>

@protocol YourProtocol <JSExport>
- (void)bar;
@end

@protocol HerProtocol <JSExport>
- (void)foobar;
@end


@interface ViewController ()<YourProtocol,HerProtocol>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Protocol *pro = objc_allocateProtocol("MyProtocol");
    protocol_addMethodDescription(pro, sel_registerName("foo"), "v@:", YES, YES);

    Protocol *p1 = objc_getProtocol("JSExport");
    protocol_addProtocol(pro, p1);
    
    class_addProtocol([self class], pro);
    
    objc_registerProtocol(pro);
    
    BOOL isConform1 = protocol_conformsToProtocol(pro, p1);
    NSLog(@"isConform = %d",isConform1);
    
    struct objc_method_description method = protocol_getMethodDescription(pro, NSSelectorFromString(@"foo"), "v@:", YES);
    NSLog(@"name:%@",NSStringFromSelector(method.name));
    NSLog(@"type:%s",method.types);
    
    BOOL isConform2 = class_conformsToProtocol([self class], pro);
    NSLog(@"isConform = %d",isConform2);
}

- (void)foo
{
    NSLog(@"invoke foo");
}

- (void)bar
{
    NSLog(@"invoke bar");
}

- (void)foobar
{
    NSLog(@"invoke foobar");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s",__func__);
    
    unsigned int count;
    __unsafe_unretained Protocol **lists = class_copyProtocolList([self class], &count);
    
    for (int i = 0; i <count; i++) {
        Protocol* protocol = lists[i];
        BOOL isConform1 = protocol_conformsToProtocol(protocol, objc_getProtocol("JSExport"));
        NSLog(@"%s conforms JSExport: %@",protocol_getName(protocol), @(isConform1));
    }
    
    JSVirtualMachine *vm = [[JSVirtualMachine alloc] init];
    JSContext *context = [[JSContext alloc] initWithVirtualMachine:vm];
    [context setObject:self forKeyedSubscript:@"vc"];
    JSValue *val = [context evaluateScript:@"vc.foo();"];
    NSLog(@"val1:%@",val);
    {
    JSValue *val = [context evaluateScript:@"vc.bar();"];
    NSLog(@"val2:%@",val);
    }
    {
    JSValue *val = [context evaluateScript:@"vc.foobar();"];
    NSLog(@"val3:%@",val);
    }
    context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"00:%@,%@",context,exception);
    };
}

@end
