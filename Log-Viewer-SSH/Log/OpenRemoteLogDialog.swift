/*
 Log-Viewer
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa
import Citadel

public class OpenRemoteLogDialog: NSWindowController, NSWindowDelegate {
    
    var sshServer: String{
        (contentViewController as! OpenRemoteLogViewController).sshServer
    }
    var sshPort: Int{
        (contentViewController as! OpenRemoteLogViewController).sshPort
    }
    var sshUser: String{
        (contentViewController as! OpenRemoteLogViewController).sshUser
    }
    var sshPassword: String{
        (contentViewController as! OpenRemoteLogViewController).sshPassword
    }
    var path: String{
        (contentViewController as! OpenRemoteLogViewController).path
    }
    
    var isValid: Bool{
        !sshServer.isEmpty && !sshUser.isEmpty && !sshPassword.isEmpty && !path.isEmpty
    }
    
    init(){
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 200), styleMask: [.closable, .titled, .resizable], backing: .buffered, defer: false)
        window.title = "Open Remote Log File"
        super.init(window: window)
        self.window?.delegate = self
        let controller = OpenRemoteLogViewController()
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
        NSApp.stopModal(withCode: isValid ? .OK : .cancel)
    }

}

class OpenRemoteLogViewController: ViewController {
    
    var sshServer: String = ""
    var sshPort: Int = 22
    var sshUser: String = ""
    var sshPassword: String = ""
    var path: String = ""
    
    var isValid: Bool{
        !sshServer.isEmpty && !sshUser.isEmpty && !sshPassword.isEmpty && !path.isEmpty
    }
    
    var serverField = NSTextField(string: "")
    var portField = NSTextField(string: String(22))
    var userField = NSTextField(string: "")
    var passwordField = NSSecureTextField(string: "")
    var pathField = NSTextField(string: "")
    
    var openButton: NSButton? = nil
    
    override public func loadView() {
        view = NSView()
        view.frame = CGRect(x: 0, y: 0, width: 600, height: 200)
        
        let grid = NSGridView()
        grid.addLabeledRow(label: "Server:", views: [serverField])
        grid.addLabeledRow(label: "Port:", views: [portField])
        grid.addLabeledRow(label: "User:", views: [userField])
        grid.addLabeledRow(label: "Password:", views: [passwordField])
        grid.addLabeledRow(label: "Path:", views: [pathField])
        
        view.addSubview(grid)
        grid.placeBelow(anchor: view.topAnchor)
        
        let testButton = NSButton(title: "Test", target: self, action: #selector(test))
        view.addSubview(testButton)
        testButton.setAnchors()
            .top(grid.bottomAnchor, inset: 2*Insets.defaultInset)
            .trailing(view.centerXAnchor, inset: 2*Insets.defaultInset)
        testButton.refusesFirstResponder = true
        testButton.bottom(view.bottomAnchor, inset: 2*Insets.defaultInset)
        
        let openButton = NSButton(title: "Open", target: self, action: #selector(open))
        view.addSubview(openButton)
        openButton.setAnchors()
            .top(grid.bottomAnchor, inset: 2*Insets.defaultInset)
            .leading(view.centerXAnchor, inset: 2*Insets.defaultInset)
        openButton.refusesFirstResponder = true
        openButton.bottom(view.bottomAnchor, inset: 2*Insets.defaultInset)
        openButton.isEnabled = false
        self.openButton = openButton
    }
    
    func readValues(){
        sshServer = serverField.stringValue
        sshPort = Int(portField.intValue)
        sshUser = userField.stringValue
        sshPassword = passwordField.stringValue
        path = pathField.stringValue
    }
    
    @objc open func test(){
        readValues()
        if !isValid{
            return
        }
        SSHClient.connectionTest(server: sshServer, port: sshPort, user: sshUser, password: sshPassword, path: path){ result in
            DispatchQueue.main.async {
                self.openButton?.isEnabled = result
            }
        }
    }
    
    @objc open func open(){
        NSApp.stopModal(withCode: isValid ? .OK : .cancel)
    }
    
}


