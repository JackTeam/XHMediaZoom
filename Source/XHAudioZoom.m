//
//  XHAudioZoom.m
//  XHMediaZoom
//
//  Created by 曾 宪华 on 13-12-14.
//  Copyright (c) 2013年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507. All rights reserved.
//

#import "XHAudioZoom.h"
#import "XHAudioPlayer.h"

#define IMAGE_MIC_NORMAL  [UIImage imageNamed:@"mic_normal_358x358.png"]
#define IMAGE_MIC_TALKING [UIImage imageNamed:@"mic_talk_358x358.png"]
#define IMAGE_MIC_WAVE [UIImage imageNamed:@"wave70x117.png"]

@interface XHPorgressImageView ()

- (UIImage *) partialImageWithPercentage:(float)percentage vertical:(BOOL)vertical grayscaleRest:(BOOL)grayscaleRest orginImage:(UIImage *)originImage;

@end

@implementation XHPorgressImageView

@synthesize progress               = _progress;
@synthesize hasGrayscaleBackground = _hasGrayscaleBackground;
@synthesize verticalProgress       = _verticalProgress;

- (UIImage *) partialImageWithPercentage:(float)percentage vertical:(BOOL)vertical grayscaleRest:(BOOL)grayscaleRest orginImage:(UIImage *)originImage {
    const int ALPHA = 0;
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, originImage.size.width * originImage.scale, originImage.size.height * originImage.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [originImage CGImage]);
    
    int x_origin = vertical ? 0 : width * percentage;
    int y_to = vertical ? height * (1.f -percentage) : height;
    
    for(int y = 0; y < y_to; y++) {
        for(int x = x_origin; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            if (grayscaleRest) {
                // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
                uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
                
                // set the pixels to gray
                rgbaPixel[RED] = gray;
                rgbaPixel[GREEN] = gray;
                rgbaPixel[BLUE] = gray;
            }
            else {
                rgbaPixel[ALPHA] = 0;
                rgbaPixel[RED] = 0;
                rgbaPixel[GREEN] = 0;
                rgbaPixel[BLUE] = 0;
            }
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:originImage.scale
                                           orientation:UIImageOrientationUp];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

- (void)dealloc
{
    self.originalImage = nil;
}

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self commonInit];
    }
    return self;
    
}

- (void)commonInit{
    
    _progress = 0.f;
    _hasGrayscaleBackground = YES;
    _verticalProgress = YES;
    _originalImage = self.image;
    
}

#pragma mark - Custom Accessor

- (void)setImage:(UIImage *)image{
    
    [super setImage:image];
    
    if (!_internalUpdating) {
        self.originalImage = image;
        [self updateDrawing];
    }
    
    _internalUpdating = NO;
}

- (void)setProgress:(float)progress{
    
    _progress = MIN(MAX(0.f, progress), 1.f);
    [self updateDrawing];
    
}

- (void)setHasGrayscaleBackground:(BOOL)hasGrayscaleBackground{
    
    _hasGrayscaleBackground = hasGrayscaleBackground;
    [self updateDrawing];
    
}

- (void)setVerticalProgress:(BOOL)verticalProgress{
    
    _verticalProgress = verticalProgress;
    [self updateDrawing];
    
}

#pragma mark - drawing

- (void)updateDrawing{
    
    _internalUpdating = YES;
    self.image = [self partialImageWithPercentage:_progress vertical:_verticalProgress grayscaleRest:_hasGrayscaleBackground orginImage:_originalImage];
}

@end

@interface XHAudioHud () {
    UIImageView         * _talkingImageView;
    XHPorgressImageView * _dynamicProgress;
}

@end

@implementation XHAudioHud

- (void)setProgress:(float)progress {
    [self setProgress:progress animated:YES];
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    if (progress > 1.0) {
        progress = 1.0;
    } else if (progress < 0.0) {
        progress = 0.0;
    }
    _progress = progress;
    
    _dynamicProgress.progress = progress;
    
    if (progress <= 0.01){
        [self showHighLight:NO];
    }
    else{
        [self showHighLight:YES];
    }
}

#pragma mark - left cycle init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.progress = 0.f;
        
        CGRect bounds = self.bounds;
        CGPoint center = CGPointMake(CGRectGetWidth(bounds) / 2.0, CGRectGetHeight(bounds) / 2.0);
        UIImageView * micNormalImageView = [[UIImageView alloc] initWithImage:IMAGE_MIC_NORMAL];
        micNormalImageView.frame = CGRectMake(0, 0, IMAGE_MIC_NORMAL.size.width, IMAGE_MIC_NORMAL.size.height);
        micNormalImageView.center = center;
        [self addSubview:micNormalImageView];
        
        _talkingImageView = [[UIImageView alloc] initWithFrame:micNormalImageView.frame];
        _talkingImageView.image = IMAGE_MIC_TALKING;
        [self addSubview:_talkingImageView];
        _talkingImageView.center = self.center;
        
        _dynamicProgress = [[XHPorgressImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 58.5)];
        _dynamicProgress.image = IMAGE_MIC_WAVE;
        [self addSubview:_dynamicProgress];
        
        /* set */
        _dynamicProgress.progress = 0;
        _dynamicProgress.hasGrayscaleBackground = NO;
        _dynamicProgress.verticalProgress = YES;
        _dynamicProgress.center = CGPointMake(self.center.x, self.center.y-13);
    }
    return self;
}

- (void)dealloc {
    _talkingImageView = nil;
    _dynamicProgress = nil;
}

-(void) showHighLight:(BOOL)yesOrNo
{
    if (yesOrNo){
        
        [UIView animateWithDuration:0.2 animations:^{
            
            _talkingImageView.alpha = 1;
            
        }];
    }
    else{
        
        [UIView animateWithDuration:0.2 animations:^{
            
            _talkingImageView.alpha = 0;
            
        }];
    }
}

@end

@interface XHAudioZoom () <XHAudioPlayerDelegate>

@property (nonatomic, strong) XHAudioPlayer *audioPlayer;
@property (nonatomic, strong) XHAudioHud *xh_audioHud;
@property (nonatomic, strong) UIView *audioContainerView;

@property (nonatomic, assign) BOOL downLoadAudioFinish;

@end

@implementation XHAudioZoom

- (id)initWithAnimationTime:(NSTimeInterval)duration
                      imageView:(UIImageView *)imageView
                   audioUrl:(NSURL *)audioUrl {
    return [self initWithAnimationTime:duration imageView:imageView audioUrl:audioUrl blurEffect:NO];
}

- (id)initWithAnimationTime:(NSTimeInterval)duration
                      imageView:(UIImageView *)imageView
                   audioUrl:(NSURL *)audioUrl
                 blurEffect:(BOOL)useBlur {
    self = [super initWithAnimationTime:duration imageView:imageView blurEffect:useBlur];
    if (self) {
        self.mediaURL = audioUrl;
    }
    return self;
}

- (void)dealloc {
    [self resetAll];
}

- (void)resetAll {
    [self resetAudioPlayer];
    [self resetAudioHud];
}

- (void)showAnimationDidFinish
{
    if (self.didShowHandler)
        self.didShowHandler();
    
    if ([self isFileURL]) {
        [self.imageView addSubview:self.audioContainerView];
        [self.xh_audioHud setProgress:0.0f];
        [self.audioPlayer playFile:self.mediaURL.path];
    } else {
        self.activityIndicatorView.center = CGPointMake(CGRectGetWidth(self.imageView.frame) / 2.0, CGRectGetHeight(self.imageView.frame) / 2.0);
        [self.imageView addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *audioData = [[NSData alloc] initWithContentsOfURL:self.mediaURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.downLoadAudioFinish = YES;
                [self.imageView addSubview:self.audioContainerView];
                [self.xh_audioHud setProgress:0.0f];
                [self _resetActivityIndicatorView];
                [self.audioPlayer playFileData:audioData];
            });
        });
    }
}

- (void)willHandleSingleTap
{
    if ([self isFileURL] || self.downLoadAudioFinish) {
        [self.audioContainerView removeFromSuperview];
        [self resetAll];
    }
    [self _resetActivityIndicatorView];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [super deviceOrientationDidChange:notification];
    [self.audioContainerView setFrame:self.imageView.bounds];
}

#pragma mark - setter / getter

- (XHAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        _audioPlayer = [[XHAudioPlayer alloc] init];
        _audioPlayer.delegate = self;
    }
    return _audioPlayer;
}

- (XHAudioHud *)xh_audioHud {
    if (!_xh_audioHud) {
        _xh_audioHud = [[XHAudioHud alloc] initWithFrame:CGRectMake(0, 0, 179, 179)];
        _xh_audioHud.center = CGPointMake(CGRectGetWidth(self.audioContainerView.frame) / 2.0, CGRectGetHeight(self.audioContainerView.frame) / 2.0);
        [self.audioContainerView addSubview:self.xh_audioHud];
    }
    return _xh_audioHud;
}

- (UIView *)audioContainerView {
    if (!_audioContainerView) {
        _audioContainerView = [[UIView alloc] initWithFrame:self.imageView.bounds];
        _audioContainerView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:self.maxAlpha / 1.5];
    }
    return _audioContainerView;
}

- (void)resetAudioPlayer {
    if (!_audioPlayer)
        return;
    
    [_audioPlayer resetAudioPlayer];
    self.audioPlayer = nil;
}

- (void)resetAudioHud {
    if (!_xh_audioHud)
        return;
    
    [_xh_audioHud setProgress:0.0f];
    self.xh_audioHud = nil;
}

#pragma mark - XHAudioPlayer delegate

- (void)XHAudioPlayer:(XHAudioPlayer *)audioPlayer didPlayFinish:(CGFloat)progress {
    
}

- (void)XHAudioPlayer:(XHAudioPlayer *)audioPlayer onProgress:(CGFloat)progress {
    if (!audioPlayer.audioPlayer)
        return;
    
    [audioPlayer.audioPlayer updateMeters];
    
    float peakPower = [audioPlayer.audioPlayer averagePowerForChannel:0];
    double ALPHA = 0.015;
    double peakPowerForChannel = pow(10, (ALPHA * peakPower));
    
    [self.xh_audioHud setProgress:peakPowerForChannel];
    [self setCurrentTime:audioPlayer.audioPlayer.currentTime];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    // NSLog(@"%@", [NSString stringWithFormat:@"%.0fs/%.0fs", (currentTime <= 0.0 ? 0.0 : currentTime), _player.duration]);
}

@end
