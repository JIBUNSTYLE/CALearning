//
//  Splash.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

struct Splash: View {
    
    @EnvironmentObject var presenter: Controller
    
    var body: some View {
        Text("Slash")
            .onAppear {
                self.presenter.dispatch(Usecases.booting(from: .basic(scene: .アプリはサーバで発行したUDIDが保存されていないかを調べる)))
            }
    }
}

struct Splash_Previews: PreviewProvider {
    static var previews: some View {
        Splash()
            .environmentObject(Controller())
    }
}
