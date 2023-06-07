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

// Adds functionality to compare the equality of two doubles to within the specified delta.
extension Double {
    func isAlmostEqual(_ doubleToCompare: Double, accuracy: Double = 0.000001) -> Bool {
        return fabs(self - doubleToCompare) < accuracy
    }
}
