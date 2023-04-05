//
//  Login.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

struct Login: View {
    @EnvironmentObject var controller: Controller
    
    @StateObject var loginBehavior: LoginBehavior
    
    @State var id: String = ""
    @State var password: String = ""
    @State var isPresentTermsOfService = false
    
    var body: some View {
            VStack {
                ZStack {
                    Color.yellow.edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        Text("Login!")
                        Spacer()
                        HStack {
                            Text("ID")
                            TextField("Input your mail address", text: $id)
                        }
                        HStack {
                            Text("Password")
                            TextField("Input your password", text: $password)
                        }
                        Button("→ Login") {
                            self.controller.dispatch(.loggingIn(from: .basic(scene: .ユーザはログインボタンを押下する(id: self.id.isEmpty ? nil : self.id , password: self.password.isEmpty ? nil : self.password))))
                        }
                        .disabled(self.controller.usecaseStatus.isExecuting)
                        if let result = self.loginBehavior.loginValidationResult
                            , case let .failed(idValidationResult, passwordValidationResult) = result {
                            switch idValidationResult {
                            case .isValid:
                                Text("")
                            case .isRequired:
                                Text("id: isRequired")
                            case .isMalformed:
                                Text("id: isMalformed")
                            }
                            switch passwordValidationResult {
                            case .isValid:
                                Text("")
                            case .isRequired:
                                Text("pw: isRequired")
                            case .isTooShort:
                                Text("pw: isTooShort")
                            case .isTooLong:
                                Text("pw: isTooLong")
                            }
                        } else {
                            Text("")
                        }
                        Spacer()
                        HStack {
                            Button("→ ログインしないで使う") {
                                self.controller.dispatch(.trialUsing(from: .basic(scene: .ユーザはログインしないで使うボタンを押下する)))
                            }
                            Spacer()
                            Button("→ Terms of Service") {
                                self.isPresentTermsOfService.toggle()
                            }
                        }
                        Spacer()
                    }
                }
            }
            .fullScreenCover(
                isPresented: self.$isPresentTermsOfService
                , onDismiss: {
                    
                }
                , content: {
                    TermsOfService()
                }
            )
        }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login(loginBehavior: Controller().loginBehavior)
    }
}
