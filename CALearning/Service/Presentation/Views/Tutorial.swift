//
//  Tutorial.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

struct Tutorial: View {
    @EnvironmentObject var service: FrontendService
    
    var body: some View {
        VStack {
            Spacer()
            Text("Tutorial!")
            Spacer()
            Button("→ Complete") {
                self.service.dispatch(.signIn(usecase: .completeTutorial(from:.basic(scene: .ユーザはチュートリアルを閉じる))))
            }
            Spacer()
        }
    }
}

struct Tutorial_Previews: PreviewProvider {
    static var previews: some View {
        Tutorial()
            .environmentObject(FrontendService())
    }
}
