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

class RemoteLogFile: LogFile{
    
    var isValid: Bool{
        logData.isValidRemote
    }
    
    var client: SSHClient? = nil
    
    override init(logData: LogData){
        super.init(logData: logData)
    }
    
    // running on background thread
    override func load() async throws{
        if let client = try await SSHClient.connect(server: self.logData.sshServer, port: self.logData.sshPort, user: self.logData.sshUser, password: self.logData.sshPassword){
            let streams = try await client.executeCommandStream("tail  -f " + logData.path)
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
    
    override func releaseLogSource(){
        Task(priority: .background){
            try await client?.close()
        }
    }
      
}

