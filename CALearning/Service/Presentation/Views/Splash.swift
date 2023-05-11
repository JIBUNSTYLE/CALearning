//
//  Splash.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

struct Splash: View {
    
    @EnvironmentObject var dispatcher: Dispatcher
    
    var body: some View {
        Text("Slash")
            .onAppear {
                self.dispatcher.dispatch(Usecases.booting(from: .basic(scene: .アプリはサーバで発行したUDIDが保存されていないかを調べる)))
            }
    }
}

struct Splash_Previews: PreviewProvider {
    static var previews: some View {
        Splash()
            .environmentObject(Dispatcher())
    }
}
