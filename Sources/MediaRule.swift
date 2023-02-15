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

import Foundation

class MediaRule {
    typealias RuleFunction = (MediaRule, [String: Any]) -> Bool
    private(set) var name: Int
    private(set) var description: String
    // swiftlint:disable large_tuple
    private var predicateList: [(fn: RuleFunction, expectedResult: Bool, errorMsg: String)] = []
    private var actionList: [RuleFunction] = []

    init(name: Int, description: String) {
        self.name = name
        self.description = description
    }

    // Adds the predicates/conditions function for the rule.
    /// - Parameter predicateFn: a closure  function to be executed for the associated rule.
    @discardableResult
    func addPredicate(predicateFn: @escaping RuleFunction, expectedValue: Bool, errorMsg: String) -> MediaRule {
        let predicateTuple = (predicateFn, expectedValue, errorMsg)
        predicateList.append(predicateTuple)

        return self
    }

    // Adds the action function for the rule to be executed.
    /// - Parameter actionFn: a closure function to be executed for the associated rule.
    @discardableResult
    func addAction(actionFn: @escaping RuleFunction) -> MediaRule {
        actionList.append(actionFn)

        return self
    }

    // Run all the predicates associated with the rule.
    /// - Parameter context: a dictionary containing data to be verified.
    func runPredicates(context: [String: Any]) -> (Bool, String) {
        for predicate in predicateList {
            let predicateFn = predicate.fn
            let expectedValue = predicate.expectedResult

            if predicateFn(self, context) != expectedValue {
                return (false, predicate.errorMsg)
            }
        }
        return (true, "")
    }

    // Run all the actions associated with the rule
    /// - Parameter context: a dictionary containing data to be verified
    func runActions(context: [String: Any]) -> Bool {
        for action in actionList {
            if !action(self, context) {
                return false
            }
        }
        return true
    }
}
