/*
 Copyright 2022 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPServices
import Foundation

class MediaRuleEngine {
    private static let LOG_TAG = MediaConstants.LOG_TAG
    private static let CLASS_NAME = "MediaRuleEngine"
    private let RULE_NOT_FOUND = "Matching rule not found"
    private var rules: [Int: MediaRule] = [:]
    private var enterFn: MediaRule.RuleFunction?
    private var exitFn: MediaRule.RuleFunction?

    // Add a rule to the be verified by the MediaRuleEngine.
    /// - Parameter rule: a `MediaRule` to be validated by the `MediaRulesEngine`.
    @discardableResult
    func add(rule: MediaRule) -> Bool {
        if rules[rule.name] == nil {
            rules[rule.name] = rule
            return true
        }
        return false
    }

    // Adds the closure/function to be run before processing the rules.
    /// - Parameter enterFn: a closure to be executed.
    func onEnterRule(enterFn: @escaping MediaRule.RuleFunction) {
        self.enterFn = enterFn
    }

    // Adds the closure/function to be run after processing the rules.
    /// - Parameter exitFn: a closure to be executed.
    func onExitRule(exitFn: @escaping MediaRule.RuleFunction) {
        self.exitFn = exitFn
    }

    // Processes the rule and returns true if success and false if failure along with the error message.
    /// - Parameters:
    ///    - name: an `Int` denoting the name of the rule./
    ///    - context: a `dictionary` containing  data to be valdiated for the rule.
    func processRule(name: Int, context: [String: Any]) -> (success: Bool, errorMsg: String) {
        guard let rule = rules[name] else {
            return (false, RULE_NOT_FOUND)
        }

        let predicateResult = rule.runPredicates(context: context)

        guard predicateResult.0 else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Predicates failed for Rule: (\(rule.description))")
            return predicateResult
        }

        // pass if no enterFn or if enterFn is a success
        if let enterFn = enterFn, !enterFn(rule, context) {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Enter action prevents further processing for Rule: (\(rule.description))")
            return predicateResult
        }

        guard rule.runActions(context: context) else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Rule action prevents further processing for Rule: (\(rule.description))")
            return predicateResult
        }

        if let exitFn = exitFn, !exitFn(rule, context) {
            Log.trace(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Exit action resulted in a failure for Rule: (\(rule.description))")
        }

        return predicateResult
    }
}
