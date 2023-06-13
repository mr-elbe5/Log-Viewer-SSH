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

class SSHConnection{
    
    func connect(server: String, port: Int = 22, user: String, password: String) async throws -> SSHClient?{
        let client = try await SSHClient.connect(
            host: server,
            port: port,
            authenticationMethod: .passwordBased(username: user, password: password),
            hostKeyValidator: .acceptAnything(),
            reconnect: .never
        )
        if client.isConnected{
            return client
        }
        return nil
    }
    
    func connectionTest(server: String, port: Int = 22, user: String, password: String, path: String, oncomplete: @escaping (Bool) -> Void) {
        Task{
            do{
                var result = false
                print("starting test")
                if let client = try await connect(server: server, port: port, user: user, password: password){
                    var buffer = try await client.executeCommand("cat " + path)
                    if let bytes = buffer.readBytes(length: min(10, buffer.readableBytes)), !bytes.isEmpty{
                        buffer.discardReadBytes()
                        result = true
                    }
                    try await client.close()
                    print("ready")
                    oncomplete(result)
                }
            }
            catch let(err){
                print(err)
                oncomplete(false)
            }
        }
    }
}
    
