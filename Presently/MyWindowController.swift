//
//  MyWindowController.swift
//  Presently
//
//  Created by Garett Brown on 2023-04-27.
//

import Cocoa

class MyWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        if let screenFrame = NSScreen.main?.visibleFrame {
            let windowFrame = self.window?.frame ?? NSRect.zero
            let x = screenFrame.origin.x + (screenFrame.size.width - windowFrame.size.width) / 2.0
            let y = screenFrame.origin.y + (screenFrame.size.height - windowFrame.size.height) / 2.0
            self.window?.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }
    
}
