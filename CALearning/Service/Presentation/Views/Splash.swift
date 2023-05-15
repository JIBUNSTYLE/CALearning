//
//  Splash.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

struct Splash: View {
    
    @EnvironmentObject var performer: Performer
    
    var body: some View {
        Text("Slash")
            .onAppear {
                self.performer.boot(from:.basic(scene: .ユーザはHome画面でアイコンを選択する))
            }
    }
}

struct Splash_Previews: PreviewProvider {
    static var previews: some View {
        Splash()
            .environmentObject(Performer())
    }
}
