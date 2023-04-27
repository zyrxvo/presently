//
//  Caller.swift
//  Presently
//
//  Created by Garett Brown on 2023-04-26.
//

import Foundation
import Cocoa

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

func fetch(url: URL, request: URLRequest) async throws -> Data {
    let config = URLSessionConfiguration.default
    config.shouldUseExtendedBackgroundIdleMode = false
    let session = URLSession(configuration: config)

    do {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            print("Error: Non-200 status code returned")
            return Data()
        }
        // process data
        return data
    } catch {
        print("Error: \(error)")
    }
    return Data()
}

func query() async throws -> (String, Int) {
    let defaults = UserDefaults.standard
    defaults.synchronize()
    guard let apiKey = defaults.string(forKey: "APIKey") else { throw NSError(domain: "Missing API Key", code: 0, userInfo: nil) }
    guard let url = URL(string: "https://api.track.toggl.com/api/v9/me/time_entries/current") else { throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)}
    
    let loginData = "\(apiKey):api_token".data(using: .utf8)!
    let base64LoginData = loginData.base64EncodedString()
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    var currentTimer = "Test"
    do {
        let data = try await fetch(url: url, request: request)
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                var name : String
                guard let description = json["description"] as? String else { throw NSError(domain: "Toggl entry is missing description", code: 0, userInfo: nil) }
                guard let tags = json["tags"] as? [String] else { throw NSError(domain: "Toggl entry is missing tags", code: 0, userInfo: nil) }
                if tags.isEmpty { name = description}
                else { name = tags[0] }
                
                guard let startingTime = json["start"] as? String else { throw NSError(domain: "Toggl entry is missing start time", code: 0, userInfo: nil) }
                let result = times(startingTime: startingTime)
                
                currentTimer = "\(name) \(result.displayString)"
                return (currentTimer, result.sleepTime)
            } else {
                throw NSError(domain: "Invalid JSON format", code: 0, userInfo: nil)
            }
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    } catch {
        // handle error
    }
    
    return ("Failed", 0)
}
