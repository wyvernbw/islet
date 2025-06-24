//
//  ContentView.swift
//  islet
//
//  Created by calin on 24.06.2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var isHovered = false

    var size: NSSize {
        return viewModel.sizeState.asSize()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black)
                .frame(width: size.width, height: size.height)
                .animation(.spring(duration: 0.3, bounce: 0.4), value: size)
            VStack {
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onHover { isHovered in
            self.isHovered = isHovered

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if self.isHovered != isHovered {
                    return
                }
                switch isHovered {
                case true: self.viewModel.reduceSizeState(event: .hovered)
                case false: self.viewModel.reduceSizeState(event: .unhovered)
                }
            }
        }
        .onTapGesture {
            self.viewModel.reduceSizeState(event: .clicked)
        }
    }
}
