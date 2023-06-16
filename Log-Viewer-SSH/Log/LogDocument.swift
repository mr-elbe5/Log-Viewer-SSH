/*
 Log-Viewer
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation
import Cocoa
import Citadel

protocol LogDelegate{
    func logChanged()
    func preferencesChanged()
}

class LogDocument: NSObject{
    
    var logData: LogData
    
    var chunks = [LogChunk]()
    
    var delegate: LogDelegate? = nil
    
    var preferences: DocumentPreferences{
        get{
            logData.preferences
        }
        set{
            logData.preferences = newValue
        }
    }
    
    var isValid: Bool{
        logData.isValid
    }
    
    var client: SSHClient? = nil
    
    init(logData: LogData){
        self.logData = logData
        super.init()
    }
    
    deinit {
        releaseLogSource()
    }
    
    func appendChunks(data: Data, maxLines: Int){
        let str = String(data: data, encoding: .utf8) ?? ""
        if maxLines != 0{
            chunks.append(LogChunk(str.substr(lines: maxLines)))
        }
        else{
            chunks.append(LogChunk(str))
        }
        DispatchQueue.main.async {
            self.delegate?.logChanged()
        }
    }
    
    func appendChunks(bytes: [UInt8], maxLines: Int = 0){
        let str = String(bytes: bytes, encoding: .utf8) ?? ""
        if maxLines != 0{
            //Log.debug("adding max lines: \(GlobalPreferences.shared.maxLines)")
            chunks.append(LogChunk(str.substr(lines: maxLines)))
        }
        else{
            chunks.append(LogChunk(str))
        }
        DispatchQueue.main.async {
            self.delegate?.logChanged()
        }
    }
    
    // running on background thread
    func load() async throws{
        if let client = try await SSHClient.connect(server: self.logData.sshServer, port: self.logData.sshPort, user: self.logData.sshUser, password: self.logData.sshPassword){
            let cmd = "tail  -n\(GlobalPreferences.shared.initialRemoteLines) -f "
            let streams = try await client.executeCommandStream(cmd + logData.path)
            var asyncStreams = streams.makeAsyncIterator()
            while let blob = try await asyncStreams.next() {
                switch blob {
                case .stdout(let stdout):
                    if let bytes = stdout.getBytes(at: 0, length: stdout.readableBytes){
                        self.appendChunks(bytes: bytes)
                    }
                case .stderr(let stderr):
                    if let bytes = stderr.getBytes(at: 0, length: stderr.readableBytes){
                        print(String(bytes: bytes, encoding: .utf8) ?? "")
                    }
                }
            }
            self.client = client
        }
    }
    
    func releaseLogSource(){
        Task(priority: .background){
            try await client?.close()
        }
    }
    
    func savePreferences(){
        LogHistory.shared.updateDataPreferences(from: logData)
        LogHistory.shared.save()
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
