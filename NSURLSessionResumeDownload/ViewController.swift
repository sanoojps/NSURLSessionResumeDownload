//
//  ViewController.swift
//  NSURLSessionResumeDownload
//
//  Created by sanooj on 11/6/17.
//  Copyright © 2017 sanooj. All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController , URLSessionDownloadDelegate,FileSystemEventsNotifier {

    var dispatchSource:DispatchSource? = nil
    var cacheOfFilesInTmpDirWithTmp:Set<URL> = []
    
    var count = 0
    
    var session :URLSession? = nil
    var task :URLSessionDownloadTask? = nil
    
    var resumableData : Data? = nil
    
    var totalBytesExpectedToWrite:Int64 = 0
    var totalBytesWritten :Int64 = 0
    
    let operationQueue =
    OperationQueue.init()
    
    @IBAction func start(_ sender: UIButton) {
    
        if self.progress.progress == 1.0
        {
            self.progress.setProgress(0, animated: true)
        }
        
        
        self.task =
            self.session?.downloadTask(with: URL.init(string: "https://download-installer.cdn.mozilla.net/pub/firefox/releases/56.0.2/mac/en-US/Firefox%2056.0.2.dmg")!)
        
        self.task?.resume()
    
    }
    
    @IBAction func stop(_ sender: UIButton) {
        
//        self.task?.cancel(byProducingResumeData: { (data:Data?) in
//
//            if let data = data
//            {
//                self.resumableData =
//                ///Data.init(referencing: data as NSData)
//                data
//            }
//        })

        
        self.task?.cancel()
    }
    
    @IBOutlet weak var progress: UIProgressView!
    func add(delegate:ViewController) -> URLSession {
        //let config = URLSessionConfiguration.background(withIdentifier: "FreeFlowIDentifier");
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: delegate, delegateQueue: self.operationQueue)
        
        return session
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let fileMonQ = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
//
//        let tmp_dir =
//            NSTemporaryDirectory()
//
//        let fileSystemRep =
//        (tmp_dir as? NSString)?.fileSystemRepresentation
//
////        let fd =
////        open(fileSystemRep, O_EVTONLY)
//
//        guard let fileHandle =
//            try? FileHandle.init(forReadingFrom: URL.init(string: tmp_dir)!) else
//        {
//            return
//        }
//
//        let fileDiscriptor =
//            fileHandle.fileDescriptor
//
//
//        let fileMonSource =
//        DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDiscriptor, eventMask: DispatchSource.FileSystemEvent.write,
//                                                  queue: fileMonQ)
//
//
//        fileMonSource.setEventHandler {
//            print(fileMonSource as Any)
//        }
//
//        fileMonSource.setCancelHandler(qos: DispatchQoS.background, flags: DispatchWorkItemFlags.enforceQoS) {
//
//        }
//
//        fileMonSource.resume()
        
        /*
        
        let moniotr =
            MonitorFile()
        moniotr.delegate = self
        
        self.dispatchSource =
            moniotr.moniterFile()
        
        let tmp_dir =
       NSTemporaryDirectory()
        
        //files before
        cacheOfFilesInTmpDirWithTmp =
        Set<URL>(
            (
                (try? FileManager.default.contentsOfDirectory(
                    at: URL.init(string: tmp_dir)!,
                    includingPropertiesForKeys: nil,
                    options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles
                    )
                    ) ?? []).filter({ (filUrl:URL) -> Bool in
                return (filUrl.absoluteString as NSString).pathExtension == "tmp"
            })
        )
        
        
        
        
        let urlString = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/56.0.2/mac/en-US/Firefox%2056.0.2.dmg"
        
        //let urlString = "https://images5.alphacoders.com/444/444113.jpg"
        
        //let config = URLSessionConfiguration.default
        
        
        let url = URL(string: urlString)
        self.session =
            add(delegate: self)
        self.task = session?.downloadTask(with: url!)
        //tmp file gets created here
        
        
        task?.resume()
        
        */
    
    }
    
    func didAddFile(toDirectory flag: Bool) {
        
        let tmp_dir =
            NSTemporaryDirectory()
        
        if flag
        {
            let newFiles =
            Set<URL>(
                (
                    (try? FileManager.default.contentsOfDirectory(
                        at: URL.init(string: tmp_dir)!,
                        includingPropertiesForKeys: nil,
                        options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles
                        )
                        ) ?? []).filter({ (filUrl:URL) -> Bool in
                            return (filUrl.absoluteString as NSString).pathExtension == "tmp"
                        })
            )
        
        
        let newFile =
            newFiles.subtracting(cacheOfFilesInTmpDirWithTmp);
            
            print(newFile)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        
        /*
         This works in iOS 11 with or without actual resume data
         If i want this method to return data
         I need to use cancel with resume data
         
         resume data object is always  around 5000
         It is not the offset of any kind
         
         Now.. on iOS 11..
         If the session object still exists download resumes automatically
         
         The Ui to start and stop works
         */
        
        print(#function)
        
        let resumeData =
            ((error as NSError?)?.userInfo[NSURLSessionDownloadTaskResumeData]) as? Data
        
        if let data = resumeData
        {
            self.resumableData =
                ///Data.init(referencing: data as NSData)
            data
        }
        
        
        print("paused \(resumeData?.count ?? 0)")
        
    }
    
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        
        print(#function)
        print(location)
        
        let docPath =
            NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first?.appending("/" + location.lastPathComponent)
        
        do
        {
            try
                FileManager.default.copyItem(at: location, to: URL.init(fileURLWithPath: docPath!))
            
        }
        catch(let exc)
        {
            print(exc)
        }
        
    }
    
    
     public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        if self.totalBytesExpectedToWrite == 0
        {
            self.totalBytesExpectedToWrite =
            totalBytesExpectedToWrite
        }
        
        self.totalBytesWritten += bytesWritten
        
        print("bytesWritten \(bytesWritten)")
        print("totalBytesWritten \(totalBytesWritten)")
        print("totalBytesExpectedToWrite \(totalBytesExpectedToWrite)")
        
        print(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) * 100)
        
        print("total calculated bytes written \(self.totalBytesWritten)")
        
        DispatchQueue.main.async
            {
            self.progress.setProgress((Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)), animated: true)
        }
        
           
        
//        if count == 5
//        {
//            downloadTask.cancel { (data:Data?) in
//
//                //let config = URLSessionConfiguration.default
////                let config = URLSessionConfiguration.background(withIdentifier: "FreeFlowIDentifier");
////                let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
////
//                if let data = data
//                {
//                    print("resumeData: \(data.count)")
//                    let task =
//                        self.session?.downloadTask(withResumeData: data)
//
//                    task?.resume()
//
//                    print("newResume")
//                }
//
//
//            }
//
//            count = 0
//            return
//        }
//
//        if totalBytesWritten == totalBytesExpectedToWrite
//        {
//            return
//        }
//
//        count+=1
        
        //downloadTask.cancel()
    }
    
     public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64)
    {
        print(#function)
    }
}

