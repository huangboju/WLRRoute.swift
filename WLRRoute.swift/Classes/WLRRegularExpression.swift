//
//  WLRRegularExpression.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/7.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum Expression: Error {
    case initError
}

class WLRRegularExpression: NSRegularExpression {
    static let WLRRouteParamPattern = ":[a-zA-Z0-9-_][^/]+"
    static let WLRRouteParamNamePattern = ":[a-zA-Z0-9-_]+"
    static let WLPRouteParamMatchPattern = "([^/]+)"

    var routerParamNamesArr: [String] = []

    static func expression(with pattern: String) -> WLRRegularExpression? {
        do {
            return try WLRRegularExpression(pattern: pattern, options: .caseInsensitive)
        } catch let error {
            print(error, #file, #function)
        }
        return nil
    }

    override init(pattern: String, options: NSRegularExpression.Options = []) throws {

        guard let transformedPattern = WLRRegularExpression.transfrom(from: pattern) else {
            throw Expression.initError
        }
        do {
            try super.init(pattern: transformedPattern, options: options)
            routerParamNamesArr = WLRRegularExpression.routeParamNames(from: pattern)!
        } catch let error {
            print(error)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func matchResult(for str: String) -> WLRMatchResult {
        let checkingResults = matches(in: str, options: [], range: NSRange(location: 0, length: str.length))
        let result = WLRMatchResult()
        if checkingResults.isEmpty {
            return result
        }
        result.match = true
        var paramDict: [String: Any] = [:]
        for paramResult in checkingResults {
            for i in 1 ..< paramResult.numberOfRanges where i <= routerParamNamesArr.count {
                let paramName = routerParamNamesArr[i - 1]
                let paramValue = str.substr(with: paramResult.rangeAt(i))
                paramDict[paramName] = paramValue
            }
        }
        result.paramProperties = paramDict
        return result
    }

    static func transfrom(from pattern: String) -> String? {
        var transfromedPattern = pattern
        let paramPatternStrs = paramPatternStrings(from: pattern)
        do {
            let paramNamePatternEx = try NSRegularExpression(pattern: WLRRouteParamNamePattern, options: .caseInsensitive)

            for paramPatternStr in paramPatternStrs! {
                var replaceParamPatternStr = paramPatternStr
                let foundParamNamePatternResult = paramNamePatternEx.matches(in: paramPatternStr, options: .reportProgress, range: NSRange(location: 0, length: paramPatternStr.length)).first
                if let foundParamNamePatternResult = foundParamNamePatternResult {
                    let paramNamePatternStr = paramPatternStr.substr(with: foundParamNamePatternResult.range)
                    replaceParamPatternStr = replaceParamPatternStr.replacingOccurrences(of: paramNamePatternStr, with: "")
                }
                if replaceParamPatternStr.isEmpty {
                    replaceParamPatternStr = WLPRouteParamMatchPattern
                }
                transfromedPattern = transfromedPattern.replacingOccurrences(of: paramPatternStr, with: replaceParamPatternStr)
            }
            if !transfromedPattern.isEmpty && transfromedPattern.substring(to: 1) != "/" {
                transfromedPattern = "^" + transfromedPattern
            }
            return transfromedPattern + "$"
        } catch let error {
            print(error)
        }
        return nil
    }

    static func paramPatternStrings(from pattern: String) -> [String]? {
        do {
            let paramPatternEx = try NSRegularExpression(pattern: WLRRouteParamPattern, options: .caseInsensitive)
            let paramPatternResults = paramPatternEx.matches(in: pattern, options: .reportProgress, range: NSRange(location: 0, length: pattern.length))
            var array: [String] = []
            for paramPattern in paramPatternResults {
                let paramPatternStr = pattern.substr(with: paramPattern.range)
                array.append(paramPatternStr)
            }
            return array
        } catch let error {
            print(error)
        }
        return nil
    }

    static func routeParamNames(from pattern: String) -> [String]? {
        do {
            let paramNameEx = try NSRegularExpression(pattern: WLRRouteParamNamePattern, options: .caseInsensitive)
            let routeParamStrs = paramPatternStrings(from: pattern)
            var routeParamNames: [String] = []
            for routeParamStr in routeParamStrs! {
                let strRange = NSRange(location: 0, length: routeParamStr.length)
                guard let foundRouteParamNameResult = paramNameEx.matches(in: routeParamStr, options: .reportProgress, range: strRange).first else {
                    continue
                }
                var routeParamNameStr = routeParamStr.substr(with: foundRouteParamNameResult.range)
                routeParamNameStr = routeParamNameStr.replacingOccurrences(of: ":", with: "")
                routeParamNames.append(routeParamNameStr)
            }
            return routeParamNames
        } catch let error {
            print(error)
        }
        return nil
    }
}
