//
//  AppDelegate.swift
//  Presently
//
//  Created by Garett Brown on 2023-04-25.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    var timer = Timer()
    var count = 0
    var windowController: NSWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.title = "00:00:00"
            button.action = #selector(showMenu(_:))
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    @objc func showMenu(_ sender: Any?) {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
    }
    
    @objc func updateTimer() {
        count += 1
        let seconds = count % 60
        let minutes = (count / 60) % 60
        let hours = (count / 3600)
        let title = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        statusItem.button?.title = title
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

