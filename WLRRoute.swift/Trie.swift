//
//  Trie.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/3/13.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

struct Trie<Element: Hashable> {
    let isElement: Bool
    let children: [Element: Trie<Element>]
}

extension Trie {
    init() {
        isElement = false
        children = [:]
    }
}

extension Trie {
    var elements: [[Element]] {
        var result: [[Element]] = isElement ? [[]] : []
        for (key, value) in children {
            result += value.elements.map { [key] + $0
            }
        }
        return result
    }
}

extension Array {
    var slice: ArraySlice<Element> {
        return ArraySlice(self)
    }
}

extension ArraySlice {
    var decomposed: (Element, ArraySlice<Element>)? {
        return isEmpty ? nil : (self[startIndex], self.dropFirst())
    }
}

extension Trie {

    func lookup(key: ArraySlice<Element>) -> Bool {
        guard let (head, tail) = key.decomposed else { return isElement }
        guard let subtrie = children[head] else { return false }
        return subtrie.lookup(key: tail)
    }

    init(_ key: ArraySlice<Element>) {
        if let (head, tail) = key.decomposed {
            let children = [head: Trie(tail)]
            self = Trie(isElement: false, children: children)
        } else {
            self = Trie(isElement: true, children: [:])
        }
    }

    func inserting(_ key: ArraySlice<Element>) -> Trie<Element> {
        guard let (head, tail) = key.decomposed else {
            return Trie(isElement: true, children: children)
        }
        var newChildren = children
        if let nextTrie = children[head] {
            newChildren[head] = nextTrie.inserting(tail)
        } else {
            newChildren[head] = Trie(tail)
        }
        return Trie(isElement: isElement, children: newChildren)
    }

    static func build(urlStr: String, emptyTrie: Trie<String>? = nil) -> Trie<String> {
        let emptyTrie = emptyTrie ?? Trie<String>()
        let components = urlStr.decomposed
        return emptyTrie.inserting(components.slice)
    }
}

extension String {

    var decomposed: [String] {
        var components: [String] = []
        guard let url = URL(string: self) else { return components }
        guard let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: false) else { return components }

        if let sheme = urlComponents.scheme {
            components.append(sheme + "://")
        }

        if let host = urlComponents.host {
            components.append(host)
        }

        if let path = urlComponents.path {
            components.append(path)
        }

        if let query = urlComponents.query {
            components.append("?" + query)
        }

        return components
    }

    func complete(knownWords: Trie<String>) -> Bool {
        let chars = decomposed.slice
        return knownWords.lookup(key: chars)
    }
}
