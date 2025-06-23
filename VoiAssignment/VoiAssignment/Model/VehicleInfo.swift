//
//  VehicleInfo.swift
//  VoiAssignment
//
//  Created by Gayatri Nagarkar on 2025-06-23.
//

import Foundation

struct VehicleInfo: Decodable, Equatable {
    let name: String
    let id: String
    let category: String
    let price: Int
    let currency: String
}
 
struct VehicleInfoResponse: Decodable {
    let name: String?
    let id: String?
    let category: String?
    let price: Int?
    let currency: String?
}
 
extension VehicleInfo {
    init(with response: VehicleInfoResponse) {
        self.name = response.name ?? "NA"
        self.id = response.id ?? "NA"
        self.category = response.category ?? "NA"
        self.price = response.price ?? 0
        self.currency = response.currency ?? ""
    }
}
