//
//  ContentView.swift
//  islet
//
//  Created by calin on 24.06.2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel 

    var body: some View {

        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white).ignoresSafeArea()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .ignoresSafeArea()
        .onHover {
            isHovered in
            switch (self.viewModel.sizeState, isHovered) {
            case (.idle, true):
                self.viewModel.reduceSizeState(event: .hovered)
            case (.hover, false):
                self.viewModel.reduceSizeState(event: .unhovered)
            default:
                break
            }
        }
    }
}

