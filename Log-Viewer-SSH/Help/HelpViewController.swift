/*
 Log-Viewer
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa


class HelpViewController: NSViewController {
    
    let texts = ["Log-Viewer helps you to follow log files and thereby mark text parts of interest.",
                 "Open 'Global Preferences' to select general behaviour, font size, colors and search mode. Colors can be changed by selecting a color block.",
                 "Open 'Document Preferences' to set the text patterns to be color marked. Full line coloring is a little faster and colors the complete line with the color of the first detected pattern.",
                 "Open a log file (.txt, .log or .out). The view will follow the file like the tail -f command.",
                 "You can pause and resume following new incoming lines with the toolbar icon.",
                 "If color marks overlap, the first (leftmost) 'wins'."]
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = NSView()
        view.frame = CGRect(x: 0, y: 0, width: 400, height: 270)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        let font = NSFont.systemFont(ofSize: 14)
        for text in texts{
            let field = NSTextField(wrappingLabelWithString: text)
            field.font = font
            stack.addArrangedSubview(field)
        }
        view.addSubview(stack)
        stack.fillSuperview(insets: Insets.defaultInsets)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
