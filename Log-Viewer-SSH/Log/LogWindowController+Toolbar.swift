/*
 Log-Viewer
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa

extension LogWindowController: NSToolbarDelegate {
    
    func addToolbar(){
        let toolbar = NSToolbar(identifier: mainWindowToolbarIdentifier)
        toolbar.delegate = self
        toolbar.allowsUserCustomization = false
        toolbar.autosavesConfiguration = false
        toolbar.displayMode = .iconAndLabel
        self.window?.toolbar = toolbar
        self.window?.toolbar?.validateVisibleItems()
    }
    
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem?
    {
        if  itemIdentifier == toolbarItemOpen {
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(openFile)
            toolbarItem.label = "Open File"
            toolbarItem.paletteLabel = "Open File"
            toolbarItem.toolTip = "Open new file"
            if #available(macOS 11.0, *){
                toolbarItem.image = NSImage(systemSymbolName: "plus.circle", accessibilityDescription: "")
            }
            else{
                toolbarItem.image = NSImage(named: "plus.circle")
            }
            return toolbarItem
        }
        
        if  itemIdentifier == toolbarItemClear {
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(clearView)
            toolbarItem.label = "Clear View"
            toolbarItem.paletteLabel = "Clear View"
            toolbarItem.toolTip = "Clear view and proceed with incoming messages"
            if #available(macOS 11.0, *){
                toolbarItem.image = NSImage(systemSymbolName: "xmark.circle", accessibilityDescription: "")
            }
            else{
                toolbarItem.image = NSImage(named: "xmark.circle")
            }
            return toolbarItem
        }
        
        if  itemIdentifier == toolbarItemReload {
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(reloadView)
            toolbarItem.label = "Reload File"
            toolbarItem.paletteLabel = "Reload File"
            toolbarItem.toolTip = "Reload File"
            if #available(macOS 11.0, *){
                toolbarItem.image = NSImage(systemSymbolName: "arrow.clockwise.circle", accessibilityDescription: "")
            }
            else{
                toolbarItem.image = NSImage(named: "arrow.clockwise.circle")
            }
            return toolbarItem
        }
        
        if  itemIdentifier == toolbarItemStart {
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(start)
            toolbarItem.label = "Start Following"
            toolbarItem.paletteLabel = "Start Following"
            toolbarItem.toolTip = "Follow changes of the log file"
            if #available(macOS 11.0, *){
                toolbarItem.image = NSImage(systemSymbolName: "play.circle", accessibilityDescription: "")
            }
            else{
                toolbarItem.image = NSImage(named: "play.circle")
            }
            return toolbarItem
        }
        
        if  itemIdentifier == toolbarItemPause {
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(pause)
            toolbarItem.label = "Pause Following"
            toolbarItem.paletteLabel = "Pause Following"
            toolbarItem.toolTip = "Pause following the log file"
            if #available(macOS 11.0, *){
                toolbarItem.image = NSImage(systemSymbolName: "pause.circle", accessibilityDescription: "")
            }
            else{
                toolbarItem.image = NSImage(named: "pause.circle")
            }
            return toolbarItem
        }
        
        if  itemIdentifier == toolbarItemGlobalPreferences {
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(openGlobalPreferences)
            toolbarItem.label = "Global Preferences"
            toolbarItem.paletteLabel = "Global Preferences"
            toolbarItem.toolTip = "Set global preferences and colors"
            if #available(macOS 11.0, *){
                toolbarItem.image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: "")
            }
            else{
                toolbarItem.image = NSImage(named: "gearshape")
            }
            return toolbarItem
        }
        
        if  itemIdentifier == toolbarItemDocumentPreferences {
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(openDocumentPreferences)
            toolbarItem.label = "Document Preferences"
            toolbarItem.paletteLabel = "Document Preferences"
            toolbarItem.toolTip = "Set document log preferences"
            if #available(macOS 11.0, *){
                toolbarItem.image = NSImage(systemSymbolName: "doc.badge.gearshape", accessibilityDescription: "")
            }
            else{
                toolbarItem.image = NSImage(named: "doc.badge.gearshape")
            }
            return toolbarItem
        }
        
        if  itemIdentifier == toolbarItemStore {
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(openStore)
            toolbarItem.label = "Tip"
            toolbarItem.paletteLabel = "Tip"
            toolbarItem.toolTip = "Leave a tip for the developer"
            if #available(macOS 11.0, *){
                toolbarItem.image = NSImage(systemSymbolName: "giftcard", accessibilityDescription: "")
            }
            else{
                toolbarItem.image = NSImage(named: "giftcard")
            }
            return toolbarItem
        }
        
        if  itemIdentifier == toolbarItemHelp {
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(openHelp)
            toolbarItem.label = "Help"
            toolbarItem.paletteLabel = "Help"
            toolbarItem.toolTip = "Help"
            if #available(macOS 11.0, *){
                toolbarItem.image = NSImage(systemSymbolName: "questionmark.circle", accessibilityDescription: "")
            }
            else{
                toolbarItem.image = NSImage(named: "questionmark.circle")
            }
            return toolbarItem
        }
    
        return nil
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            toolbarItemOpen,
            toolbarItemClear,
            toolbarItemReload,
            toolbarItemPause,
            toolbarItemGlobalPreferences,
            toolbarItemDocumentPreferences,
            toolbarItemStore,
            toolbarItemHelp
        ]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [toolbarItemOpen,
         toolbarItemClear,
         toolbarItemReload,
         toolbarItemStart,
         toolbarItemPause,
         toolbarItemGlobalPreferences,
         toolbarItemDocumentPreferences,
         toolbarItemStore,
         toolbarItemHelp,
         NSToolbarItem.Identifier.space,
         NSToolbarItem.Identifier.flexibleSpace]
    }
    
    @objc func openFile() {
        delegate?.openDocument(sender: self)
    }
    
    @objc func clearView() {
        documentViewController.clear()
    }
    
    @objc func reloadView() {
        documentViewController.reloadFullFile()
    }
    
    @objc func openGlobalPreferences() {
        let controller = GlobalPreferencesWindowController()
        controller.centerInWindow(outerWindow: window)
        NSApp.runModal(for: controller.window!)
    }
    
    @objc func openDocumentPreferences() {
        let controller = DocumentPreferencesWindowController(log: logDocument)
        controller.centerInWindow(outerWindow: window)
        NSApp.runModal(for: controller.window!)
    }
    
    @objc func openStore() {
        let controller = StoreWindowController()
        controller.centerInWindow(outerWindow: window)
        NSApp.runModal(for: controller.window!)
    }
    
    @objc func openHelp() {
        let controller = HelpWindowController()
        controller.centerInWindow(outerWindow: window)
        NSApp.runModal(for: controller.window!)
    }
    
    @objc func start() {
        documentViewController.follow = true
        documentViewController.updateFromDocument()
        if let toolbar = window?.toolbar{
            toolbar.removeItem(at: 3)
            toolbar.insertItem(withItemIdentifier: toolbarItemPause, at: 3)
        }
    }
    
    @objc func pause() {
        documentViewController.follow = false
        if let toolbar = window?.toolbar{
            toolbar.removeItem(at: 3)
            toolbar.insertItem(withItemIdentifier: toolbarItemStart, at: 3)
        }
    }
    
    func updateStartPause(){
        if let toolbar = window?.toolbar{
            toolbar.removeItem(at: 3)
            if documentViewController.follow{
                toolbar.insertItem(withItemIdentifier: toolbarItemPause, at: 3)
            }
            else{
                toolbar.insertItem(withItemIdentifier: toolbarItemStart, at: 3)
            }
        }
    }
    
}


