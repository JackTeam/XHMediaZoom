//
//  ViewController.m
//  XHMediaZoom
//
//  Created by 曾 宪华 on 13-12-14.
//  Copyright (c) 2013年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507. All rights reserved.
//

#import "ViewController.h"
#import "XHMediaZoom.h"
#import "XHVideoZoom.h"
#import "XHAudioZoom.h"

@interface ViewController ()
@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) UISwitch *urlStringSwitch;
@property (strong, nonatomic) UILabel *tipsLabel;

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) XHMediaZoom *imageZoomView;

@property (strong, nonatomic) UIImageView *videoImageView;
@property (strong, nonatomic) XHVideoZoom *videoZoomView;

@property (strong, nonatomic) UIImageView *audioImageView;
@property (strong, nonatomic) XHAudioZoom *audioZoomView;
@end

@implementation ViewController

#pragma mark - switch

- (UISwitch *)urlStringSwitch {
    if (!_urlStringSwitch) {
        _urlStringSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 20 + 44, 50, 35)];
        [_urlStringSwitch setOn:NO];
        [_urlStringSwitch addTarget:self action:@selector(switchURL:) forControlEvents:UIControlEventValueChanged];
    }
    return _urlStringSwitch;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        CGRect tipsLabelFrame = self.urlStringSwitch.frame;
        tipsLabelFrame.origin.y += CGRectGetHeight(tipsLabelFrame);
        _tipsLabel = [[UILabel alloc] initWithFrame:tipsLabelFrame];
        _tipsLabel.textColor = [UIColor blackColor];
        [self setLocalLabelText];
    }
    return _tipsLabel;
}

#pragma mark - backgroundView

- (UIImageView *)backgroundView
{
    if (_backgroundView) return _backgroundView;
    
    _backgroundView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [_backgroundView setImage:[UIImage imageNamed:@"background" ]];
    
    
    return _backgroundView;
}

#pragma mark - subviews with ImageView

- (UIImageView *)imageView
{
    if (_imageView) return _imageView;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 120)];
    _imageView.center = CGPointMake(self.view.frame.size.width / 2, 100);
    
    [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTouch:)]];
    [_imageView setImage:[UIImage imageNamed:@"me_thumb"]];
    [_imageView setUserInteractionEnabled:YES];
    
    return _imageView;
}

- (XHMediaZoom *)imageZoomView
{
    if (_imageZoomView) return _imageZoomView;
    
    _imageZoomView = [[XHMediaZoom alloc] initWithAnimationTime:0.5 imageView:self.imageView blurEffect:NO];
    _imageZoomView.tag = 1;
    _imageZoomView.backgroundColor = [UIColor colorWithRed:0.141 green:0.310 blue:1.000 alpha:1.000];
    _imageZoomView.maxAlpha = 0.75;
    
    
    return _imageZoomView;
}

#pragma mark - subviews with Audio

- (UIImageView *)audioImageView
{
    if (_audioImageView) return _audioImageView;
    
    _audioImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 120)];
    _audioImageView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - 240);
    
    [_audioImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(audioDidTouch:)]];
    [_audioImageView setImage:[UIImage imageNamed:@"mic_talk_358x358"]];
    [_audioImageView setUserInteractionEnabled:YES];
    
    return _audioImageView;
}

- (XHAudioZoom *)audioZoomView
{
    if (_audioZoomView) return _audioZoomView;
    
    _audioZoomView = [[XHAudioZoom alloc] initWithAnimationTime:0.5 imageView:self.audioImageView audioUrl:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"backgroundsound" ofType:@"mp3"]] blurEffect:NO];
    
    _audioZoomView.tag = 2;
    _audioZoomView.maxAlpha = 0.85;
    
    return _audioZoomView;
}

#pragma mark - subviews with Video

- (UIImageView *)videoImageView
{
    if (_videoImageView) return _videoImageView;
    
    _videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 120)];
    _videoImageView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - 100);
    
    [_videoImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoDidTouch:)]];
    [_videoImageView setImage:[UIImage imageNamed:@"me_video_thumb"]];
    [_videoImageView setUserInteractionEnabled:YES];
    
    return _videoImageView;
}

- (XHVideoZoom *)videoZoomView
{
    if (_videoZoomView) return _videoZoomView;
    
    _videoZoomView = [[XHVideoZoom alloc] initWithAnimationTime:0.5 imageView:self.videoImageView videoUrl:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"me" ofType:@"mp4"]] blurEffect:NO];
    _videoZoomView.tag = 3;
    _videoZoomView.maxAlpha = 0.85;
    
    return _videoZoomView;
}

#pragma mark - Left cycle init

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.urlStringSwitch];
    [self.view addSubview:self.tipsLabel];
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.audioImageView];
    [self.view addSubview:self.videoImageView];
    
    [self.view sendSubviewToBack:self.backgroundView];
}

- (void)dealloc {
    NSLog(@"dealloc");
    self.urlStringSwitch = nil;
    self.tipsLabel = nil;
    self.backgroundView = nil;
    self.imageView = nil;
    if (_imageZoomView)
        self.imageZoomView = nil;
    self.audioImageView = nil;
    if (_audioZoomView)
        self.audioZoomView = nil;
    self.videoImageView = nil;
    if (_videoZoomView)
        self.videoZoomView = nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    ViewController * __weak weakSelf = self;
    [UIView animateWithDuration:0.15 animations:^{
        if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
            self.imageView.center = CGPointMake(self.view.frame.size.width / 2, 100);
            self.audioImageView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - 240);
            self.videoImageView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - 100);
        } else {
            self.imageView.center = CGPointMake(self.view.frame.size.height / 2 + 100, 80);
            self.audioImageView.center = CGPointMake(self.view.frame.size.height / 2 - 120, self.view.frame.size.width - 180);
            self.videoImageView.center = CGPointMake(self.view.frame.size.height / 2 + 100, self.view.frame.size.width - 80);
        }
    } completion:^(BOOL finished) {
        NSLog(@"%@", weakSelf.view);
    }];
}

#pragma mark - Handler

- (void)setLocalLabelText {
    _tipsLabel.text = NSLocalizedString(@"local", @"");
}

- (void)setHttpLabelText {
    _tipsLabel.text = NSLocalizedString(@"http", @"");
}

- (void)switchURL:(UISwitch *)sender {
    if (sender.on) {
        [self setHttpLabelText];
    } else {
        [self setLocalLabelText];
    }
}

- (BOOL)isVisiableHttpURL {
    return self.urlStringSwitch.on;
}

- (void)imageDidTouch:(UIGestureRecognizer *)recognizer
{
    __weak typeof(self) weakSelf = self;
    [self.imageZoomView showWithDidShowHandler:^{
        if ([weakSelf isVisiableHttpURL]) {
            [weakSelf.imageZoomView setImageUrl:[NSURL URLWithString:@"http://www.pailixiu.com/me.jpg"] customUICallback:nil];
        }
    } didDismissHandler:^{
        
    }];
}

- (void)audioDidTouch:(UIGestureRecognizer *)recognizer {
    __weak typeof(self) weakSelf = self;
    [self.audioZoomView showWithDidShowHandler:^() {
        if ([weakSelf isVisiableHttpURL]) {
            [weakSelf.audioZoomView refreshMediaURL:[NSURL URLWithString:@"http://www.pailixiu.com/jack/backgroundsound.mp3"]];
        } else {
            [weakSelf.audioZoomView refreshMediaURL:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"backgroundsound" ofType:@"mp3"]]];
        }
    }];
}

- (void)videoDidTouch:(UIGestureRecognizer *)recognizer
{
    __weak typeof(self) weakSelf = self;
    [self.videoZoomView showWithDidShowHandler:^() {
        // TODO: do anything what you want here
        if ([weakSelf isVisiableHttpURL]) {
            [weakSelf.videoZoomView refreshMediaURL:[NSURL URLWithString:@"http://www.pailixiu.com/jack/me.mp4"]];
        } else {
            [weakSelf.videoZoomView refreshMediaURL:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"me" ofType:@"mp4"]]];
        }
    }];
}

@end
