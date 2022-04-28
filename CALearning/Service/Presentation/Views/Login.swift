//
//  Login.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

struct Login: View {
    
    let localStore: LoginStore
    
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
                            self.presenter.dispach(Login.ba)
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
        Login(localStore: Presenter().localStore)
    }
}
