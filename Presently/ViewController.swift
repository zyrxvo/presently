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
        print("Success!")
        defaults.set(sender.stringValue, forKey: "APIKey")
        defaults.synchronize()
        print(defaults.string(forKey: "APIKey") ?? "None")
    }
    
    @IBAction func hideDockIcon(_ sender: NSButton) {
    }
}

