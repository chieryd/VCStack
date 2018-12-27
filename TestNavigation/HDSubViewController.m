//
//  HDSubViewController.m
//  TestNavigation
//
//  Created by HanDong Wang on 2018/12/14.
//  Copyright © 2018 HanDong Wang. All rights reserved.
//

#import "HDSubViewController.h"
#import "HDVCStack.h"
#import "UIViewController+NavigationBar.h"

@interface HDSubViewController ()
@property (nonatomic, strong) HDDefaultNaviBar *naviBar;
@end

@implementation HDSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [button setTitle:@"点击回退" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 100)];
    [button1 setTitle:@"点击push" forState:UIControlStateNormal];
    button1.backgroundColor = [UIColor blueColor];
    [button1 addTarget:self action:@selector(clickButton2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 300, 300, 200)];
    scrollView.backgroundColor = [UIColor greenColor];
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = YES;
    scrollView.contentSize = CGSizeMake(300 * 3, 200);
    [self.view addSubview:scrollView];
    
    [self.view addSubview:self.naviBar];
}

- (void)clickButton {
    if (HDVCStack.shareInstance.viewControllers.count == 4) {
        [HDVCStack popToRootViewControllerWithAnimation:[HDVCStackAnimation defaultAnimation]];
    }
    else if (HDVCStack.shareInstance.viewControllers.count == 3) {
        [HDVCStack popToVCWithName:@"HDRootViewController" animation:[HDVCStackAnimation defaultAnimation]];
    }
    else if (HDVCStack.shareInstance.viewControllers.count == 5) {
        HDSubViewController *subViewController = [[HDSubViewController alloc] init];
        [HDVCStack popToVCWithName:@"HDRootViewController"
                         animation:[HDVCStackAnimation defaultAnimation]
                        thenPushTo:subViewController
                         animation:[HDVCStackAnimation defaultAnimation]];
    }
    else if (HDVCStack.shareInstance.viewControllers.count == 6) {
        HDSubViewController *subViewController = [[HDSubViewController alloc] init];
        [HDVCStack popToVCWithName:@"HDRootViewController"
                         animation:nil
                        thenPushTo:subViewController
                         animation:[HDVCStackAnimation defaultAnimation]];
    }
    else if (HDVCStack.shareInstance.viewControllers.count == 7) {
        HDSubViewController *subViewController = [[HDSubViewController alloc] init];
        [HDVCStack popToVCWithName:@"HDRootViewController"
                         animation:nil
                        thenPushTo:subViewController
                         animation:nil];
    }
    else {
        [HDVCStack popWithAnimation:[HDVCStackAnimation defaultAnimation]];
    }
}

- (void)clickButton2 {
    HDSubViewController *vc = [[HDSubViewController alloc] init];
    [HDVCStack pushto:vc animation:[HDVCStackAnimation defaultAnimation]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (HDDefaultNaviBar *)naviBar {
    if (!_naviBar) {
        _naviBar = [UIViewController defaultBar];
    }
    return _naviBar;
}

@end
