//
//  ContentView.swift
//  Sample
//
//  Created by Mohammad Jeeshan on 07/08/22.
//

import SwiftUI
import AppleLogin

struct ContentView: View {
    var body: some View {
        VStack (spacing: 10) {
            Spacer().frame(height: 30)
            Text("AppleLogin Sample")
                .font(.title)
                .bold()
            Spacer()
            
            Button {
               let appleLoginController = AppleLoginController(delegate: self)
                appleLoginController.beginAppleLogin()
            } label: {
                Text("Continue with Apple")
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .padding()
                    .font(.headline)
                    .foregroundColor(Color.white)
                    .background(Color.black)
                    .cornerRadius(8)
            }
            Spacer()
        }
    }
}

//AppleLogin Delegate methods
extension ContentView: AppleLoginStatusDelegate {
    func appleLoginSuccess(accessToken: String, name: String, email: String) {
        debugPrint(accessToken)
    }
    
    func appleLoginFail(error: AppleAuthError) {
        switch error {
        case .appleDeclinedPermissions:
            //Handle as you want
            break
        case .accessTokenNotFound:
            //Handle as you want
            break
        case .userDataNotFound:
            //Handle as you want
            break
        case .unknown(let error):
            debugPrint(error)
        }
    }
}
