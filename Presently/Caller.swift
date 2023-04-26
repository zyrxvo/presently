//
//  Caller.swift
//  Presently
//
//  Created by Garett Brown on 2023-04-26.
//

import Foundation
import Cocoa

func query(completion: @escaping (String?, Int?) -> Void) {
    let defaults = UserDefaults.standard
    defaults.synchronize()
    guard let apiKey = defaults.string(forKey: "APIKey") else { return }
    guard let url = URL(string: "https://api.track.toggl.com/api/v9/me/time_entries/current") else { return }
    
    let loginData = "\(apiKey):api_token".data(using: .utf8)!
    let base64LoginData = loginData.base64EncodedString()
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    var currentTimer = "Test"
    let config = URLSessionConfiguration.default
    config.shouldUseExtendedBackgroundIdleMode = false

    let session = URLSession(configuration: config)
    let task = session.dataTask(with: request) { data, response, error in
        guard let data = data else {
            print("Error: No data returned")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                var name : String
                guard let description = json["description"] as? String else { return }
                guard let tags = json["tags"] as? [String] else { return }
                if tags.isEmpty { name = description}
                else { name = tags[0] }
                
                guard let startingTime = json["start"] as? String else { return }
                let result = times(startingTime: startingTime)
                
                currentTimer = "\(name) \(result.displayString)"
                completion(currentTimer, result.sleepTime)
            } else {
                print("Error: Invalid JSON format")
            }
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
    }
    
    task.resume()
}

func times(startingTime: String) -> (displayString: String, sleepTime: Int) {
    let utcTimeZone = TimeZone(identifier: "UTC")!
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = utcTimeZone
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    let startTimeString = String(startingTime.replacingOccurrences(of: "T", with: " ", options: .literal, range: nil).dropLast(6))
    
    let currentDate = Date()
    let currentTimeString = dateFormatter.string(from: currentDate)

    guard let startTime = dateFormatter.date(from: startTimeString),
          let endTime = dateFormatter.date(from: currentTimeString) else {
        return ("Error: Invalid date format", -1)
    }

    let duration = endTime.timeIntervalSince(startTime)
    let hours = Int(duration)/Int(3600) % Int(3600)
    let minutes = Int(duration)/Int(60) % Int(60)
    let durstr = String(format: "(%01d:%02d)", hours, minutes)
    let sleeptime = Int(60) - Int(duration) % Int(60)
    
    return (displayString: durstr, sleepTime: sleeptime)
}
