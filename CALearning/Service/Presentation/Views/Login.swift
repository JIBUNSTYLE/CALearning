//
//  Login.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

struct Login: View {
    @EnvironmentObject var presenter: Controller
    
    @StateObject var store: LoginBehavior
    
    @State var id: String?
    @State var password: String?
    @State var isPresentTermsOfService = false
    
    var body: some View {
            VStack {
                ZStack {
                    Color.yellow.edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        Text("Login!")
                        Spacer()
                        Button("→ Login") {
                            self.presenter.dispatch(.loggingIn(from: .basic(scene: .ユーザはログインボタンを押下する(id: self.id, password: self.password))))
                        }
                        .disabled(self.presenter.usecaseStatus.isExecuting)
                        if let result = self.store.loginValidationResult
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
        Login(store: Controller().loginBehavior)
    }
}
