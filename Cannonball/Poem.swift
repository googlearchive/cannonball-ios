//
// Copyright (C) 2017 Google, Inc. and other contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

open class Poem {

    // MARK: Types

    // String constants used to archive the stored properties of a poem.
    struct SerializationKeys {
        static let words : String = "words"
        static let text : String = "text"
        static let picture : String = "imageId"
        static let theme : String = "theme"
        static let timestamp : String = "timestamp"
    }

    // The words composing a poem.
    open var words: [String] = []

    // The picture used as a background of a poem.
    open var picture: String = ""

    // The theme name of the poem.
    open var theme: String = ""

    // The date a poem is completed.
    open var timestamp = -1

    convenience init() {
        self.init(words: [], picture: "", theme: "", timestamp: -1)
    }
    // Initialize a Poem instance will all its properties, including a UUID.
    init(words: [String], picture: String, theme: String, timestamp: Int) {
        self.words = words
        self.picture = picture
        self.theme = theme
        self.timestamp = timestamp
    }

    // Retrieve the poem words as one sentence.
    func getSentence() -> String {
        return words.joined(separator: " ")
    }

    func getTimestamp() -> Int {
        return Int(NSDate().timeIntervalSince1970)
    }

    func finishPoem() {
        timestamp = getTimestamp()
    }

    // Initialize a Poem instance with all its public properties.
    convenience init(data : NSDictionary) {
        let words = data[SerializationKeys.words]
        let picture = data[SerializationKeys.picture]
        let theme = data[SerializationKeys.theme]
        let timestamp = data[SerializationKeys.timestamp]

        self.init( words : words as! [String], picture : picture as! String, theme : theme as! String, timestamp: timestamp as! Int)
    }

    open func encode() -> NSDictionary {
        let data : NSDictionary = [
            SerializationKeys.text: getSentence(),
            SerializationKeys.picture: picture,
            SerializationKeys.theme: theme,
            SerializationKeys.timestamp: timestamp,
        ]
        return data;
    }
}
