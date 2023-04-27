//
//  AppDelegate.swift
//  Presently
//
//  Created by Garett Brown on 2023-04-25.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let defaults = UserDefaults.standard
    let statusItem = NSStatusBar.system.self.statusItem(withLength:NSStatusItem.variableLength)
    var dockIconMenuItem = NSMenuItem(title: "Hide Dock Icon", action: #selector(toggleDockIcon), keyEquivalent: "d")
    var counter = 0
    
    let semaphore = DispatchSemaphore(value: 1)
    var shouldRestartLoop = false

 
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.defaults.synchronize()
        let iconIsHidden = self.defaults.bool(forKey: "hideDockIcon")
        if iconIsHidden {
            NSApp.setActivationPolicy(.accessory)
            self.dockIconMenuItem.title = "Show Dock Icon"
        }
        else {
            NSApp.setActivationPolicy(.regular)
            self.dockIconMenuItem.title = "Hide Dock Icon"
        }
        guard let button = self.statusItem.button else { return }
            
        button.title = "Presently"
        button.action = #selector(showMenu(_:))
        
        Task.detached {
            await self.repeatedlyMakeAPICall()
        }
    }
    
    
    @objc func toggleDockIcon() {
        self.defaults.synchronize()
        let iconIsHidden = self.defaults.bool(forKey: "hideDockIcon")
        if iconIsHidden {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            self.defaults.set(false, forKey: "hideDockIcon")
            self.dockIconMenuItem.title = "Hide Dock Icon"
        }
        else {
            NSApp.setActivationPolicy(.accessory)
            self.defaults.set(true, forKey: "hideDockIcon")
            self.dockIconMenuItem.title = "Show Dock Icon"
        }
        self.defaults.synchronize()
    }
    
    @objc func showMenu(_ sender: Any?) {
        print(self.dockIconMenuItem.title)
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(self.refresh), keyEquivalent: "r"))
        menu.addItem(self.dockIconMenuItem)
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        self.statusItem.menu = menu
        self.statusItem.button?.performClick(nil)
    }
    @IBAction func refreshKey(_ sender: Any) {
        self.refresh()
    }
    
    @objc func refresh() {
        // When you want to manually interrupt the loop, you can set the shouldRestartLoop variable to true
        shouldRestartLoop = true

        // When you want to restart the loop, you can call the repeatedlyMakeAPICall function again in a detached task
        Task.detached {
            await self.repeatedlyMakeAPICall()
        }
    }
    
    @objc func update() async -> Int {
        print("Called Update \(self.counter)")
        self.counter += 1
        var interval = 0
        do {
            let result = try await query()
            if let button = self.statusItem.button {
                DispatchQueue.main.async {
                    button.title = result.0
                }
            }
            interval = result.1
        } catch {
            print("Error")
        }
        print("Interval \(interval)")
        return interval
    }
    
    // Define a function that makes an API call and returns the wait time
    func makeAPICall() async -> TimeInterval {
        // Wait for the semaphore to become available
        semaphore.wait()
        defer {
            // Release the semaphore when we're done
            semaphore.signal()
        }
        
        let waitTime = await TimeInterval(update())
        return waitTime
    }

    // Define a function that waits for the specified time interval
    func wait(_ timeInterval: TimeInterval) async {
        do {
            try await Task.sleep(nanoseconds: UInt64(timeInterval * Double(NSEC_PER_SEC)))
        } catch {
            print("Error?")
        }
    }

    // Define a function that repeatedly makes the API call with a dynamic wait time
    func repeatedlyMakeAPICall() async {
        while true {
            let waitTime = await makeAPICall()
            await wait(waitTime)
            
            // Check if we should interrupt the loop and restart it
            if shouldRestartLoop {
                shouldRestartLoop = false
                return
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

