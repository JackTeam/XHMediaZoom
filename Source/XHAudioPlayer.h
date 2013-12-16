//
//  XHAudioPlayer.h
//  XHMediaZoom
//
//  Created by 曾 宪华 on 13-12-16.
//  Copyright (c) 2013年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class XHAudioPlayer;

@protocol XHAudioPlayerDelegate <NSObject>

@optional
- (void)XHAudioPlayer:(XHAudioPlayer *)audioPlayer onProgress:(CGFloat)progress;
- (void)XHAudioPlayer:(XHAudioPlayer *)audioPlayer didPlayFinish:(CGFloat)progress;

@end

@interface XHAudioPlayer : NSObject <AVAudioPlayerDelegate, AVAudioSessionDelegate, AVAudioRecorderDelegate> {
    
}
@property(nonatomic, strong) AVAudioPlayer  *audioPlayer;
@property(nonatomic, strong) AVAudioRecorder * audioRecorder;
@property(nonatomic, strong) NSTimer * timer;
@property(nonatomic, weak) id <XHAudioPlayerDelegate> delegate;

- (void)resetAudioPlayer;
- (void)playFile:(NSString *)strFilePath;
- (void)recordTo:(NSString *)strFilePath;
- (void)playFileData:(NSData *)data;
- (void)playFileOnline:(NSString *)strUrl;
@end
