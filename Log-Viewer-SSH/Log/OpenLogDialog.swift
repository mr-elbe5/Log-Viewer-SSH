/*
 Log-Viewer
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa
import Citadel

public class OpenLogDialog: NSWindowController, NSWindowDelegate {
    
    var logData: LogData{
        (contentViewController as! OpenLogViewController).logData
    }
    
    init(){
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 200), styleMask: [.closable, .titled, .resizable], backing: .buffered, defer: false)
        window.title = "Open Remote Log File"
        super.init(window: window)
        self.window?.delegate = self
        let controller = OpenLogViewController()
        contentViewController = controller
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func windowDidLoad() {
        super.windowDidLoad()
        window?.makeKeyAndOrderFront(nil)
    }
    
    public func windowWillClose(_ notification: Notification) {
        NSApp.stopModal(withCode: logData.isValid ? .OK : .cancel)
    }

}

class OpenLogViewController: ViewController {
    
    var logData = LogData()
    
    let scrollView = NSScrollView()
    let contentView = NSView()
    
    var serverField = NSTextField(string: "")
    var portField = NSTextField(string: String(22))
    var userField = NSTextField(string: "")
    var passwordField = NSSecureTextField(string: "")
    var pathField = NSTextField(string: "")
    
    var openButton: NSButton? = nil
    
    override public func loadView() {
        view = NSView()
        view.frame = CGRect(x: 0, y: 0, width: 600, height: 400)
        
        scrollView.asVerticalScrollView(inView: view, contentView: contentView)
        var lastAnchor: NSLayoutYAxisAnchor = contentView.topAnchor
        let documents = LogHistory.shared.logHistory
        if documents.isEmpty{
            let label = NSTextField(labelWithString: "There are no recent files")
            contentView.addSubview(label)
            label.placeBelow(anchor: contentView.topAnchor, insets: Insets.defaultInsets)
            lastAnchor = label.bottomAnchor
        }
        else{
            for document in documents{
                let button = NSButton(title: document.path, target: self, action: #selector(openRecent))
                contentView.addSubview(button)
                button.placeBelow(anchor: lastAnchor, insets: Insets.defaultInsets)
                button.refusesFirstResponder = true
                lastAnchor = button.bottomAnchor
            }
        }
        
        let grid = NSGridView()
        grid.addLabeledRow(label: "Server:", views: [serverField])
        grid.addLabeledRow(label: "Port:", views: [portField])
        grid.addLabeledRow(label: "User:", views: [userField])
        grid.addLabeledRow(label: "Password:", views: [passwordField])
        grid.addLabeledRow(label: "Path:", views: [pathField])
        
        view.addSubview(grid)
        grid.placeBelow(anchor: lastAnchor)
        
        let testRemoteButton = NSButton(title: "Test remote", target: self, action: #selector(testRemote))
        view.addSubview(testRemoteButton)
        testRemoteButton.setAnchors()
            .top(grid.bottomAnchor, inset: 2*Insets.defaultInset)
            .trailing(view.centerXAnchor, inset: 2*Insets.defaultInset)
        testRemoteButton.refusesFirstResponder = true
        
        let openRemoteButton = NSButton(title: "Open remote", target: self, action: #selector(openRemote))
        view.addSubview(openRemoteButton)
        openRemoteButton.setAnchors()
            .top(grid.bottomAnchor, inset: 2*Insets.defaultInset)
            .leading(view.centerXAnchor, inset: 2*Insets.defaultInset)
        openRemoteButton.refusesFirstResponder = true
        openRemoteButton.isEnabled = false
        self.openButton = openRemoteButton
        
        let openLocalButton = NSButton(title: "Open local...", target: self, action: #selector(openLocal))
        view.addSubview(openLocalButton)
        openLocalButton.placeBelow(anchor: openRemoteButton.bottomAnchor, insets: Insets.doubleInsets)
        openLocalButton.refusesFirstResponder = true
        openLocalButton.bottom(view.bottomAnchor, inset: 2*Insets.defaultInset)
    }
    
    func readValues(){
        logData.sshServer = serverField.stringValue
        logData.sshPort = Int(portField.intValue)
        logData.sshUser = userField.stringValue
        logData.sshPassword = passwordField.stringValue
        logData.path = pathField.stringValue
    }
    
    @objc open func openRecent(){
        
    }
    
    @objc open func testRemote(){
        readValues()
        if !logData.isValidRemote{
            return
        }
        logData.remoteConnectionTest(){ result in
            DispatchQueue.main.async {
                self.openButton?.isEnabled = result
            }
        }
    }
    
    @objc open func openRemote(){
        NSApp.stopModal(withCode: logData.isValidRemote ? .OK : .cancel)
    }
    
    @objc open func openLocal(){
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        if NSApp.runModal(for: panel) == .OK, let url = panel.urls.first{
            self.logData.reset()
            self.logData.path = url.path
            view.window?.close()
        }
    }
    
}


