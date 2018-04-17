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
        // A String (not an array of such) used by Firebase RTDB.
        static let text : String = "text"
        static let picture : String = "imageId"
        static let theme : String = "theme"
        static let timestamp : String = "timestamp"
    }

    // MARK: Instance variables

    // The words composing a poem.
    open var words: [String] = []

    // The picture used as a background of a poem.
    open var picture: String = ""

    // The theme name of the poem.
    open var theme: String = ""

    // The date a poem is completed.
    open var timestamp = -1

    // Initialize a Poem instance will all its properties, including a UUID.
    // Includes default parameters for creating an empty poem.
    init(words: [String] = [], picture: String = "", theme: String = "", timestamp: Int = -1) {
        self.words = words
        self.picture = picture
        self.theme = theme
        self.timestamp = timestamp
    }

    // Initialize a Poem from an NSDictionary, most likely returned by Firebase RTDB.
    convenience init(fromDictionary poemDict : NSDictionary) {
        let text = poemDict[SerializationKeys.text] as! String
        let words = text.components(separatedBy: " ")
        let picture = poemDict[SerializationKeys.picture]
        let theme = poemDict[SerializationKeys.theme]
        let timestamp = poemDict[SerializationKeys.timestamp]

        self.init( words : words, picture : picture as! String, theme : theme as! String, timestamp: timestamp as! Int)
    }

    // Retrieve the poem words as one sentence.
    func getSentence() -> String {
        return words.joined(separator: " ")
    }

    // Encode the poem as an NSDictionary usable by Firebase RTDB.
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
