//
//  SetGameView.swift
//  Set
//
//  Created by Ivan Devitskyi on 08/11/2025.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject private var viewModel: SetGameViewModel
    
    init(viewModel: SetGameViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        EmptyView()
    }
}

#Preview {
    SetGameView(viewModel: SetGameViewModel())
}
