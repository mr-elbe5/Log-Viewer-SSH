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
    
    var serverField = NSTextField(string: "")
    var portField = NSTextField(string: String(22))
    var userField = NSTextField(string: "")
    var passwordField = NSSecureTextField(string: "")
    var pathField = NSTextField(string: "")
    
    var stackView = NSStackView()
    
    var openButton: NSButton? = nil
    
    override public func loadView() {
        view = NSView()
        view.frame = CGRect(x: 0, y: 0, width: 600, height: 400)
        
        let label = NSTextField(labelWithString: "Recent remote logs:")
        view.addSubview(label)
        label.placeBelow(anchor: view.topAnchor)
        
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        view.addSubview(scrollView)
        scrollView.placeBelow(view: label)
        scrollView.height(200)
        let clipView = FlippedClipView()
        scrollView.contentView = clipView
        clipView.fillSuperview(insets: Insets.defaultInsets)
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        clipView.addSubview(stackView)
        stackView.fillSuperview(insets: Insets.defaultInsets)
        let logHistory = LogHistory.shared.logHistory
        if logHistory.isEmpty{
            let nolabel = NSTextField(labelWithString: "There are no recent remote logs")
            stackView.addArrangedSubview(nolabel)
            nolabel.placeBelow(view: label, insets: Insets.defaultInsets)
        }
        else{
            for logData in logHistory{
                let button = RecentLogButton(logData: logData, target: self, action: #selector(openRecent))
                stackView.addArrangedSubview(button)
            }
        }
        
        let clearHistoryButton = NSButton(title: "Clear History", target: self, action: #selector(clearHistory))
        view.addSubview(clearHistoryButton)
        clearHistoryButton.placeBelow(view: scrollView, insets: Insets.defaultInsets)
        clearHistoryButton.refusesFirstResponder = true
        
        let grid = NSGridView()
        view.addSubview(grid)
        grid.placeBelow(view: clearHistoryButton, insets: Insets.doubleInsets)
        grid.addLabeledRow(label: "Server:", views: [serverField])
        grid.addLabeledRow(label: "Port:", views: [portField])
        grid.addLabeledRow(label: "User:", views: [userField])
        grid.addLabeledRow(label: "Password:", views: [passwordField])
        grid.addLabeledRow(label: "Path:", views: [pathField])
        
        let testRemoteButton = NSButton(title: "Test remote file", target: self, action: #selector(testRemote))
        view.addSubview(testRemoteButton)
        testRemoteButton.setAnchors()
            .top(grid.bottomAnchor, inset: 2*Insets.defaultInset)
            .trailing(view.centerXAnchor, inset: 2*Insets.defaultInset)
        testRemoteButton.refusesFirstResponder = true
        
        let openRemoteButton = NSButton(title: "Open remote file", target: self, action: #selector(openRemote))
        view.addSubview(openRemoteButton)
        openRemoteButton.setAnchors()
            .top(grid.bottomAnchor, inset: 2*Insets.defaultInset)
            .leading(view.centerXAnchor, inset: 2*Insets.defaultInset)
        openRemoteButton.refusesFirstResponder = true
        openRemoteButton.isEnabled = false
        self.openButton = openRemoteButton
        
        let openLocalButton = NSButton(title: "Open local file...", target: self, action: #selector(openLocal))
        view.addSubview(openLocalButton)
        openLocalButton.setAnchors()
            .top(testRemoteButton.bottomAnchor, inset: 2*Insets.defaultInset)
            .centerX(view.centerXAnchor)
            .bottom(view.bottomAnchor, inset: 2*Insets.defaultInset)
        openLocalButton.refusesFirstResponder = true
    }
    
    func readValues(){
        logData.sshServer = serverField.stringValue
        logData.sshPort = Int(portField.intValue)
        logData.sshUser = userField.stringValue
        logData.sshPassword = passwordField.stringValue
        logData.path = pathField.stringValue
    }
    
    @objc func clearHistory(){
        for sv in stackView.arrangedSubviews{
            stackView.removeArrangedSubview(sv)
        }
        stackView.removeAllSubviews()
        LogHistory.shared.logHistory.removeAll()
        LogHistory.shared.save()
    }
    
    @objc func openRecent(sender: AnyObject?){
        if let button = sender as? RecentLogButton{
            serverField.stringValue = button.logData.sshServer
            portField.stringValue = String(button.logData.sshPort)
            userField.stringValue = button.logData.sshUser
            passwordField.stringValue = button.logData.sshPassword
            pathField.stringValue = button.logData.path
        }
    }
    
    @objc func testRemote(){
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
    
    @objc func openRemote(){
        NSApp.stopModal(withCode: logData.isValidRemote ? .OK : .cancel)
    }
    
    @objc func openLocal(){
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

class RecentLogButton: NSButton{
    
    var logData: LogData
    
    init(logData: LogData, target: AnyObject?, action: Selector){
        self.logData = logData
        super.init(frame: .zero)
        title = logData.displayName
        self.target = target
        self.action = action
        self.bezelStyle = .roundRect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


