/*
 Log-Viewer-SSH
 Copyright (C) 2023 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa
import Citadel

class LogData: NSObject, Codable {
    
    static func == (lhs: LogData, rhs: LogData) -> Bool {
            lhs.sshServer == rhs.sshServer && lhs.path == rhs.path
        }
    
    enum CodingKeys: String, CodingKey {
        case server
        case port
        case user
        case password
        case path
        case preferences
    }
    
    var sshServer: String = ""
    var sshPort: Int = 22
    var sshUser: String = ""
    var sshPassword: String = ""
    var path: String
    var preferences : DocumentPreferences
    
    var isLocal: Bool{
        sshServer.isEmpty
    }
    
    var url: URL?{
        URL(fileURLWithPath: path, isDirectory: false)
    }
    
    var isValid: Bool{
        !sshServer.isEmpty && !sshUser.isEmpty && !sshPassword.isEmpty && !path.isEmpty
    }
    
    var displayName: String{
        isLocal ?
        "local: \(path)" :
        "ssh: \(sshServer):\(path)"
    }
    
    override init(){
        self.path = ""
        preferences = DocumentPreferences()
        super.init()
    }
    
    init(server: String, port: Int = 22, user: String, password: String, path: String, preferences: DocumentPreferences){
        self.sshServer = server
        self.sshPort = port
        self.sshUser = user
        self.sshPassword = password
        self.path = path
        self.preferences = preferences
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sshServer = try values.decodeIfPresent(String.self, forKey: .server) ?? ""
        sshPort = try values.decodeIfPresent(Int.self, forKey: .port) ?? 22
        sshUser = try values.decodeIfPresent(String.self, forKey: .user) ?? ""
        sshPassword = try values.decodeIfPresent(String.self, forKey: .password) ?? ""
        path = try values.decodeIfPresent(String.self, forKey: .path) ?? ""
        preferences = try values.decodeIfPresent(DocumentPreferences.self, forKey: .preferences) ??  DocumentPreferences()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sshServer, forKey: .server)
        try container.encode(sshPort, forKey: .port)
        try container.encode(sshUser, forKey: .user)
        try container.encode(sshPassword, forKey: .password)
        try container.encode(path, forKey: .path)
        try container.encode(preferences, forKey: .preferences)
    }
    
    func reset(){
        sshServer = ""
        sshPort = 22
        sshUser = ""
        sshPassword = ""
        path = ""
        preferences = DocumentPreferences()
    }
    
    func updatePreferences(from data: LogData){
        preferences = data.preferences
    }
    
    func remoteConnectionTest(oncomplete: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async{
            Task{
                do{
                    var result = false
                    print("starting access test")
                    if let client = try await SSHClient.connect(server: self.sshServer, port: self.sshPort, user: self.sshUser, password: self.sshPassword){
                        var buffer = try await client.executeCommand("tail " + self.path)
                        if let bytes = buffer.readBytes(length: min(10, buffer.readableBytes)), !bytes.isEmpty{
                            buffer.discardReadBytes()
                            result = true
                        }
                        try await client.close()
                        print("access test successful")
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
    
}
