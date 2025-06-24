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
                .fill(Color.black).ignoresSafeArea()
            VStack {
            }

        }
        .ignoresSafeArea()
        .onHover {
            isHovered in
            switch isHovered {
            case true: self.viewModel.reduceSizeState(event: .hovered)
            case false: self.viewModel.reduceSizeState(event: .unhovered)
            }
        }
    }
}
