//
//  ViewController.swift
//  Presently
//
//  Created by Garett Brown on 2023-04-25.
//

import Cocoa

class ViewController: NSViewController {
    let defaults = UserDefaults.standard

    @IBOutlet var apiField: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        apiField.bezelStyle = .roundedBezel
        defaults.synchronize()
        apiField.stringValue = defaults.string(forKey: "APIKey") ?? "None"
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func endEditing(_ sender: NSTextField) {
        defaults.set(sender.stringValue, forKey: "APIKey")
        defaults.synchronize()
    }
    
    @IBAction func hideDockIcon(_ sender: NSButton) {
    }
}

