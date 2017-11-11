//
//  MonitorFile.h
//  NSURLSessionResumeDownload
//
//  Created by sanooj on 11/7/17.
//  Copyright © 2017 sanooj. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FileSystemEventsNotifier
-(void)didAddFileToDirectory:(BOOL)flag;
@end

@interface MonitorFile : NSObject

@property(atomic,weak) id <FileSystemEventsNotifier> delegate;

-(dispatch_source_t)moniterFile;

@end
