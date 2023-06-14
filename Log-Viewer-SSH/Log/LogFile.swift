/*
 Log-Viewer
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation
import Cocoa

protocol LogDelegate{
    func logChanged()
    func preferencesChanged()
}

class LogFile: NSObject{
    
    var preferences =  DocumentPreferences()
    
    var chunks = [LogChunk]()
    
    var delegate: LogDelegate? = nil
    
    deinit {
        releaseLogSource()
    }
    
    func appendChunks(data: Data){
        let str = String(data: data, encoding: .utf8) ?? ""
        if GlobalPreferences.shared.maxLines != 0{
            chunks.append(LogChunk(str.substr(lines: GlobalPreferences.shared.maxLines)))
        }
        else{
            chunks.append(LogChunk(str))
        }
        DispatchQueue.main.async {
            self.delegate?.logChanged()
        }
    }
    
    func appendChunks(bytes: [UInt8]){
        let str = String(bytes: bytes, encoding: .utf8) ?? ""
        if GlobalPreferences.shared.maxLines != 0{
            chunks.append(LogChunk(str.substr(lines: GlobalPreferences.shared.maxLines)))
        }
        else{
            chunks.append(LogChunk(str))
        }
        DispatchQueue.main.async {
            self.delegate?.logChanged()
        }
    }
    
    func releaseLogSource(){
    }
    
    // running on background thread
    func load() async throws{
    }
    
    func savePreferences(){
        GlobalPreferences.shared.save()
    }

    func displayPreferencesChanged(){
        for chunk in chunks{
            chunk.displayed = false
        }
        delegate?.preferencesChanged()
    }

}

class LogChunk{
    
    var string : String
    var displayed : Bool = false
    
    init(_ string: String){
        self.string = string
    }
    
}
