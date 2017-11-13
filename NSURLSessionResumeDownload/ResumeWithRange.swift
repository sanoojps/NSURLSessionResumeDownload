//
//  ResumeWithRange.swift
//  NSURLSessionResumeDownload
//
//  Created by sanooj on 11/10/17.
//  Copyright © 2017 sanooj. All rights reserved.
//

import Foundation

///https://developer.apple.com/library/content/qa/qa1761/_index.html
///curl "https://download-installer.cdn.mozilla.net/pub/firefox/releases/56.0.2/mac/en-US/Firefox%2056.0.2.dmg" -i -H "Range: bytes=0-1023" -v


    


let firefoxURLString = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/56.0.2/mac/en-US/Firefox%2056.0.2.dmg"

let eTagKey:String = "Etag"
let lastModifiedKey:String = "Last-Modified"


let ifRangeKey: String = "If-Range"

let rangeKey: String = "Range"
let bytesKey: String  = "bytes="

let contentLengthKey: String =
"Content-Length"


let defaultRange: Range<Int32> =
    Range<Int32>(uncheckedBounds: (lower: 0, upper: 1000))

typealias EtagTuple = (etag:String?,lastModified:String?,contentLength:String)

typealias ETagCompletionHandler = (EtagTuple?)->()

typealias URLSessionDataTaskCompletionHandler = (Data?, URLResponse?, Error?) -> Void

class ResumableWithChunks {
    
var downloadedData:Data? = nil

func makeAUrlSessionCall(
    urlRequest:URLRequest?,
    completionHandler:@escaping URLSessionDataTaskCompletionHandler
    )
{
    guard let urlRequest = urlRequest else
    {
        completionHandler(nil,nil,NSError())
        return
    }
    
    let session =
        URLSession.shared
    
    let task = session.dataTask(with: urlRequest) {
        (data:Data?, response:URLResponse?, error:Error?) in
        
        print("Range \(urlRequest.allHTTPHeaderFields?["Range"] as Any)")
        print("If-Range \(urlRequest.allHTTPHeaderFields?["If-Range"] as Any)")
        print("Content-Range \((response as? HTTPURLResponse)?.allHeaderFields["Content-Range"] as Any)")
        print("Data length \(data?.count as Any)")
        print("Current Thread \(Thread.current as Any)")
        completionHandler(data,response,error)
        
    }
    
    task.resume()
}

func makeAURLRequest(
    url:URL,
    HTTPMethod:String = "GET",
    headerParameters:[String:String],
    bodyData:Data?
    ) -> URLRequest
{
    var urlRequest:URLRequest =
        URLRequest.init(url: url)
    
    urlRequest.httpMethod =
    HTTPMethod
    
    urlRequest.httpBody =
    bodyData
    
    urlRequest.allHTTPHeaderFields =
    headerParameters
    
    return urlRequest
}

func getEtag(urlString:String,completionHandler:@escaping ETagCompletionHandler)
{
    guard let url:URL = URL(string: urlString) else
    {
        completionHandler(nil)
        return
    }
    
    let urlRequest:URLRequest =
        makeAURLRequest(
            url: url,
            HTTPMethod: "HEAD",
            headerParameters: [:],
            bodyData: nil
    )
    
    makeAUrlSessionCall(urlRequest: urlRequest)
    { (data:Data?, response:URLResponse?, error:Error?) in
        
        guard let response: HTTPURLResponse =
            response as? HTTPURLResponse else
        {
            completionHandler(nil)
            return
        }
        
        guard let headers:[String :Any] =
            response.allHeaderFields as? [String : Any] else
        {
            completionHandler(nil)
            return
        }
        
        let lastMod = headers[lastModifiedKey] as? String
        let etag = headers[eTagKey] as? String
        
        guard let contentLength = headers[contentLengthKey] as? String
        else
        {
            completionHandler(nil)
            return
        }
        
        let toTrimCharSet:CharacterSet =
            CharacterSet(charactersIn: "\"")
        
        let trimmedEtag: String? =
            etag?.trimmingCharacters(in: toTrimCharSet)
        
        
        let etagTuple :EtagTuple =
            EtagTuple(
                etag:trimmedEtag,
                lastModified:lastMod ,
                contentLength:contentLength
        )
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            completionHandler(etagTuple)
        }
    }
}

func prepareResumeHeaders(
    etag:String?,
    lastMod:String?,
    range:Range<Int32> = defaultRange
    ) -> [String : String]
{
    //if-Range
    let ifRange =
        lastMod
    
    let range =
        String(format: bytesKey + "%d-%d", range.lowerBound,range.upperBound)

    if let ifRange = ifRange
    {
        return [ifRangeKey : ifRange, rangeKey : range]
    }
    
    return [rangeKey : range]
}

func makeChunks(contentLength:String) -> [Range<Int32>]
{
    let defaultChunkSize: Int32 = 1 * 1024 * 1024 //1 MB
    
    let numberFormatter =
        NumberFormatter.init()
    
    let contentLength:Int32 =
        numberFormatter.number(from: contentLength)?.int32Value ?? defaultChunkSize
    
    let numberOfChunks: Float =
        Float(contentLength) / Float(defaultChunkSize)
    
    print(numberOfChunks)
    print(contentLength)
    
    var ranges: [Range<Int32>] =
    []
    
    var lowerbounds : Int32 = 0
    
    var upperbounds :Int32 = 0
    
    while (upperbounds < contentLength)
    {
        
        upperbounds = upperbounds + defaultChunkSize
        
        if upperbounds >= contentLength
        {
            upperbounds = contentLength
        }
        
        let range  =
        Range<Int32>.init(uncheckedBounds: (lower: lowerbounds, upper: upperbounds))
        
        lowerbounds = upperbounds + 1
        //+1 as http range hedaer 0.499 == 500 .both limits are included
        //but Swift Range does not include upper bounds
        //Stupid mE!
        
        ranges.append(range)
    }
    
    
    return ranges
}

func makeTheRangedGetRequest(
    urlrequest:URLRequest,
    range:Range<Int32> = defaultRange ,
    completionHandler:@escaping URLSessionDataTaskCompletionHandler)
{
    
    
    self.makeAUrlSessionCall(
        urlRequest: urlrequest,
        completionHandler:
        { (data:Data?, response:URLResponse?, error:Error?) in
            
            completionHandler(data,response,error)
            
    })
    
}

    class DownloadObject
    {
        let range: Range<Int32>
        let data: Data
        //i hold the data dowloaded
        //here
        //ideally this could be written out to a file
        //and a reference to that tmp file path
        //should be used
        
        init(data:Data,range:Range<Int32>)
        {
            self.data = data
            self.range = range
        }
    }

    
    static let newU = "https://www.hdwallpapers.in/download/justice_league_wonder_woman_superman_batman_4k_8k-7680x4320.jpg"
    
    static let oldU =
    "https://www.hdwallpapers.in/download/skull_and_bones_e3_2017_4k_8k-7680x4320.jpg"
    
    
    func startDownload(urlString:String = firefoxURLString,completion:@escaping ([Range<Int32>])->())
{
    getEtag(urlString: urlString) { (params:(etag:String?,lastMod:String?,contentLength:String)?) in
        
         let etag = params?.etag
            let lastMod = params?.lastMod
        guard let contentLength =  params?.contentLength else
        {
            return
        }
        
        let ranges =
            self.makeChunks(contentLength: contentLength)
        
        var dataChunks :[DownloadObject] =
        []
        
        
        var lastActiveRange:Range<Int32> =
            defaultRange
        
        var failedRanges:[Range<Int32>] =
        []
        
        let dispatchGroup = DispatchGroup()
        
        //let range = ranges[0]
        
        ranges.forEach({ (range:Range<Int32>) in
            
            dispatchGroup.enter()
            
            let headers =
                self.prepareResumeHeaders(etag: etag, lastMod: lastMod, range: range)
            
            guard let url:URL = URL(string: urlString) else
            {
                return
            }
            
            let urlrequest =
                self.makeAURLRequest(url: url,
                                HTTPMethod: "GET",
                                headerParameters: headers,
                                bodyData: nil
            )
            
            
            
            self.makeTheRangedGetRequest(
                urlrequest: urlrequest,
                range: range,
                completionHandler:
                { (data:Data?, response:URLResponse?, error:Error?) in
                    
                    if let data = data
                    {
                        
                        lastActiveRange =
                        range
                        
                        print(lastActiveRange)
                        
                        let dataChunk =
                            DownloadObject.init(data: data, range: range)
                        
                        dataChunks.append(dataChunk)
                    }
                    else
                    {
                        print(range)
                        print(response as? HTTPURLResponse as Any)
                        print(error as Any)
                        
                        //light sync
                        //this var might be accessed from multiple threads
                        DispatchQueue.main.async {
                            failedRanges.append(range)
                        }

                        //print(failedRanges)
                    }
                    
                    dispatchGroup.leave()
            })
            
        })
        
        dispatchGroup.notify(queue: DispatchQueue.main, execute: {
           print(dataChunks.count)
            
            let docsDir  =
            NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory,
                FileManager.SearchPathDomainMask.userDomainMask,
                true
                )[0]
            
            let fileName = docsDir + "/" + (urlString as NSString).lastPathComponent
    
            
            //as download happens parallelly
            // you woulnd't know whihc cunk finished first
            dataChunks.sort(
                by: { (lhs:DownloadObject, rhs:DownloadObject) -> Bool in
                
                if lhs.range.lowerBound < rhs.range.lowerBound
                {
                    return true
                }
                
                return false
            })
            
            //combine
            var data:Data =  Data()
            dataChunks.forEach({ (chunk:DownloadObject) in
                data.append(chunk.data)
            })
            
            do {
                
                try? FileManager.default.removeItem(atPath: fileName)
                
                try data.write(to: URL.init(fileURLWithPath: fileName))
                
                //data should be made nil here
            }
            catch
            {
                print(error)
            }
            
            completion(failedRanges)
            
        })
        
    } // get tag
}

}
