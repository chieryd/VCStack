//
//  HDVCStackPanGesture.h
//  TestNavigation
//
//  Created by HanDong Wang on 2018/12/17.
//  Copyright © 2018 HanDong Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HDViewPanGestureBlock) (void);
@interface HDVCStackPanGesture : NSObject
@property (nonatomic, copy) HDViewPanGestureBlock successBlock;
+ (instancetype)shareInstance;
- (void)pangestureWithView:(UIView *)view completeHandle:(void(^)(void))completeHandle;
@end

NS_ASSUME_NONNULL_END
