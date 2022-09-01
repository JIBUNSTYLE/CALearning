//
//  Login.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

struct Login: View {
    @EnvironmentObject var presenter: Presenter
    
    let localStore: LoginStore
    
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
                            self.presenter.dispatch(Loggingin.basic(scene: .ユーザはログインボタンを押下する(id: self.id, password: self.password)))
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
        Login(localStore: Presenter().loginStore)
    }
}
