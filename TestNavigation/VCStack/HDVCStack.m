//
//  HDNavigationController.m
//  TestNavigation
//
//  Created by HanDong Wang on 2018/12/14.
//  Copyright © 2018 HanDong Wang. All rights reserved.
//

#import "HDVCStack.h"
#import "HDRootViewController.h"
#import "HDScreenInfo.h"
#import "HDVCStackPanGesture.h"
#import "HDVCStackPanProtocol.h"

@interface HDVCStack ()
@property (nonatomic, readwrite, strong) NSMutableArray *viewControllers;
@property (nonatomic, readwrite, strong) UIViewController *visibleViewController;
@property (nonatomic, readwrite, strong) UIViewController *rootViewController;
@end

@implementation HDVCStack

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static HDVCStack *__instance = nil;
    dispatch_once(&onceToken, ^{
        __instance = [[HDVCStack alloc] init];
    });
    return __instance;
}

- (void)initWithRootViewController:(UIViewController *)viewController {
    _rootViewController = viewController;
    self.visibleViewController = _rootViewController;
    [self.viewControllers addObject:viewController];
}

- (NSMutableArray *)viewControllers {
    if (!_viewControllers) {
        _viewControllers = [NSMutableArray new];
    }
    return _viewControllers;
}

// 模拟左滑手势的处理，如果用户实现了协议，且标明不使用左滑手势，则不增加手势选项，否则默认是增加的
+ (void)panGestureWithView:(UIViewController *)vc {
    if ([vc conformsToProtocol:@protocol(HDVCEnableDragBackProtocol)] &&
        [vc respondsToSelector:@selector(enableDrag)] &&
        [(UIViewController <HDVCEnableDragBackProtocol> *)vc enableDrag] == NO) {
        // 这里什么都不做
        return;
    }
    // 添加拖动手势的操作
    [[HDVCStackPanGesture shareInstance] pangestureWithView:vc.view completeHandle:^() {
        if ([HDVCStack.shareInstance.viewControllers count] > 1) {
            // 底部的vc
            UIViewController *bottomVC = HDVCStack.shareInstance.viewControllers[HDVCStack.shareInstance.viewControllers.count - 2];
            // 当前显示的vc
            UIViewController *currentVC = HDVCStack.shareInstance.visibleViewController;
            
            if (bottomVC && currentVC) {
                // 当前禁止任何手势
                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                
                [bottomVC viewWillAppear:true];
                [currentVC viewWillDisappear:true];
                [UIView animateWithDuration:0.34 animations:^{
                    currentVC.view.frame = CGRectMake(HDScreenInfo.width, 0, HDScreenInfo.width, HDScreenInfo.height);
                    bottomVC.view.frame = CGRectMake(0, 0, HDScreenInfo.width, HDScreenInfo.height);
                } completion:^(BOOL finished) {
                    if (finished) {
                        [currentVC.view removeFromSuperview];
                        [currentVC viewDidDisappear:true];
                        [bottomVC viewDidAppear:true];
                        HDVCStack.shareInstance.visibleViewController = bottomVC;
                        [[[HDVCStack shareInstance] viewControllers] removeLastObject];
                        // 手势禁用关闭
                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    }
                }];
            }
        }
    }];
}

+ (void)pushto:(UIViewController *)vc animation:(NSObject<HDVCStackAnimationProtocol> *)animation {
    // 添加手势处理
    [self panGestureWithView:vc];
    
    // 当前禁止任何手势
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [HDVCStack.shareInstance.viewControllers addObject:vc];
    [vc viewWillAppear:false];
    [HDVCStack.shareInstance.visibleViewController viewWillDisappear:false];
    [HDVCStack.shareInstance.visibleViewController.view addSubview:vc.view];
    
    
    if (animation) {
        // 动画开始
        [animation pushWithWillShowVC:vc currentVC:HDVCStack.shareInstance.visibleViewController completion:^(BOOL finished) {
            if (finished) {
                [HDVCStack.shareInstance.visibleViewController viewDidDisappear:true];
                [vc viewDidAppear:true];
                HDVCStack.shareInstance.visibleViewController =  vc;
                // 手势禁用关闭
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }
        }];
    }
    else {
        // 手势禁用关闭
        [HDVCStack.shareInstance.visibleViewController viewDidDisappear:false];
        [vc viewDidAppear:false];
        HDVCStack.shareInstance.visibleViewController =  vc;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    
}

// 提取出一些公共方法，减少代码的行数
+ (void)popToVC:(UIViewController *)popToVC
      animation:(NSObject<HDVCStackAnimationProtocol> *)animation
  willDismissVC:(UIViewController *)willDismissVC {
    [self popToVC:popToVC
        animation:animation
    willDismissVC:willDismissVC
popCompleteHandle:nil];
}

+ (void)popToVC:(UIViewController *)popToVC
      animation:(NSObject<HDVCStackAnimationProtocol> *)animation
  willDismissVC:(UIViewController *)willDismissVC
popCompleteHandle:(void (^)(BOOL))popCompletion {
    if (popToVC) {
        // 当前禁止任何手势
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        if (animation) {
            [popToVC viewWillAppear:true];
            [willDismissVC viewWillDisappear:true];
            [animation popWithWillShowVC:popToVC currentVC:willDismissVC
                              completion:^(BOOL finished) {
                                  if (finished) {
                                      [willDismissVC.view removeFromSuperview];
                                      [willDismissVC viewDidDisappear:true];
                                      [popToVC viewDidAppear:true];
                                      HDVCStack.shareInstance.visibleViewController = popToVC;
                                      // 手势禁用关闭
                                      [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                      // completion handle
                                      if (popCompletion) {
                                          popCompletion(finished);
                                      }
                                  }
                              }];
        }
        else {
            [popToVC viewWillAppear:false];
            [willDismissVC viewWillDisappear:false];
            [willDismissVC.view removeFromSuperview];
            [willDismissVC viewDidDisappear:false];
            [popToVC viewDidAppear:false];
            HDVCStack.shareInstance.visibleViewController = popToVC;
            // 手势禁用关闭
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            if (popCompletion) {
                popCompletion(YES);
            }
        }
    }
    else {
        if (popCompletion) {
            popCompletion(NO);
        }
    }
}

+ (void)popWithAnimation:(NSObject<HDVCStackAnimationProtocol> *)animation {
    if ([[HDVCStack shareInstance] viewControllers].count > 0) {
        [[[HDVCStack shareInstance] viewControllers] removeLastObject];
        UIViewController *willVisibleVC = [[HDVCStack shareInstance] viewControllers].lastObject;
        
        // 当前禁止任何手势
        [self popToVC:willVisibleVC animation:animation willDismissVC:HDVCStack.shareInstance.visibleViewController];
    }
}

+ (void)popToRootViewControllerWithAnimation:(NSObject<HDVCStackAnimationProtocol> *)animation {
    if ([[HDVCStack shareInstance] viewControllers].count > 0) {
        UIViewController *willVisibleVC = [[HDVCStack shareInstance] viewControllers].firstObject;
        
        // 将中间view全部删除
        for (NSInteger i = HDVCStack.shareInstance.viewControllers.count - 1; i > 0; i--) {
            if (i == 0) {
                break;
            }
            UIViewController *vc = HDVCStack.shareInstance.viewControllers[i];
            [vc.view removeFromSuperview];
            [HDVCStack.shareInstance.viewControllers removeObjectAtIndex:i];
        }
        
        // 已出当前已经添加上的view
        if (willVisibleVC) {
            [willVisibleVC.view addSubview:HDVCStack.shareInstance.visibleViewController.view];
        }
        
        // 当前禁止任何手势
        [self popToVC:willVisibleVC animation:animation willDismissVC:HDVCStack.shareInstance.visibleViewController];
    }
}

+ (UIViewController *)vcByName:(NSString *)vcName {
    if (HDVCStack.shareInstance.viewControllers.count > 0) {
        for (UIViewController *vc in HDVCStack.shareInstance.viewControllers) {
            if ([NSStringFromClass([vc class]) isEqualToString:vcName]) {
                return vc;
            }
        }
    }
    return nil;
}

+ (void)popToVCWithName:(NSString *)vcName
              animation:(NSObject<HDVCStackAnimationProtocol> *)popAnimation {
    if ([self vcByName:vcName]) {
        [self popTo:[self vcByName:vcName] animation:popAnimation popCompleteHandle:nil];
    }
}

+ (void)popTo:(UIViewController *)vc
    animation:(NSObject<HDVCStackAnimationProtocol> *)popAnimation
popCompleteHandle:(void (^)(BOOL))popCompletion {
    if (HDVCStack.shareInstance.viewControllers.count > 0 &&
        [HDVCStack.shareInstance.viewControllers containsObject:vc]) {
        UIViewController *willVisibleVC = vc;
        
        NSInteger willVisibleVCIndex = [HDVCStack.shareInstance.viewControllers indexOfObject:vc];
        
        // 将中间view全部删除
        for (NSInteger i = HDVCStack.shareInstance.viewControllers.count - 1; i > 0; i--) {
            if (i == willVisibleVCIndex) {
                break;
            }
            UIViewController *vc = HDVCStack.shareInstance.viewControllers[i];
            [vc.view removeFromSuperview];
            [HDVCStack.shareInstance.viewControllers removeObjectAtIndex:i];
        }
        
        // 已出当前已经添加上的view
        if (willVisibleVC) {
            [willVisibleVC.view addSubview:HDVCStack.shareInstance.visibleViewController.view];
        }
        
        // 当前禁止任何手势
        [self popToVC:willVisibleVC animation:popAnimation willDismissVC:HDVCStack.shareInstance.visibleViewController popCompleteHandle:popCompletion];
    }
    else {
        if (popCompletion) {
            popCompletion(NO);
        }
    }
}

+ (void)popToVCWithName:(NSString *)popVCName
              animation:(NSObject<HDVCStackAnimationProtocol> *)popAnimation
             thenPushTo:(UIViewController *)pushVC
              animation:(NSObject<HDVCStackAnimationProtocol> *)pushAnimation {
    if ([self vcByName:popVCName]) {
        [self popTo:[self vcByName:popVCName]
          animation:popAnimation
         thenPushTo:pushVC
          animation:pushAnimation];
    }
}

+ (void)popTo:(UIViewController *)popVC
    animation:(NSObject<HDVCStackAnimationProtocol> *)popAnimation
   thenPushTo:(UIViewController *)pushVC
    animation:(NSObject<HDVCStackAnimationProtocol> *)pushAnimation {
    [self popTo:popVC animation:popAnimation popCompleteHandle:^(BOOL finished) {
        if (finished) {
            [self pushto:pushVC animation:pushAnimation];
        }
    }];
}

@end
