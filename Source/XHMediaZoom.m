//
//  XHMediaZoom.m
//  XHMediaZoom
//
//  Created by 曾 宪华 on 13-12-14.
//  Copyright (c) 2013年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507. All rights reserved.
//

#import "XHMediaZoom.h"

@interface XHMediaZoom ()

// aniamtion
@property (nonatomic, assign) NSTimeInterval        animationTime;

// UI
@property (nonatomic, strong) UIView                * backgroundView;
@property (nonatomic, strong) UIImageView           * imageView;
@property (nonatomic, weak  ) UIImageView           * originalImageView;


@end

@implementation XHMediaZoom
{
    BOOL _useBlurEffect;
}

#pragma mark -
#pragma mark - Views controls

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.center = CGPointMake(CGRectGetWidth(self.imageView.frame) / 2.0, CGRectGetHeight(self.imageView.frame) / 2.0);
    }
    return _activityIndicatorView;
}

- (UIView *)backgroundView
{
    if (_backgroundView) return _backgroundView;
    
    if (_useBlurEffect) {
        UINavigationBar *blurView = [[UINavigationBar alloc] initWithFrame:self.frame];
        blurView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        blurView.barTintColor = [UIColor blackColor];
        blurView.alpha = 0.0;
        _backgroundView = blurView;
    } else {
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        [_backgroundView setBackgroundColor:[UIColor blackColor]];
        [_backgroundView setAlpha:0.0];
    }
    
    return _backgroundView;
}

- (UIImageView *)imageView
{
    if (_imageView) return _imageView;
    
    _imageView = [[UIImageView alloc] initWithFrame:self.initMediaFrame];
    _imageView.clipsToBounds = YES;
    [_imageView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];
    [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    
    return _imageView;
}

- (CGRect)initMediaFrame
{
    CGPoint location = [self convertPoint:CGPointMake(0, 0) fromView:self.originalImageView];
    CGRect frame = CGRectMake(location.x, location.y, self.originalImageView.bounds.size.width, self.originalImageView.bounds.size.height);
    return frame;
}

- (void)_resetActivityIndicatorView {
    if (!_activityIndicatorView)
        return;
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
}


#pragma mark - Life cycle

- (id)initWithAnimationTime:(NSTimeInterval)duration
                      imageView:(UIImageView *)imageView
{
    return [self initWithAnimationTime:duration imageView:imageView blurEffect:NO];
}

- (id)initWithAnimationTime:(NSTimeInterval)duration
                      imageView:(UIImageView *)imageView
                 blurEffect:(BOOL)useBlur
{
    self = [super initWithFrame:[self currentFrame:[[UIApplication sharedApplication] statusBarOrientation]]];
    if (self) {
        _useBlurEffect = useBlur && !SYSTEM_VERSION_iOS_6;
        
        self.animationTime = duration;
        self.originalImageView = imageView;
        self.maxAlpha = 1.0;
        [self.imageView setImage:imageView.image];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)]];
        [self addSubview:self.backgroundView];
        [self addSubview:self.imageView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (SYSTEM_VERSION_iOS_6) {
        self.backgroundView.backgroundColor = backgroundColor;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    } else {
        if ([self.backgroundView isKindOfClass:[UINavigationBar class]]) {
            ((UINavigationBar *) self.backgroundView).barTintColor = backgroundColor;
        } else if ([self.backgroundView isKindOfClass:[UIView class]]) {
            self.backgroundView.backgroundColor = backgroundColor;
        }
#endif
    }
}

- (void)dealloc
{
    self.mediaURL = nil;
    self.imageView = nil;
    
    self.didShowHandler = nil;
    self.didDismissHandler = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public api

- (void)setImage:(UIImage *)image
{
    [self.imageView setImage:image];
}

- (void)setImageUrl:(NSURL *)imageUrl customUICallback:(XHCustomImageViewLoadURLCallbackHandler)callBack {
    XHMediaZoom * __weak weakSelf = self;
    if (callBack) {
        callBack(imageUrl, weakSelf.imageView);
    } else {
        [self.imageView addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
        dispatch_async(dispatch_queue_create("down load Image", NULL), ^{
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageUrl];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _resetActivityIndicatorView];
                if (image) {
                    NSLog(@"下载图片成功");
                    [weakSelf.imageView setImage:image];
                } else {
                    NSLog(@"下载图片失败");
                }
            });
        });
    }
}

- (BOOL)isFileURL {
    return self.mediaURL.isFileURL;
}

- (void)refreshMediaURL:(NSURL *)mediaURL {
    self.mediaURL = mediaURL;
}

- (void)show
{
    [self showWithDidShowHandler:nil didDismissHandler:nil];
}

- (void)showWithDidDismissHandler:(XHMediaZoomDidDismiss)didDismissHandler {
    [self showWithDidShowHandler:nil didDismissHandler:didDismissHandler];
}

- (void)showWithDidShowHandler:(XHMediaZoomDidShow)didShowHandler {
    [self showWithDidShowHandler:didShowHandler didDismissHandler:nil];
}

- (void)showWithDidShowHandler:(XHMediaZoomDidShow)didShowHandler didDismissHandler:(XHMediaZoomDidDismiss)didDismissHandler {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    self.frame = [self currentFrame:[[UIApplication sharedApplication] statusBarOrientation]];
    self.backgroundView.frame = [self currentFrame:[[UIApplication sharedApplication] statusBarOrientation]];
    self.imageView.frame = [self initMediaFrame];
    self.didShowHandler = [didShowHandler copy];
    self.didDismissHandler = [didDismissHandler copy];
    
    XHMediaZoom * __weak weakSelf = self;
    [UIView animateWithDuration:self.animationTime
                     animations:^{
                         weakSelf.imageView.frame = [weakSelf imageFrame];
                         [weakSelf.backgroundView setAlpha:weakSelf.maxAlpha];
                     }
                     completion:^(BOOL finished) {
                         if (finished){
                             [self showAnimationDidFinish];
                         }
                     }
     ];
}

-(void)showAnimationDidFinish
{
    // do something in the base class
    if (self.didShowHandler)
        self.didShowHandler();
}

-(void)willHandleSingleTap
{
    // do something in the base class
    [self _resetActivityIndicatorView];
}

#pragma mark - Auxiliary functions

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self willHandleSingleTap];
    XHMediaZoom * __weak weakSelf = self;
    
    [UIView animateWithDuration:self.animationTime
                     animations:^{
                         // Resize the image view to fill the view frame
                         weakSelf.imageView.frame = weakSelf.initMediaFrame;
                         [weakSelf.backgroundView setAlpha:0.0];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             if (self.didDismissHandler) {
                                 self.didDismissHandler();
                             }
                             [self removeFromSuperview];
                         }
                     }
     ];
}

- (CGRect)currentFrame:(UIInterfaceOrientation)orientation
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    float statusBarHeight = 0;
    
    if (SYSTEM_VERSION_iOS_6 && ![UIApplication sharedApplication].statusBarHidden) {
        statusBarHeight = 20;
    }
    if (UIInterfaceOrientationIsLandscape(orientation)){
        return CGRectMake(0, 0, screenSize.height, screenSize.width - statusBarHeight);
    }
    return CGRectMake(0, 0, screenSize.width, screenSize.height - statusBarHeight);
}

- (CGRect)imageFrame
{
    CGSize size = self.bounds.size;
    CGSize imageSize = self.imageView.image.size;
    float ratio = fminf(size.height / imageSize.height, size.width / imageSize.width);
    
    float imageViewWidth = imageSize.width * ratio;
    float imageViewHeight = imageSize.height * ratio;
    
    return CGRectMake((self.frame.size.width - imageViewWidth) * 0.5f, (self.frame.size.height - imageViewHeight) * 0.5f, imageViewWidth, imageViewHeight);
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight || orientation == UIDeviceOrientationPortrait) {
        self.frame = [self currentFrame:(UIInterfaceOrientation)orientation];
        self.backgroundView.frame = [self currentFrame:(UIInterfaceOrientation)orientation];
        self.imageView.frame = [self imageFrame];
    }
}

@end
