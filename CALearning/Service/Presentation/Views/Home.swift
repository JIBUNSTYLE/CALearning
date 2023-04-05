//
//  Home.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2023/04/05.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var controller: Controller
    
    @StateObject var shoppingBehavior: ShoppingBehavior
    
    
    var body: some View {
        VStack {
            Spacer()
            Text("Actor: \(self.controller.actor.description)")
            Spacer()
            Button("→ Purchase") {
                self.controller.dispatch(.purchase(from: .basic(scene: .ユーザは購入ボタンを押下する)))
            }
            .disabled(self.shoppingBehavior.isConfirming)
            Spacer()
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        let controller = Controller()
        Home(shoppingBehavior: controller.shoppingBehavior)
            .environmentObject(controller)
    }
}
