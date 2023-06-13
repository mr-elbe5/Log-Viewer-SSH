/*
 Log-Viewer
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa


class DocumentPreferencesWindowController: NSWindowController, NSWindowDelegate {
    
    var logDocument : LogFile
    
    var observer : NSKeyValueObservation? = nil
    
    init(log: LogFile){
        logDocument = log
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 500, height: 310), styleMask: [.closable, .titled, .resizable], backing: .buffered, defer: false)
        window.title = "Document Preferences"
        super.init(window: window)
        self.window?.delegate = self
        let controller = DocumentPreferencesViewController()
        controller.logDocument = logDocument
        contentViewController = controller
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        window?.level = .statusBar
    }
    func windowWillClose(_ notification: Notification) {
        NSApp.stopModal()
    }

}
