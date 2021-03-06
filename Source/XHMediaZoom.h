//
//  XHMediaZoom.h
//  XHMediaZoom
//
//  Created by 曾 宪华 on 13-12-14.
//  Copyright (c) 2013年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define SYSTEM_VERSION_iOS_6 (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)

@class XHMediaZoom;

typedef void(^XHMediaZoomDidDismiss)();
typedef void(^XHMediaZoomDidShow)();

typedef void(^XHCustomImageViewLoadURLCallbackHandler)(NSURL *imageURL, UIImageView *disPlayImageView);

@interface XHMediaZoom : UIView

- (id)initWithAnimationTime:(NSTimeInterval)duration
                      imageView:(UIImageView *)imageView;

- (id)initWithAnimationTime:(NSTimeInterval)duration
                      imageView:(UIImageView *)imageView
                 blurEffect:(BOOL)useBlur;

@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, readonly)  UIImageView * imageView;
@property (nonatomic, assign) CGFloat maxAlpha;

// block
@property (nonatomic, copy  ) XHMediaZoomDidDismiss didDismissHandler;
@property (nonatomic, copy  ) XHMediaZoomDidShow    didShowHandler;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
- (void)_resetActivityIndicatorView;

- (void)setImage:(UIImage *)image;
- (void)setImageUrl:(NSURL *)imageUrl customUICallback:(XHCustomImageViewLoadURLCallbackHandler)callBack;

- (void)refreshMediaURL:(NSURL *)mediaURL;
- (BOOL)isFileURL;

- (void)show;
- (void)showWithDidShowHandler:(XHMediaZoomDidShow)didShowHandler;
- (void)showWithDidDismissHandler:(XHMediaZoomDidDismiss)didDismissHandler;
- (void)showWithDidShowHandler:(XHMediaZoomDidShow)didShowHandler didDismissHandler:(XHMediaZoomDidDismiss)didDismissHandler;

@end

/////////////////////////////////////////////////////////
// Protected functions

@interface XHMediaZoom ()

- (void)showAnimationDidFinish;
- (void)willHandleSingleTap;
- (void)deviceOrientationDidChange:(NSNotification *)notification;

@end

/////////////////////////////////////////////////////////
