
import Foundation
import UIKit

func * (lhs: Character, rhs: Int) -> String {
    return String(repeating: String(lhs), count: rhs)
}

public extension String {
    
    public func tokenizeToWord() -> [String] {
        return self.tokenize(option: kCFStringTokenizerUnitWord)
    }
    
    public func tokenizeToWordRemovingHyphenation() -> [String] {
        return self.filter { $0 != "-" }
            .tokenize(option: kCFStringTokenizerUnitWord)
    }
    
    public func tokenizeToWordRanges() -> [CountableRange<Int>] {
        return self.tokenizeRanges(option: kCFStringTokenizerUnitWord)
    }
    
    public func tokenizeToWordIndexRanges() -> [Range<String.Index>] {
        return self.tokenizeIndexRanges(option: kCFStringTokenizerUnitWord)
    }
    
    public func tokenizeToSentences() -> [String] {
        return self.tokenize(option: kCFStringTokenizerUnitSentence)
    }
    
    public func tokenizeToParagraphs() -> [String] {
        return self.tokenize(option: kCFStringTokenizerUnitParagraph)
    }
    
    public func tokenizeToLineBreaks() -> [String] {
        return self.tokenize(option: kCFStringTokenizerUnitLineBreak)
    }
    
    private func tokenize(option: CFOptionFlags) -> [String] {
        return self.tokenizeRanges(option: option).map { self.substring(with: $0) }
    }
    
    private func tokenizeRanges(option: CFOptionFlags) -> [CountableRange<Int>] {
        let inputRange = CFRangeMake(0, self.utf16.count)        
        let flag = UInt(option)
        let locale = CFLocaleCopyCurrent() 
        let cfString : CFString = self as CFString
        let tokenizer = CFStringTokenizerCreate( kCFAllocatorDefault, cfString, inputRange, flag, locale)
        var tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)        
        var tokenRanges : [CountableRange<Int>] = []
        let tokenTypeOptionSet : CFStringTokenizerTokenType = []
        while tokenType != tokenTypeOptionSet {
            let currentTokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let lower = Int(currentTokenRange.location)
            let upper = Int(currentTokenRange.location + currentTokenRange.length)
            let range = lower ..< upper 
            tokenRanges.append(range)            
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        return tokenRanges
    }
    
    private func tokenizeIndexRanges(option: CFOptionFlags) -> [Range<String.Index>] {
        return tokenizeRanges(option: option).compactMap { self.range(fromCountableRange: $0) }
    }
   
    public func toWordsFromRegex() -> [String] {
        return self["(\\b[^\\s]+\\b)"].matches()
    }
    
    public func toWordRangesFromRegex() -> [Range<Int>] {
        return self["(\\b[^\\s]+\\b)"]
            .ranges()
            .map { $0.location ..< ($0.location + $0.length) }
    }

    private var regexSpecialCharactersBounderies: String {
        // https://regex101.com/
        return "[-'’%$#&/]\\b|\\b[‑'’%$#&/]|\\b[‐'’%$#&/]|\\d*\\.?\\d+|[A-Za-z0-9]|\\([A-Za-z0-9]"
    }

    private var regexIncludingSpecialCharactersWithinWords: String {
        // http://rubular.com/r/egE3v951RH
        return "(?<=\\s|^|\\b)(?:\(regexSpecialCharactersBounderies)+\\))+(?=\\s|$|\\b)"
    }

    private var regexIncludingSpecialCharactersWithinWordsAndPunctuations: String {
        // https://regex101.com/r/IpOqXy/17
        // https://stackoverflow.com/questions/42019240/regex-to-match-words-with-punctuation-but-not-punctuation-alone
        return "(?<=\\s|^|\\b)(?:\(regexSpecialCharactersBounderies)+\\))+(?=\\s|$|\\b)"
            + "|[^A-Za-z0-9\\s]"
    }

    public func toWordsFromRegexIncludingSpecialCharactersWithinWords() -> [String] {
        return self[regexIncludingSpecialCharactersWithinWords]
            .matches()
    }
    
    public func toRangesFromRegexIncludingSpecialCharactersWithinWords() -> [Range<Int>] {
        return self[regexIncludingSpecialCharactersWithinWords]
            .ranges()
            .map { $0.location ..< ($0.location + $0.length) }
    }

    public func toWordsFromRegexIncludingSpecialCharactersWithinWordsAndPunctuations() -> [String] {
        return self[regexIncludingSpecialCharactersWithinWordsAndPunctuations]
            .matches()
    }

    public func toNSRangesFromRegexIncludingSpecialCharactersWithinWordsAndPunctuations() -> [NSRange] {
        return self[regexIncludingSpecialCharactersWithinWordsAndPunctuations]
            .ranges()
    }

    public func toRangesFromRegexIncludingSpecialCharactersWithinWordsAndPunctuations() -> [Range<Int>] {
        return self[regexIncludingSpecialCharactersWithinWordsAndPunctuations]
            .ranges()
            .map { $0.location ..< ($0.location + $0.length) }
    }

    public func toWords() -> [String] {
        let range = self.range(of: self)!
        var words = [String]()
        enumerateSubstrings(in: range, options: .byWords) { (substring, _, _, _) -> Void in
            words.append(substring!)
        }
        return words
    }

    public func toWordRanges() -> [Range<String.Index>] {
        let wordRange = self.range(of: self)!
        var ranges = [Range<String.Index>]()

        enumerateSubstrings(in: wordRange, options: .byWords) { (_, range, _, _) -> Void in
            ranges.append(range)
        }
        return ranges
    }
 
    public func toLinguisticSentenceRanges() ->  [Range<String.Index>] {
        
        let charset = CharacterSet.whitespacesAndNewlines
        
        let (tags, textRanges) = 
            self.trimmingCharacters(in: charset)
                .toLinguisticTagsAndRanges()
        
        let sentenceSplit = 
            tags
                .enumerated()
                .split(omittingEmptySubsequences: true, 
                       whereSeparator: { 
                        return $0.element == "SentenceTerminator"
                })
                .map { $0.compactMap { $0 } }
        
        let sentenceRanges = 
            sentenceSplit
                .map { ($0.first?.offset ?? 0, $0.last?.offset ?? 0) }
                .map { first, last in textRanges[first].lowerBound ..< textRanges[last].upperBound }
        return sentenceRanges
    }
    
    public func toLinguisticSentences() -> [String] {
        let (tags, ranges) = toLinguisticTagsAndRanges()
        
        var result = [String]()
        let ixs = tags.enumerated().filter {
            $0.element == "SentenceTerminator"
            }
            .map { return ranges[$0.offset].lowerBound}
        
        if ixs.count == 0 {
            return [self]
        }
        var prev = self.startIndex
        for ix in ixs {
            let r = prev...ix
            let charset = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            let trimmed = self[r].trimmingCharacters(in: charset)
            result.append(trimmed)
            prev = self.index(after: ix)
        }
        return result
    }
    
    public func toLinguisticTagsAndRanges() -> (tags: [String], ranges: [Range<String.Index>]) {
        var r = [Range<String.Index>]()
        let i = self.indices
        let t = self.linguisticTags(in: i.startIndex ..< i.endIndex, 
                                    scheme: NSLinguisticTagScheme.lexicalClass.rawValue, 
                                    options: NSLinguisticTagger.Options.joinNames, 
                                    orthography: nil, 
                                    tokenRanges: &r)
        return (t, r)
    }
    
    public func toLinguisticTagsWordsAndRanges() -> (tags: [String], words: [String], ranges: [NSRange]) {
        //www.hackingwithswift.com/example-code/strings/how-to-parse-a-sentence-using-nslinguistictagger
        let options = NSLinguisticTagger.Options.omitWhitespace.rawValue 
            | NSLinguisticTagger.Options.joinNames.rawValue
        let tagger = NSLinguisticTagger(tagSchemes: NSLinguisticTagger
            .availableTagSchemes(forLanguage: "en"), 
                                        options: Int(options))
        let inputString = self
        tagger.string = inputString
        var tags = [String]()
        var words = [String]()
        var ranges = [NSRange]()
        let range = NSRange(location: 0, length: inputString.utf16.count)
        tagger
            .enumerateTags(in: range, 
                           scheme: .nameTypeOrLexicalClass, 
                           options: NSLinguisticTagger
                            .Options(rawValue: options)) { (tag, tokenRange, _, _) in
                                guard let tag = tag?.rawValue, let range = Range(tokenRange, in: inputString) else { return }
                                let token = inputString[range]
                                let word = String(token)
                                //print("\(tag): \(token), \(tokenRange), \(sentenceRange)")
                                tags.append(tag)
                                words.append(word) 
                                ranges.append(tokenRange)
        }
        return (tags, words, ranges)
    }
    
    public func indexAt(from: Int) -> String.Index {
        return self.index(startIndex, offsetBy: from)
    }

    private func substring(with range : CFRange) -> String {
        let nsrange = NSRange.init(location: range.location, length: range.length)
        let substring = (self as NSString).substring(with: nsrange)
        return substring
    }
    
    private func substring(with range : CountableRange<Int>) -> String {
        let nsrange = NSRange.init(location: range.lowerBound, length: range.count)
        let substring = (self as NSString).substring(with: nsrange)
        return substring
    }
    
    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        get {
            return self[..<index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeThrough<Int>) -> Substring {
        get {
            return self[...index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeFrom<Int>) -> Substring {
        get {
            return self[index(startIndex, offsetBy: value.lowerBound)...]
        }
    }

    subscript(_ range: NSRange) -> String {
        let start = self.index(self.startIndex, offsetBy: range.lowerBound)
        let end = self.index(self.startIndex, offsetBy: range.upperBound)
        let subString = self[start..<end]
        return String(subString)
    }

    subscript (range: Range<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: range.count)
        return String(self[startIndex..<endIndex])
    }
    
    subscript (index: Int) -> Character {
        let charIndex = self.index(self.startIndex,offsetBy:index)
        return self[charIndex]
    }
    
    public func substring(from: Int) -> String {
        let fromIndex = self.indexAt(from: from)
        return String(self[fromIndex...])
    }

    public func substring(to toIndex: Int) -> String {
        let index = self.indexAt(from: toIndex)
        return String(self[..<index]) // Swift 4
    }

    public func substring(from fromIndex: Int, to toIndex: Int) -> String {
        let start = index(startIndex, offsetBy: fromIndex)
        let end = index(start, offsetBy: toIndex - fromIndex)
        return String(self[start ..< end])
    }
    
    public func substring(withRange range: Range<Int>) -> String {
        let range = self.range(fromRangeInt: range)
        return String(self[range])
    }
    
    public func substring(withNSRange range: NSRange) -> String {
        return substring(from: range.lowerBound, to: range.upperBound)
    }
    
    public func nsRange(fromStringIndex range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }

    public func nsRange(fromRangeInt rangeInt : Range<Int>) -> NSRange {
        return NSRange.init(location: rangeInt.lowerBound,
                         length: rangeInt.count)
    }
    
    public func nsRange() -> NSRange {
        return NSRange(location: 0, length: self.utf16.count)
    }
    
    public func range(fromNSRange nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
    
    public func range(usingNSRange nsRange : NSRange) -> Range<String.Index> {
        let startIndex = indexAt(from: nsRange.location)
        let endIndex = indexAt(from: nsRange.location + nsRange.length)
        return startIndex..<endIndex
    }
    
    public func range(withNSRange nsRange : NSRange) -> Range<Int> {
        let start = nsRange.location
        let end = nsRange.location + nsRange.length
        return start..<end
    }
    
    public func range(fromStringIndex stringIndex: Range<String.Index>?) -> Range<Int> {
        guard let start = stringIndex?.lowerBound.encodedOffset,
            let end = stringIndex?.upperBound.encodedOffset else { return 0..<0 }
        return start..<end
    }

    public func range(fromRangeInt rangeInt: Range<Int>) -> Range<String.Index> {
        let startIndex = self.indexAt(from: rangeInt.lowerBound)
        let endIndex = self.indexAt(from: rangeInt.upperBound)
        return startIndex..<endIndex
    }

    public func range(fromRange range: Range<Int>) -> Range<String.Index>
    {
        let from = self.index(self.startIndex, offsetBy: range.lowerBound)
        let to = self.index(self.startIndex, offsetBy: range.upperBound)
        return from..<to
    }
    
    public func range(fromCountableRange countableRange: CountableRange<Int>) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(
                utf16.startIndex, 
                offsetBy: countableRange.lowerBound, 
                limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: countableRange.count, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }

    public func ranges(from string: String) -> [NSRange] {
        let wordRangesInt = self.toWordRangesFromRegex()
        var ranges: [NSRange] = []
        for range in wordRangesInt {
            let wordToHighlight = self.substring(withRange: range)
            if string == wordToHighlight {
                let stringIndexRange = self.range(fromRangeInt: range)
                let nsRange = self.nsRange(fromStringIndex: stringIndexRange)
                ranges.append(nsRange)
            }
        }
        return ranges
    }

    public func range(ofUniqueWord word: String) -> NSRange? {
        let words = self
            .toWordsFromRegexIncludingSpecialCharactersWithinWords()
            .elementFrequencyCounter()
        if let count = words[word], count < 2 {
            return (self as NSString).range(of: word)
        }
        return nil
    }

    public static func replaceAt(str: String, index: Int, newCharac: String) -> String {
        return str.substring(to: index - 1)  + newCharac + str.substring(from: index)
    }

    public func replaceHypthensWithNonBreakingHyphens() -> String {
        let nonBreakingHyphen = "\u{2011}"
        let hyphen = "\u{2010}"
        let hyphenMinus = "\u{002D}"
        let enDash = "\u{2013}"
        let figureDash = "\u{2012}"
        let otherHyphens = [enDash, figureDash, hyphen, hyphenMinus]
        return otherHyphens.reduce(self) { string, hyphen  in
            return string.replacingOccurrences(of: hyphen, with: nonBreakingHyphen)
        }
    }

    public func highlight(words ranges: [NSRange], toColor color: UIColor) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for range in ranges {
            attributedString.addAttributes([.foregroundColor: color], range: range)
        }
        return attributedString
    }

    public func underLine(word range: NSRange, toColor color: UIColor,
                          style: NSUnderlineStyle) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        attributedString.addAttributes([.underlineStyle: style.rawValue,
                                        .foregroundColor: color], range: range)
        return attributedString
    }

    public func underLine(words ranges: [NSRange], toColor color: UIColor,
                          style: NSUnderlineStyle) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for range in ranges {
            attributedString.addAttributes([.underlineStyle: style.rawValue,
                                            .foregroundColor: color], range: range)
        }
        return attributedString
    }

    public func getUniqueWords() -> [String] {
        let words = toWordsFromRegexIncludingSpecialCharactersWithinWords()
        let uniqueWords = Set(words)
        return Array(uniqueWords)
    }
    
    public func getNonRepeatingWord() -> [String] {
        let words = toWordsFromRegexIncludingSpecialCharactersWithinWords()
        let wordsFrequency = words.elementFrequencyCounter()
        return wordsFrequency
            .filter({ $0.value == 1 })
            .map({$0.key })
    }
    
    public func getRepeatingWord() -> [String] {
        let words = toWordsFromRegexIncludingSpecialCharactersWithinWords()
        let wordsFrequency = words.elementFrequencyCounter()
        return wordsFrequency
            .filter({ $0.value > 1 })
            .map({$0.key })
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constrainedSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constrainedSize,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil)
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constrainedSize = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(
            with: constrainedSize,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil)
        return ceil(boundingBox.width)
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let text: String = self
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let text: String = self
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: fontAttributes)
        return size.height
    }

    
    //emoji 
    
    public func toUIImage(with fontSize: CGFloat) -> UIImage {
        let size = CGSize(width: 30, height: 35)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.white.set()
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        
        (self as NSString).draw(in: rect, withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]) 
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let im = image else {
            print("problem")
            return UIImage()
        }
        return im
    }
    
    public func showEmojiDetail () -> String {
        return self.reduce("") { // loop through str individual characters
            var item = "\($1)" // string with the current char
            let isEmoji = item.containsEmoji // true or false
            
            if isEmoji {
                item = item.applyingTransform(StringTransform.toUnicodeName, reverse: false)!
            }
            return $0 + item
            }.replacingOccurrences(of:"\\N", with:"") // strips "\N"
        
    }
    
    public var containsEmoji: Bool {
        
        for scalar in self.unicodeScalars {
            switch scalar.value {
                
            case 0x2600...0x1F9FF:
                return true
            default:
                continue
            }
        }
        return false
    }

    public func removeEmojies () -> String {
        
        return self.reduce("") 
        { 
            let item = "\($1)" // string with the current char
            let isEmoji = item.containsEmoji // true or false
            
            if isEmoji {
                
                print("Found emoji", item)
                return ""
            }else {
                print("No emoji", item)
                return item
            }
        }
    }
    
    
    public static func getItemUrlFromBundle (bundleID: String, itemName:String, extention: String, subDirectory:String = "") -> URL? {
        guard let bundle = Bundle(identifier: bundleID) else { 
            print("Bundle ID is not valid")
            return nil 
        }
        let url = bundle.url(forResource: itemName, withExtension: extention, subdirectory: subDirectory)
        return url
    }
    
    public static func getItemPathFromBundle (bundleID: String, itemName:String, type: String, inDirectory:String = "") -> String? {
        guard let bundle = Bundle(identifier: bundleID) else { 
            print("Bundle ID is not valid")
            return nil 
        }
        let path = bundle.path(forResource: itemName, ofType: type, inDirectory: inDirectory)
        return path
    }
    
    public static func fileExist(with path: String) -> Bool{
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path)
    }

}

extension Collection where Iterator.Element == String {

    public func takeRandom (_ amount: Int, with minCharacterCount: Int) -> [String] {
        let words =  self.filter({ $0.count >= minCharacterCount})
        return words.takeRandom(amount: amount)
    }
}

