//
//  Calculator.swift
//  HMSPatient
//
//  Created by pushker yadav on 18/07/24.
//

import Foundation
func calculateAge(from dateOfBirth: Date) -> Int {
    let calendar = Calendar.current
    let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
    return ageComponents.year ?? 0
}
