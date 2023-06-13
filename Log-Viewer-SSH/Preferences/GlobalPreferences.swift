/*
 Log-Viewer
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



protocol PreferencesDelegate {
    func preferencesChanged()
}

class GlobalPreferences: Identifiable, Codable{
    
    static var shared = GlobalPreferences()
    
    static var fontSizes = [10, 12, 14, 16, 18, 20, 24]
    static var numPatterns : Int = 5
    static var defaultMaxLines = 1000
    
    static var defaultTextColorSet : [CodableColor] = [
        CodableColor(red: 0, green: 0, blue: 0),
        CodableColor(red: 0, green: 0, blue: 0),
        CodableColor(red: 0, green: 0, blue: 0),
        CodableColor(red: 0, green: 0, blue: 0),
        CodableColor(red: 0, green: 0, blue: 0)
    ]
    
    static var darkmodeTextColorSet : [CodableColor] = [
        CodableColor(red: 1, green: 1, blue: 0.35), // yellow
        CodableColor(red: 1, green: 0.8, blue: 0.6), // orange
        CodableColor(red: 0.6, green: 1, blue: 0.5), //green
        CodableColor(red: 0.5, green: 1, blue: 1), //cyan
        CodableColor(red: 0.9, green: 0.7, blue: 1) //purple
    ]
    
    static var defaultBackgroundColorSet : [CodableColor] = [
        CodableColor(red: 1, green: 1, blue: 0.35), // yellow]
        CodableColor(red: 1, green: 0.8, blue: 0.6), // orange
        CodableColor(red: 0.6, green: 1, blue: 0.5), //green
        CodableColor(red: 0.5, green: 1, blue: 1), //cyan
        CodableColor(red: 0.9, green: 0.7, blue: 1) //purple
    ]
    
    static var darkmodeBackgroundColorSet : [CodableColor] = [
        CodableColor(red: 0, green: 0, blue: 0),
        CodableColor(red: 0, green: 0, blue: 0),
        CodableColor(red: 0, green: 0, blue: 0),
        CodableColor(red: 0, green: 0, blue: 0),
        CodableColor(red: 0, green: 0, blue: 0)
    ]
    
    enum CodingKeys: String, CodingKey {
        case rememberWindowFrame
        case useTabs
        case showFullFile
        case fontSize
        case showUnmarkedGray
        case caseInsensitive
        case textColors
        case backgroundColors
        case documentPreferences
        case maxLines
    }
    
    var rememberWindowFrame = true
    var useTabs = true
    var showFullFile = true
    var fontSize = 14
    var showUnmarkedGray = true
    var caseInsensitive = true
    var textColors : [CodableColor] = isDarkMode ? darkmodeTextColorSet : defaultTextColorSet
    var backgroundColors : [CodableColor] = isDarkMode ? darkmodeBackgroundColorSet : defaultBackgroundColorSet
    var documentPreferences = [URL: DocumentPreferences]()
    var maxLines = GlobalPreferences.defaultMaxLines

    static var isDarkMode : Bool{
        get{
            UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
        }
    }

    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        rememberWindowFrame = try values.decodeIfPresent(Bool.self, forKey: .rememberWindowFrame) ?? true
        useTabs = try values.decodeIfPresent(Bool.self, forKey: .useTabs) ?? true
        showFullFile = try values.decodeIfPresent(Bool.self, forKey: .showFullFile) ?? true
        fontSize = try values.decodeIfPresent(Int.self, forKey: .fontSize) ?? 14
        showUnmarkedGray = try values.decodeIfPresent(Bool.self, forKey: .showUnmarkedGray) ?? true
        caseInsensitive = try values.decodeIfPresent(Bool.self, forKey: .caseInsensitive) ?? true
        textColors = try values.decodeIfPresent([CodableColor].self, forKey: .textColors) ?? (GlobalPreferences.isDarkMode ? GlobalPreferences.darkmodeTextColorSet : GlobalPreferences.defaultTextColorSet)
        backgroundColors = try values.decodeIfPresent([CodableColor].self, forKey: .backgroundColors) ?? (GlobalPreferences.isDarkMode ? GlobalPreferences.darkmodeBackgroundColorSet : GlobalPreferences.defaultBackgroundColorSet)
        documentPreferences = try values.decodeIfPresent([URL: DocumentPreferences].self, forKey: .documentPreferences) ?? [URL: DocumentPreferences]()
        maxLines = try values.decodeIfPresent(Int.self, forKey: .maxLines) ?? GlobalPreferences.defaultMaxLines
        save()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rememberWindowFrame, forKey: .rememberWindowFrame)
        try container.encode(useTabs, forKey: .useTabs)
        try container.encode(showFullFile, forKey: .showFullFile)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(showUnmarkedGray, forKey: .showUnmarkedGray)
        try container.encode(caseInsensitive, forKey: .caseInsensitive)
        try container.encode(textColors, forKey: .textColors)
        try container.encode(backgroundColors, forKey: .backgroundColors)
        try container.encode(documentPreferences, forKey: .documentPreferences)
        try container.encode(maxLines, forKey: .maxLines)
        
    }
    
    func resetGlobalSettings(){
        rememberWindowFrame = true
        useTabs = true
        showFullFile = true
        fontSize = 14
        showUnmarkedGray = false
        caseInsensitive = true
        maxLines = 0
        textColors = GlobalPreferences.isDarkMode ? GlobalPreferences.darkmodeTextColorSet : GlobalPreferences.defaultTextColorSet
        backgroundColors = GlobalPreferences.isDarkMode ? GlobalPreferences.darkmodeBackgroundColorSet : GlobalPreferences.defaultBackgroundColorSet
    }
    
    func resetDocumentPreferences(){
        documentPreferences.removeAll()
    }
    
    func getDocumentPreferences(url: URL) -> DocumentPreferences{
        if documentPreferences.keys.contains(url){
            return documentPreferences[url]!
        }
        let prefs = DocumentPreferences()
        documentPreferences[url] = prefs
        save()
        return prefs
    }
    
    static func load(){
        if let storedString = UserDefaults.standard.value(forKey: "logPreferences") as? String {
            if let history : GlobalPreferences = GlobalPreferences.fromJSON(encoded: storedString){
                GlobalPreferences.shared = history
            }
        }
        else{
            print("no saved data available for preferences")
            GlobalPreferences.shared = GlobalPreferences()
        }
    }
    
    func save(){
        let storeString = toJSON()
        UserDefaults.standard.set(storeString, forKey: "logPreferences")
    }
}


