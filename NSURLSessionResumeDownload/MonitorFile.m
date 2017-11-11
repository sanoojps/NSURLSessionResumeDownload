//
//  MonitorFile.m
//  NSURLSessionResumeDownload
//
//  Created by sanooj on 11/7/17.
//  Copyright © 2017 sanooj. All rights reserved.
//

#import "MonitorFile.h"

@implementation MonitorFile

-(dispatch_source_t)moniterFile
{
    NSString* filePath =
    NSTemporaryDirectory();
    
    const char* fileSysRep =
    [filePath fileSystemRepresentation];
    
    int fd =
    open(fileSysRep, O_EVTONLY);
    
    dispatch_queue_t queue =
    dispatch_queue_create("com.filemon.q", 0);
    
    dispatch_source_t fileMonSource =
    dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd, DISPATCH_VNODE_WRITE, queue);
    
    dispatch_source_set_event_handler(fileMonSource, ^{
        [self.delegate didAddFileToDirectory:YES];
    });
    
    dispatch_source_set_cancel_handler(fileMonSource, ^{
        close(fd);
    });
    
    dispatch_resume(fileMonSource);
    
    return fileMonSource;
}

@end
