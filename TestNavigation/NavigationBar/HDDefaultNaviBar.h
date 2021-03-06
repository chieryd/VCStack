//
//  HDDefaultNaviBar.h
//  TestNavigation
//
//  Created by HanDong Wang on 2018/12/18.
//  Copyright © 2018 HanDong Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDDefaultNaviBar : UIView
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIImage *backIcon;
@end

NS_ASSUME_NONNULL_END
