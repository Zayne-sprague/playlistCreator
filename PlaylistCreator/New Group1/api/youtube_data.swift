//
//  youtube_data.swift
//  PlaylistCreator
//
//  Created by zayne sprague on 4/7/18.
//  Copyright © 2018 ZRS. All rights reserved.
//

//TODO - MOVE THIS ONTO A SERVER.  BEST KEPT ON DEVICE FOR V1 FOR RELIABILITY/MONEY REASONS

import Foundation
import Alamofire

var api_key = "AIzaSyBy7g1ogoE72VVlFwiBYVD2L-bOnASbZIk"
var video_location = "https://www.youtube.com/watch?v="
var youtube_api_url = "https://www.googleapis.com/youtube/v3/"
var api_search = "search?key=\(api_key)"
var api_video_info = "videos?key=\(api_key)"
var options = ["videoDuration": ["any", "long", "medium", "short"],
               "order": ["date", "rating", "relevance", "title", "videoCount", "viewCount"]]
var lang = "en"


// GET VIDEOS FOR TAGS
func find_videos_for_tags(tags: [String] , filters: [String:Any], handler: @escaping ([String])->() ) {
    
    locate_based_on_topics(tags: tags, filters: filters, ids: [], count: 1, handler: handler) //hardcode 1 returned url for each video.
}


// ---- HELPER FUNCTIONS ----
func locate_based_on_topics(tags: [String], filters: [String:Any], ids: [String], count: Int, handler: @escaping ([String])->()){
    var new_ids = ids
    var i = 0
    for tag in tags{
        var url = get_search_url(query: [
                "topic": tag,
                "order": "relevance",
                "maxResults": count
            ]) //CHANGE THESE FOR MORE FILTERING.
        
        //var json = get_tagged_video(url: url, filters: filters)
        
        
        get_tagged_video(url: url, filters: filters, handler: {id in
            new_ids.append(id)
            
            if(new_ids.count == tags.count){
                handler(new_ids)
            }
        })
    }
}

func get_tagged_video(url: String, filters: [String:Any], handler: @escaping (String)->()){
    Data1.searchRequest(url: url, closure: { json, error  in
        print(error ?? "nil")
        print(json ?? "nil")
        print("Update views")
        
        var search_ids = get_search_ids_from_response(json: json!)
        get_videos_info(search_ids: search_ids, handler: {search_video_info in
            var id = filter_videos(filters: filters, video_info: search_video_info)
            
            handler(id)
        })
       
    })
}

func get_search_ids_from_response(json: [String: Any]) -> [String]{
    var ids : [String] = []
    
    if let items = json["items"] as? [[String: Any]]{
        for item in items{
            var vid_ids = item["id"] as! [String: Any]
            ids.append(vid_ids["videoId"] as! String)
        }
    }
    
    return ids
}

func get_videos_info(search_ids: [String], handler: @escaping ([[String:Any]])->()){
    
    var infos : [[String: Any]] = []
    var i = 0
    for id in search_ids{
    
        pull_video_info_request(id: id, handler: {
            info in
            
            infos.append(info)
            
            if i >= search_ids.count-1 {
                handler(infos)
            }else{
                i += 1
            }
        })
    }
}

func pull_video_info_request(id: String, handler: @escaping ([String:Any])->()){
    var url = "\(youtube_api_url)\(api_video_info)&part=contentDetails,statistics,snippet&id=\(id)"

    Data1.searchRequest(url: url, closure: { json, error  in
        print(error ?? "nil")
        print(json ?? "nil")
        print("Update views")
        
        var items = json!["items"] as! [[String: Any]]
        var item = items[0]
        
        handler(item)
    })
}

func filter_videos(filters: [String: Any], video_info: [[String:Any]]) -> String{
    var urls : [String] = []
    var new_vid_info : [String:Any] = [:]
    
    if let likes = filters["likes"] as? String{
        new_vid_info = sort_video_info(arg: "likes", rank_setting: likes, video_info: video_info)
    }
    
    for vid in new_vid_info{
        var vd = vid.value as! [String:Any]
        urls.append(vd["id"] as! String)
    }
    
    return urls[0]
}

func sort_video_info(arg: String, rank_setting: Any, video_info: [[String:Any]]) -> [String:Any]{
    var sorted_video_info : [String:Any] = [:]
    
    if arg == "likes"{
        var info : [String :Any] = sort_by_likes(info : video_info)
        var likes = info["likes"] as! [String:Any]
        var hold = info["hold"] as! [String:Any]
        
        sorted_video_info = order_search_info(rank_setting: rank_setting, sorted_info: likes, hold: hold)
    }
    
    return sorted_video_info
}

func order_search_info(rank_setting: Any, sorted_info: [String:Any], hold: [String:Any]) -> [String:Any]{
    var info : [String:Any] = get_order_structure(info: sorted_info, setting: rank_setting)
    var count = info["count"] as! Int
    var direction = info["direction"] as! String
    
    return put_search_in_order(info: sorted_info, hold: hold, count: count, direction: direction)
    
}

func put_search_in_order(info: [String:Any], hold: [String:Any], count:Int, direction:String) -> [String:Any]{
    var new_info : [String:Any] = [:]
    
    var cnt = count;
    var dir = direction
    
    for x in info{
        new_info["\(cnt)"] = hold[x.key]
        if direction == "up"{
            cnt += 1
        }else{
            cnt -= 1
        }
    }
    
    return new_info
}

func get_order_structure(info: [String:Any], setting: Any) -> [String:Any]{
    var count = 1;
    var direction = "up";
    if (setting as! String == "most"){
        count = info.count
        direction = "down"
    }
    return ["count": count, "direction": direction]
}


func sort_by_likes(info : [[String:Any]]) -> [String:Any]{
    var new_info : [String:Any] = [:]
    var likes : [String:Int] = [:]
    var hold : [String:Any] = [:]
    
    for x in info{
        var stats = x["statistics"] as! [String: Any]
        
        if let likeCount = stats["likeCount"] as? Int{
            likes[x["id"] as! String] = likeCount
        }else{
            likes[x["id"] as! String] = 0
        }
        
        hold[x["id"] as! String] = x
    }
    
    let raw_sorted_likes = likes.sorted{ $0.key > $1.key }
    var sorted_likes : [String:Any] = [:]
    
    for x in raw_sorted_likes{
        sorted_likes[x.key] = x.value
    }
    
    new_info = ["likes": sorted_likes, "hold": hold]
    return new_info
}

// ---- CONSTRUCTOR FUNCTIONS ----

func get_search_url(query: [String:Any]) -> String{
    var url = youtube_api_url + api_search + "&part=snippet&type=video"

    
    if let count = query["maxResults"] as? Int{
        url += "&maxResults=\(count)"
    }
    
    if let duration = query["videoDuration"] as? String{
        url += "&videoDuration=\(duration)"
    }
    
    if let order = query["order"] as? String{
        url += "&order=\(order)"
    }
    
    if let relevance = query["relevance"] as? String{
        url += "&relevance=\(relevance)"
    }
    
    url += "&relevanceLanguage=\(lang)" //Can't imagine a time when you wouldn't want this. (out of country... lets focus in country first)
    
    if let topic = query["topic"] as? String{
        url += "&q=\(topic)"
    }else{
        assert(true, "Failed to give a topic!")
    }
    
    return url
}

