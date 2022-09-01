//
//  Tutorial.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

struct Tutorial: View {
    @EnvironmentObject var presenter: Presenter
    
    var body: some View {
        VStack {
            Spacer()
            Text("Tutorial!")
            Spacer()
            Button("→ Complete") {
                self.presenter.dispatch(CompleteTutorial.basic(scene: .ユーザはチュートリアルを閉じる))
            }
            Spacer()
        }
    }
}

struct Tutorial_Previews: PreviewProvider {
    static var previews: some View {
        Tutorial()
            .environmentObject(Presenter())
    }
}
