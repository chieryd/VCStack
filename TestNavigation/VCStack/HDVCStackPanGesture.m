//
//  HDVCStackPanGesture.m
//  TestNavigation
//
//  Created by HanDong Wang on 2018/12/17.
//  Copyright © 2018 HanDong Wang. All rights reserved.
//

#import "HDVCStackPanGesture.h"
#import "HDScreenInfo.h"
#import "HDVCStack.h"

@interface HDVCStackPanGesture ()

/**
 滑动开始时，遮挡底部的View,禁止用户手势操作
 */
@property (nonatomic, strong) UIView *maskView;

@end

@implementation HDVCStackPanGesture

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static HDVCStackPanGesture *__instance;
    dispatch_once(&onceToken, ^{
        __instance = [HDVCStackPanGesture new];
    });
    return __instance;
}

- (void)pangestureWithView:(UIView *)view completeHandle:(void (^)(void))completeHandle {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    self.successBlock = completeHandle;
    [view addGestureRecognizer:panGesture];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    // 当前正在拖动的view
    UIView *view = pan.view;
    // 即将要显示的View
    if (HDVCStack.shareInstance.viewControllers.count > 1) {
        UIViewController *bottomViewController = HDVCStack.shareInstance.viewControllers[HDVCStack.shareInstance.viewControllers.count - 2];
        UIView *bottomView = bottomViewController.view;
        
        // 一些标记值
        static CGPoint startViewCenter;
        static CGPoint startBottomViewCenter;
        static BOOL continueFlag = YES;
        
        if (view && bottomView) {
            // 拖动开始的检测
            if (pan.state == UIGestureRecognizerStateBegan) {
                // 拖动开始时View的frame需要先发生变化，保证和系统的UI风格统一
                bottomView.frame = CGRectMake(- HDScreenInfo.width / 3.0, 0, HDScreenInfo.width, HDScreenInfo.height);
                view.frame = CGRectMake(HDScreenInfo.width / 3.0, 0, HDScreenInfo.width, HDScreenInfo.height);
                // 检测当前的拖动的位置是否在合适的点，当前确立，view的左边1/3z位置可以作为触发的初始点
                CGPoint startPoint = [pan locationInView:view];
                if (startPoint.x > (view.frame.size.width / 3.0)) {
                    continueFlag = NO;
                }
                else {
                    continueFlag = YES;
                    // 将底部的View遮罩，避免手势点击造成其他问题
                    [bottomView addSubview:self.maskView];
                }
                startViewCenter = view.center;
                startBottomViewCenter = bottomView.center;
            }
            else if (pan.state == UIGestureRecognizerStateChanged) {
                if (continueFlag) {
                    // 拿到对一个的偏移量
                    CGPoint transition = [pan translationInView:view];
                    view.center = CGPointMake(startViewCenter.x + transition.x / 3.0 * 2.0, startViewCenter.y);
                    bottomView.center = CGPointMake(startBottomViewCenter.x + transition.x / 3.0, startBottomViewCenter.y);
                }
            }
            else if (pan.state == UIGestureRecognizerStateEnded) {
                if (continueFlag) {
                    // 将遮罩view去除
                    if (self.maskView.superview != nil) {
                        [self.maskView removeFromSuperview];
                    }
                    // 开始收尾动画
                    if (view.center.x > (view.frame.size.width / 6.0 * 7.0)) {
                        if (self.successBlock) {
                            self.successBlock();
                        }
                    }
                    else {
                        // 禁止用户操作
                        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                        // 还原到初始的位置
                        [UIView animateWithDuration:0.34 animations:^{
                            view.frame = CGRectMake(HDScreenInfo.width / 3.0, 0, HDScreenInfo.width, HDScreenInfo.height);
                            bottomView.frame = CGRectMake(- HDScreenInfo.width / 3.0, 0, HDScreenInfo.width, HDScreenInfo.height);
                        } completion:^(BOOL finished) {
                            if (finished) {
                                // 解开用户手势操作
                                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                // 还原对象的位置
                                view.frame = CGRectMake(0, 0, HDScreenInfo.width, HDScreenInfo.height);
                                bottomView.frame = CGRectMake(0, 0, HDScreenInfo.width, HDScreenInfo.height);
                            }
                        }];
                    }
                }
            }
        }
    }
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDScreenInfo.width, HDScreenInfo.height)];
        _maskView.backgroundColor = [UIColor clearColor];
    }
    return _maskView;
}

@end
