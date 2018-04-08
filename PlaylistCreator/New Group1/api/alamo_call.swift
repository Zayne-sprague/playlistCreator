import Alamofire

class Data1 {
    
    static fileprivate let queue = DispatchQueue(label: "requests.queue", qos: .utility)
    static fileprivate let mainQueue = DispatchQueue.main
    
    fileprivate class func make(request: DataRequest, closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        request.responseJSON(queue: Data1.queue) { response in
            
            // print(response.request ?? "nil")  // original URL request
            // print(response.response ?? "nil") // HTTP URL response
            // print(response.data ?? "nil")     // server data
            //print(response.result ?? "nil")   // result of response serialization
            
            switch response.result {
            case .failure(let error):
                Data1.mainQueue.async {
                    closure(nil, error)
                }
                
            case .success(let data):
                Data1.mainQueue.async {
                    closure((data as? [String: Any]) ?? [:], nil)
                }
            }
        }
    }
    
    class func searchRequest(url: String, closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        let path = url.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
        let request = Alamofire.request(path!)
        Data1.make(request: request) { json, error in
            closure(json, error)
        }
    }
}
