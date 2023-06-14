/*
 Log-Viewer
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation
import Cocoa

class LocalLogFile: LogFile{
    
    var isValid: Bool{
        logData.isValid
    }
    
    private var fileHandle: FileHandle? = nil
    private var eventSource: DispatchSourceFileSystemObject? = nil
    
    override init(logData: LogData){
        super.init(logData: logData)
    }
    
    override func releaseLogSource(){
        releaseEventSource()
        fileHandle = nil
    }
    
    // running on background thread
    override func load() async throws {
        if FileManager.default.fileExists(atPath: logData.path), let url = logData.url{
            preferences = GlobalPreferences.shared.getDocumentPreferences(url: url)
            fileHandle = try FileHandle(forReadingFrom: url)
            Log.debug("start read")
            if GlobalPreferences.shared.showFullFile, let data = fileHandle?.readDataToEndOfFile(){
                appendChunks(data: data)
            }
            Log.debug("end read")
            setEventSource()
        }
    }
    
    func setEventSource(){
        if let fileHandle = fileHandle{
            let eventSource = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: fileHandle.fileDescriptor,
                eventMask: .extend,
                queue: DispatchQueue.main
            )
            eventSource.setEventHandler {
                let event = eventSource.data
                self.processEvent(event: event)
            }
            eventSource.setCancelHandler {
                if #available(macOS 10.15, *){
                    try? fileHandle.close()
                }
                else{
                    fileHandle.closeFile()
                }
            }
            fileHandle.seekToEndOfFile()
            eventSource.resume()
            self.eventSource = eventSource
        }
    }
    
    func releaseEventSource(){
        eventSource?.cancel()
        eventSource = nil
    }
    
    // running on background thread
    func processEvent(event: DispatchSource.FileSystemEvent) {
        guard event.contains(.extend) else {
            return
        }
        if let data = fileHandle?.readDataToEndOfFile(){
            appendChunks(data: data)
            DispatchQueue.main.async {
                self.delegate?.logChanged()
            }
        }
    }
      
}

