XHMediaZoom
===========
类似instagrm图片、视频等资源的缩放动画View来查看详细内容，根据ImageView的位置进行缩放，并且还有查看语音资源的播放功能，注意：资源文件可是网络的，也是可以是本地的，方便自定义使用，并且还具有iOS7背景毛玻璃效果，可以自定设置是否开启.

![image](https://github.com/JackTeam/XHMediaZoom/raw/master/Screenshots/PhotoBlurExample.png)
![image](https://github.com/JackTeam/XHMediaZoom/raw/master/Screenshots/VideoExample.png)
![image](https://github.com/JackTeam/XHMediaZoom/raw/master/Screenshots/AudioExample.png)


##安装
##Installation

中文:      [CocosPods](http://cocosPods.org)安装XHMediaRecorder的推荐方法,只是在Podfile添加以下行:

english:   [CocosPods](http://cocosPods.org) is the recommended methods of installation XHMediaRecorder, just add the following line to `Profile`:

## Profile

```
pod 'XHMediaZoom'
```

## 例子
## Example

```objective-c
- (void)_setup {
    UIImageView *imgaeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"your image"]];
    imgaeView.userInteractionEnabled = YES;
    [imgaeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(show:)]];
    [self.view addSubview:imgaeView];
}

- (void)show:(UITapGestureRecognizer *)gesture {
    [self _showZoom:(UIImageView *)gesture.view];
}

- (void)_showZoom:(UIImageView *)imageView {
    XHMediaZoom *imageZoomView = [[XHMediaZoom alloc] initWithAnimationTime:0.5 imageView:imageView blurEffect:NO];
    // self.imageView 是你被点击的控件
    // self.imageView is your imageView
    imageZoomView.tag = 1;
    imageZoomView.backgroundColor = [UIColor colorWithRed:0.141 green:0.310 blue:1.000 alpha:1.000];
    imageZoomView.maxAlpha = 0.75;
    [imageZoomView show];
}
```

### Thank you

[rFlex](https://github.com/rFlex) provide VideoPlay 

## License

中文:      XHMediaZoom 是在MIT协议下使用的，可以在LICENSE文件里面找到相关的使用协议信息.

English:   XHMediaZoom is acailable under the MIT license, see the LICENSE file for more information.
