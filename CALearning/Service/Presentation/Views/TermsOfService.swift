//
//  TermsOfService.swift
//  CALearning
//
//  Created by 斉藤  祐輔 on 2022/04/28.
//

import SwiftUI

struct TermsOfService: View {
    @EnvironmentObject var controller: Controller
    
    var body: some View {
        VStack {
            Spacer()
            Text("Actor: \(self.controller.actor.description)")
            Spacer()
            Button("→ Purchase") {
                self.controller.dispatch(.purchase(from: .basic(scene: .ユーザは購入ボタンを押下する)))
            }
            Spacer()
        }
    }
}

struct TermsOfService_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfService()
    }
}
