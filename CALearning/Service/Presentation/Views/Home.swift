//
//  Home.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/04/05.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var service: FrontendService
    
    @StateObject var shoppingStore: ShoppingState
    
    
    var body: some View {
        VStack {
            Spacer()
            Text("Actor: \(self.service.actor.description)")
            Spacer()
            Button("→ Purchase") {
                self.service.dispatch(.shopping(usecase: .purchase(from: .basic(scene: .ユーザは購入ボタンを押下する))))
            }
            .disabled(self.shoppingStore.isConfirming)
            Spacer()
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        let service = FrontendService()
        Home(shoppingStore: service.shoppingState)
            .environmentObject(service)
    }
}
