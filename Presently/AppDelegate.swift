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
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    var timer = Timer()
    var dockIconMenuItem = NSMenuItem(title: "Hide Dock Icon", action: #selector(toggleDockIcon), keyEquivalent: "d")
    var repeatingTimer = Timer()
    var counter = 0
    var sleepTimer = -100
    var windowController: NSWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        defaults.synchronize()
        let iconIsHidden = defaults.bool(forKey: "hideDockIcon")
        if iconIsHidden { NSApp.setActivationPolicy(.accessory) }
        else { NSApp.setActivationPolicy(.regular) }
        
        guard let button = statusItem.button else { return }
            
        button.title = "Presently"
        button.action = #selector(showMenu(_:))
        
        Task.detached {
            let interval = await self.update()
        }
            
//            updateTimer()
//            print("\(self.sleepTimer)")
//            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
//            self.timer.tolerance = 5
//            RunLoop.current.add(self.timer, forMode: .common)
//            self.initialTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.count), userInfo: nil, repeats: true)
//            RunLoop.current.add(self.initialTimer, forMode: .common)
    }
    
    @objc func test() {
        print("Executed!")
        print("\(self.sleepTimer)")
    }
    
    @objc func count() {
        counter += 1
        print(":-> \(counter)")
    }
    
    @objc func toggleDockIcon() {
        defaults.synchronize()
        let iconIsHidden = defaults.bool(forKey: "hideDockIcon")
        if iconIsHidden {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            defaults.set(false, forKey: "hideDockIcon")
            self.dockIconMenuItem.title = "Hide Dock Icon"
        }
        else {
            NSApp.setActivationPolicy(.accessory)
            defaults.set(true, forKey: "hideDockIcon")
            self.dockIconMenuItem.title = "Show Dock Icon"
        }
        defaults.synchronize()
    }
    
    @objc func showMenu(_ sender: Any?) {
        print(self.dockIconMenuItem.title)
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(self.updateTimer), keyEquivalent: "r"))
        menu.addItem(self.dockIconMenuItem)
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
    }
    
    @objc func update() async -> Int {
        counter += 1
        print("Update \(counter)")
        timer.invalidate()
        var interval = 0
        do {
            let result = try await query2()
            if let button = statusItem.button {
                DispatchQueue.main.async {
                    button.title = result.0
                }
            }
            interval = result.1
        } catch {
            print("Error")
        }
        return interval
    }
    
    @objc func updateTimer() {
        if let button = statusItem.button {
            query { currentTimer, sleepInterval in
//                self.sleepTimer = sleepInterval ?? 0
//                print("Processed: \(sleepInterval ?? -5)")
//                self.initialTimer = Timer.scheduledTimer(timeInterval: TimeInterval(sleepInterval ?? 0), target: self, selector: #selector(self.test), userInfo: nil, repeats: false)
                if let currentTimer = currentTimer {
                    DispatchQueue.main.async {
                        button.title = currentTimer
                    }
                } else {
                    print("Error: Unable to retrieve current timer")
                }
                if let sleepInterval = sleepInterval {
                    if sleepInterval < 60 {
                        print("S: \(sleepInterval)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(sleepInterval - 1)) {
                            print("Timer fired!")
                            self.repeatingTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
                            RunLoop.current.add(self.repeatingTimer, forMode: .common)
                        }
                    }
                }
                else {
                    print("Error: No time interval given")
                }
            }
        }
    }

//    @objc func showSettingsWindow() {
//        if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "Presently" }) {
//            // The settings window is already open, so just bring it to the front
//            window.makeKeyAndOrderFront(nil)
//        } else {
//            // The settings window is not open, so create and show a new instance
//            let storyboard = NSStoryboard(name: "Main", bundle: nil)
//            let settingsWindowController = storyboard.instantiateController(withIdentifier: "ViewController") as! NSWindowController
//            settingsWindowController.showWindow(nil)
//        }
//    }
    @objc func showSettingsWindow() {
        if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "Presently" }) {
            // The settings window is already open, so just bring it to the front
            window.makeKeyAndOrderFront(nil)
        } else {
            // The settings window is not open, so create and show a new instance
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            if let settingsWindowController = storyboard.instantiateInitialController() as? NSWindowController {
                settingsWindowController.showWindow(nil)
            }
        }
    }

    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

