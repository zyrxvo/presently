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
    var counter = 0
    var sleepTimer = 0
    var windowController: NSWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        if let button = statusItem.button {
            
            button.title = "Presently"
            button.action = #selector(showMenu(_:))
            
            updateTimer()
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
            self.timer.tolerance = 5
            RunLoop.current.add(self.timer, forMode: .common)
//            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.count), userInfo: nil, repeats: true)
//            RunLoop.current.add(self.timer, forMode: .common)
        }
    }
    
    @objc func showMenu(_ sender: Any?) {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(self.updateTimer), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
    }
    
    @objc func count() {
        counter += 1
        print(counter)
    }
    
    @objc func updateTimer() {
        if let button = statusItem.button {
            query { currentTimer, sleepInterval in
                self.sleepTimer = sleepInterval ?? 0
                if let currentTimer = currentTimer {
                    DispatchQueue.main.async {
                        button.title = currentTimer
                    }
                } else {
                    print("Error: Unable to retrieve current timer")
                }
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

