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
    
    var sshServer: String
    var sshPort: Int
    var sshUser: String
    var sshPassword: String
    var path: String
    
    var isValid: Bool{
        !sshServer.isEmpty && !sshUser.isEmpty && !sshPassword.isEmpty && !path.isEmpty
    }
    
    var client: SSHClient? = nil
    
    init(server: String, port: Int = 22, user: String, password: String, path: String){
        self.sshServer = server
        self.sshPort = port
        self.sshUser = user
        self.sshPassword = password
        self.path = path
        super.init()
    }
    
    override func load() {
        Task{
            client = try await SSHConnection().connect(server: self.sshServer, port: self.sshPort, user: self.sshUser, password: self.sshPassword)
            if let client = client{
                var buffer = try await client.executeCommand("tail -f " + self.path)
                if let bytes = buffer.readBytes(length: buffer.readableBytes), !bytes.isEmpty{
                    appendChunks(bytes: bytes)
                }
            }
        }
    }
    
    override func releaseLogSource(){
        Task{
            try await client?.close()
        }
    }
      
}

