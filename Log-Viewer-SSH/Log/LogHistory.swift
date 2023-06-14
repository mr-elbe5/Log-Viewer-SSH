/*
 Log-Viewer
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa

class LogHistory: NSObject, Codable {
    
    static var shared = LogHistory()
    
    static func loadHistory(){
        if let storedString = UserDefaults.standard.value(forKey: "logHistory") as? String {
            if let history : LogHistory = LogHistory.fromJSON(encoded: storedString){
                LogHistory.shared = history
            }
        }
        else{
            print("no saved data available for log history")
            LogHistory.shared = LogHistory()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case frameRect
        case logHistory
    }
    
    var logHistory : Array<LogData>
    
    override init(){
        logHistory = Array<LogData>()
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        logHistory = try values.decodeIfPresent(Array<LogData>.self, forKey: .logHistory) ?? Array<LogData>()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(logHistory, forKey: .logHistory)
    }
    
    func addData(_ data: LogData){
        if !logHistory.contains(where: { $0 == data}){
            logHistory.append(data)
            save()
        }
    }
    
    func save(){
        let storeString = toJSON()
        UserDefaults.standard.set(storeString, forKey: "logHistory")
    }
    
}
