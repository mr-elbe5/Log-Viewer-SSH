/*
 Log-Viewer-SSH
 Copyright (C) 2023 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation
import Cocoa

extension NSAlert{

    // returns true if ok was pressed
    static func acceptWarning(message: String) -> Bool{
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = message
        alert.addButton(withTitle: "Ok")
        alert.addButton(withTitle: "Cancel")
        let result = alert.runModal()
        return result == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    static func acceptInfo(message: String){
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = message
        alert.addButton(withTitle: "Ok")
        alert.runModal()
    }
    
    static func showError(message: String){
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = message
        alert.addButton(withTitle: "Ok")
        alert.runModal()
    }

}
