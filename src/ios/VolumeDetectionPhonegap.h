//
//  AppDelegate.h
//  test
//
//  Created by Xavier Ledoux on 07/01/2014.
//  Copyright (c) 2014 Adfab. All rights reserved.
//

#import <Cordova/CDVPlugin.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VolumeDetectionPhonegap : CDVPlugin {
    AVAudioRecorder *recorder;

    NSTimer *timer;
    NSThread *thread;
    
    // PHONEGAP
    NSString *callbackId;
    CDVPluginResult* pluginResult;

}

@end
