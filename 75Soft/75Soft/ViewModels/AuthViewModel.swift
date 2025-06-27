//
//  AuthViewModel.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/26/25.
//

import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    
    func login(email: String, password: String) {
        // TODO: Implement real authentication
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isAuthenticated = true
        }
        
    }
    
    
    func register(email: String, password: String) {
        // TODO: Implement real registration
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isAuthenticated = true
        }
    }
}
