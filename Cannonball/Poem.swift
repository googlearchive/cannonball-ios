//
// Copyright (C) 2018 Google, Inc. and other contributors.
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
import Firebase

open class Poem {

    // MARK: Types

    // String constants used to access the properties of a poem.
    struct SerializationKeys {
        static let text : String = "text"
        static let picture : String = "imageId"
        static let theme : String = "theme"
        static let timestamp : String = "creationTimeStamp"
        static let isPublic : String = "public"
    }

    // MARK: Instance variables
    // The words composing a poem.
    open var words: [String]

    // The picture used as a background of a poem.
    open var picture: String

    // The theme name of the poem.
    open var theme: String

    // The date a poem is completed.
    open var timestamp : Date

    // Whether or not a poem is public
    open var isPublic : Bool

    open var ref : DocumentReference?

    // Initialize a Poem instance will all its properties, including a UUID.
    // Includes default parameters for creating an empty poem.
    init(words: [String] = [], picture: String = "", theme: String = "", timestamp: Date = Date(), isPublic : Bool = false, ref : DocumentReference? = nil) {
        self.words = words
        self.picture = picture
        self.theme = theme
        self.timestamp = timestamp
        self.isPublic = isPublic
        self.ref = ref
    }

    // Initialize a Poem from a Firestore database reference
    convenience init(fromRef ref : DocumentReference) {
        self.init()
        ref.getDocument { (snap, err) in
            if let err = err {
                print("Error reading poem \(ref.path): \(err)")
            } else {
                guard let poemDict = snap?.data() else {
                    print("poemDict is nil for poem \(ref.path)")
                    return
                }
                let text = poemDict[SerializationKeys.text] as! String
                let words = text.components(separatedBy: " ")
                let picture = poemDict[SerializationKeys.picture] as! String
                let theme = poemDict[SerializationKeys.theme] as! String
                let firebaseTimestamp = poemDict[SerializationKeys.timestamp] as! Timestamp
                let timestamp = firebaseTimestamp.dateValue()
                let isPublic = poemDict[SerializationKeys.isPublic] as! Bool

                self.init( words : words, picture : picture, theme : theme, timestamp: timestamp, isPublic : isPublic, ref : ref)
            }
        }

    }

    // Retrieve the poem words as one sentence.
    func getSentence() -> String {
        return words.joined(separator: " ")
    }

    // Encode the poem as a dictionary usable by Cloud Firestore.
    open func encode() -> [String : Any] {
        return [
            SerializationKeys.text: getSentence(),
            SerializationKeys.picture: picture,
            SerializationKeys.theme: theme,
            SerializationKeys.timestamp: Timestamp(date: timestamp),
            SerializationKeys.isPublic: isPublic
        ]
    }
}
