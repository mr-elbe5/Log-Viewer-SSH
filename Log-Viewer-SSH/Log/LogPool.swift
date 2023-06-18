/*
 Log-Viewer-SSH
 Copyright (C) 2023 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa

class LogPool {
    
    static var defaultSize: NSSize = NSMakeSize(900, 600)
    static var defaultRect: NSRect{
        var x : CGFloat = 0
        var y : CGFloat = 0
        if let screen = NSScreen.main{
            x = screen.frame.width/2 - defaultSize.width/2
            y = screen.frame.height/2 - defaultSize.height/2
        }
        return NSMakeRect(x, y, LogPool.defaultSize.width, LogPool.defaultSize.height)
    }
    
    static var shared = LogPool()
    
    var windowControllers = Array<LogWindowController>()
    
    var mainWindowController: LogWindowController? {
        if windowControllers.isEmpty{
            return nil
        }
        var controller = windowControllers.first { $0.window?.isMainWindow ?? false}
        if controller == nil{
            controller = windowControllers.first
        }
        return controller
    }
    
    var emptyWindowController: LogWindowController? {
        if windowControllers.isEmpty{
            return nil
        }
        return windowControllers.first { $0.logDocument == nil}
    }
    
    var mainWindow: NSWindow? {
        mainWindowController?.window
    }
    
    var mainDocument: LogDocument? {
        mainWindowController?.logDocument
    }
    
    func clearRecentDocuments(_ sender: Any?) {
        GlobalPreferences.shared.resetDocumentPreferences()
        GlobalPreferences.shared.save()
    }
    
    func removeController(controller: LogWindowController){
        controller.logDocument?.releaseLogSource()
        windowControllers.remove(obj: controller)
        if windowControllers.isEmpty{
            NSApplication.shared.terminate(self)
        }
    }
    
    func removeController(forWindow: NSWindow){
        for controller in windowControllers{
            if controller.window == forWindow{
                removeController(controller: controller)
                break
            }
        }
    }
    
}

extension LogPool: LogWindowDelegate{
    
    func openDocument(sender: LogWindowController?) {
        let dialog = OpenLogDialog()
        if NSApp.runModal(for: dialog.window!) == .OK{
            let document = LogDocument(logData: dialog.logData)
            if let controller = emptyWindowController{
                fillEmptyController(controller: controller, with: document)
            }
            else{
                addController(for: document, sender: sender)
            }
            LogHistory.shared.addData(document.logData)
        }
        else if windowControllers.isEmpty{
            NSApplication.shared.terminate(self)
        }
    }
    
    func fillEmptyController(controller: LogWindowController, with document: LogDocument){
        controller.setDocument(document: document)
        Task(priority: .background){
            try await document.load()
        }
    }
    
    func addController(for document: LogDocument?, sender: LogWindowController?) {
        let controller = LogWindowController(document: document)
        registerController(controller: controller)
        if GlobalPreferences.shared.useTabs, let sender = sender{
            sender.window!.addTabbedWindow(controller.window!, ordered: .above)
            controller.window?.makeKeyAndOrderFront(nil)
        }
        else{
            controller.showWindow(nil)
        }
        if let document = document{
            controller.window?.title = document.logData.displayName
            Task(priority: .background){
                try await document.load()
            }
        }
    }
    
    func registerController(controller: LogWindowController) {
        controller.delegate = self
        guard let window = controller.window else {return}
        NotificationCenter.default.addObserver(forName:NSWindow.willCloseNotification, object: window, queue: nil){ [unowned self] notification in
            guard let window = notification.object as? NSWindow else { return }
            self.removeController(forWindow: window)
        }
        windowControllers.append(controller)
    }
    
    func newWindowForTab(from: LogWindowController) {
        openDocument(sender: from)
    }
    
}

final class NotificationToken: NSObject {
    let notificationCenter: NotificationCenter
    let token: Any

    init(notificationCenter: NotificationCenter = .default, token: Any) {
        self.notificationCenter = notificationCenter
        self.token = token
    }

    deinit {
        notificationCenter.removeObserver(token)
    }
}
