//
//  Home.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/04/05.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var dispatcher: Dispatcher
    
    @StateObject var shoppingStore: ShoppingStore
    
    
    var body: some View {
        VStack {
            Spacer()
            Text("Actor: \(self.dispatcher.actor.description)")
            Spacer()
            Button("→ Purchase") {
                self.dispatcher.dispatch(.purchase(from: .basic(scene: .ユーザは購入ボタンを押下する)))
            }
            .disabled(self.shoppingStore.isConfirming)
            Spacer()
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        let dispatcher = Dispatcher()
        Home(shoppingStore: dispatcher.shoppingStore)
            .environmentObject(dispatcher)
    }
}
