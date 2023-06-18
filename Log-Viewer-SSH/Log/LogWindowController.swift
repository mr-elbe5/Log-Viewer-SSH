/*
 Log-Viewer-SSH
 Copyright (C) 2023 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa

protocol LogWindowDelegate{
    func openDocument(sender: LogWindowController?)
    func newWindowForTab(from: LogWindowController)
}

class LogWindowController: NSWindowController {
    
    let mainWindowToolbarIdentifier = NSToolbar.Identifier("MainWindowToolbar")
    let toolbarItemOpen = NSToolbarItem.Identifier("ToolbarOpenItem")
    let toolbarItemClear = NSToolbarItem.Identifier("ToolbarClearItem")
    let toolbarItemReload = NSToolbarItem.Identifier("ToolbarReloadItem")
    let toolbarItemStart = NSToolbarItem.Identifier("ToolbarStartItem")
    let toolbarItemPause = NSToolbarItem.Identifier("ToolbarPauseItem")
    let toolbarItemGlobalPreferences = NSToolbarItem.Identifier("ToolbarGlobalPreferencesItem")
    let toolbarItemDocumentPreferences = NSToolbarItem.Identifier("ToolbarDocumentPreferencesItem")
    let toolbarItemStore = NSToolbarItem.Identifier("ToolbarStoreItem")
    let toolbarItemHelp = NSToolbarItem.Identifier("ToolbarHelpItem")

    var delegate : LogWindowDelegate? = nil
    
    var logViewController : LogViewController {
        get{
            contentViewController as! LogViewController
        }
    }
    
    var logDocument : LogDocument? {
        get{
            logViewController.logDocument
        }
    }
    
    init(document: LogDocument? = nil){
        let window = NSWindow(contentRect: LogPool.defaultRect, styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: true)
        window.title = "Log-Viewer-SSH"
        window.tabbingMode = GlobalPreferences.shared.useTabs ? .preferred : .automatic
        super.init(window: window)
        self.window?.delegate = self
        addToolbar()
        setupViewController(document: document)
        if GlobalPreferences.shared.rememberWindowFrame, let logDocument = document{
            self.window?.setFrameUsingName(logDocument.logData.id)
        }
    }
    
    func setDocument(document: LogDocument){
        window?.title = document.logData.displayName
        logViewController.setDocument(logDocument: document)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViewController(document: LogDocument?){
        let viewController = LogViewController(logDocument: document)
        contentViewController = viewController
    }
    
}

extension LogWindowController: NSWindowDelegate{
    
    func windowWillClose(_ notification: Notification) {
        if GlobalPreferences.shared.rememberWindowFrame, let logDocument = logDocument{
            window?.saveFrame(usingName: logDocument.logData.id)
        }
    }
    
    override public func newWindowForTab(_ sender: Any?) {
        delegate?.newWindowForTab(from: self)
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        updateStartPause()
    }
}

