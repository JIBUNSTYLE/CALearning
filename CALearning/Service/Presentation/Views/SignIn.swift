//
//  SignIn.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

struct SignIn: View {
    @EnvironmentObject var dispatcher: Dispatcher
    
    @StateObject var signInStore: SignInStore
    
    @State var id: String = ""
    @State var password: String = ""
    @State var isPresentTermsOfService = false
    
    var body: some View {
            VStack {
                ZStack {
                    Color.yellow.edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        Text("SignIn!")
                        Spacer()
                        HStack {
                            Text("ID")
                            TextField("Input your mail address", text: $id)
                        }
                        HStack {
                            Text("Password")
                            TextField("Input your password", text: $password)
                        }
                        Button("→ SignIn") {
                            self.dispatcher.dispatch(.signingIn(from: .basic(scene: .ユーザはログインボタンを押下する(id: self.id.isEmpty ? nil : self.id , password: self.password.isEmpty ? nil : self.password))))
                        }
                        .disabled(self.dispatcher.usecaseStatus.isExecuting)
                        if let result = self.signInStore.signInValidationResult
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
                        if !self.dispatcher.isSignInModalPresented {
                            Spacer()
                            HStack {
                                Button("→ ログインしないで使う") {
                                    self.dispatcher.dispatch(.trialUsing(from: .basic(scene: .ユーザはログインしないで使うボタンを押下する)))
                                }
                                Spacer()
                                Button("→ Terms of Service") {
                                    self.isPresentTermsOfService.toggle()
                                }
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
            .onAppear {
                Dependencies.shared.locationManager.requestAuthorization()
            }
        }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        let dispatcher = Dispatcher()
        SignIn(signInStore: dispatcher.signInStore)
            .environmentObject(dispatcher)
    }
}
