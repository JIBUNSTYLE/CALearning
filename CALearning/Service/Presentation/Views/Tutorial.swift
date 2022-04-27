//
//  Tutorial.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

struct Tutorial: View {
    @EnvironmentObject var sharedPresenter: SharedPresenter
    
    var body: some View {
        VStack {
            Spacer()
            Text("Tutorial!")
            Spacer()
            Button("→ Complete") {
                self.sharedPresenter.dispach(CompleteTutorial.basic(scene: .ユーザはチュートリアルを閉じる))
            }
            Spacer()
        }
    }
}

struct Tutorial_Previews: PreviewProvider {
    static var previews: some View {
        Tutorial()
            .environmentObject(SharedPresenter())
    }
}
