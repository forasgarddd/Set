//
//  SetGameView.swift
//  Set
//
//  Created by Ivan Devitskyi on 08/11/2025.
//

import SwiftUI

struct SetGameView: View {
    typealias Card = SetGame.Card
    @ObservedObject private var viewModel: SetGameViewModel
    
    private let aspectRatio: CGFloat = 2/3
    private let deckWidth: CGFloat = 50
    private let dealAnimation: Animation = .easeInOut(duration: 0.5)
    private let dealInterval: TimeInterval = 0.1
    
    init(viewModel: SetGameViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Text("Set")
            .font(.largeTitle)
        cards
        
        VStack {

            HStack {
                deck
                    .disabled(viewModel.deck.isEmpty)
                discardPile
                
            }
            Button("New Game") {
                withAnimation {
                    viewModel.createNewGame()
                }
            }
            Button("Shuffle") {
                withAnimation {
                    viewModel.cardsOnTable = viewModel.cardsOnTable.shuffled()
                }

            }
        }
        
    }
    
    private var cards: some View {
        AspectVGrid(viewModel.cardsOnTable, aspectRatio: aspectRatio) { card in
            
            CardView(card, isFaceUp: true)
                .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                .transition(.asymmetric(insertion: .identity, removal: .identity))
                .matchedGeometryEffect(id: card.id, in: discardingNamespace)
                .padding(4)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        viewModel.choose(card)
                    }
                }
        }
    }
    
    @Namespace private var dealingNamespace
    @Namespace private var discardingNamespace
    
    private var deck: some View {
        ZStack {
            let base = RoundedRectangle(cornerRadius: 12)
            Group {
                base.fill(.white)
                base.strokeBorder(lineWidth: 4)
            }
            ForEach(viewModel.deck) { card in
                CardView(card, isFaceUp: false)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
            }
            
        }
        .frame(width: deckWidth, height: deckWidth / aspectRatio)
        .onTapGesture {
            deal()
        }
    }
    
    private var discardPile: some View {
        ZStack {
                let base = RoundedRectangle(cornerRadius: 12)
                Group {
                    base.fill(.white)
                    base.strokeBorder(lineWidth: 4)
                }
            ForEach(viewModel.discardedCards) { card in
                CardView(card, isFaceUp: true)
                    .matchedGeometryEffect(id: card.id, in: discardingNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
            }
        }
        .frame(width: deckWidth, height: deckWidth / aspectRatio)
    }
    
    private func deal() {
        withAnimation(.easeInOut(duration: 0.5)) {
            viewModel.dealThreeCards()
        }
    }
}

struct CardView: View {
    let card: SetGame.Card
    var isFaceUp: Bool
    
    init(_ card: SetGame.Card, isFaceUp: Bool) {
        self.card = card
        self.isFaceUp = isFaceUp
    }
    
    var body: some View {
        ZStack {
            let base = RoundedRectangle(cornerRadius: 12)
            Group {
                base.fill(.white)
                base.strokeBorder(lineWidth: 4)
                
                if isFaceUp {
                    renderSymbols(shape: makeSymbol(from: card.shape), color: uiColor(from: card.color), shading: (card.shading), count: card.symbolsCount)
                }
            }
            .foregroundStyle(card.isMismatched ? .red : card.isMatched ? .green : .black)
            .animation(nil, value: card.isMatched)
            .animation(nil, value: card.isMismatched)
            .foregroundStyle(card.isSelected ? .yellow : .black)
            base.fill(.yellow).opacity(card.isSelected ? 0.25 : 0)
                .animation(nil, value: card.isSelected)
        }
    }
    
    func makeSymbol(from shape: SetGame.Card.Shape) -> AnyShape {
        switch shape {
        case .oval:
            return AnyShape(Ellipse())
        case .diamond:
            return AnyShape(Diamond())
        case .rectangle:
            return AnyShape(Rectangle())
        }
    }
    
    func uiColor(from color: SetGame.Card.Color) -> Color {
        switch color {
        case .red:
            return .red
        case .green:
            return .green
        case .blue:
            return .blue
        }
    }
    
    @ViewBuilder
    func render(shape: some Shape, color: Color, shading: SetGame.Card.Shading, lineWidth: CGFloat) -> some View {
        switch shading {
        case .solid:
            shape.fill(color)
        case .striped:
            shape.fill(color.opacity(0.5)).overlay(shape.stroke(color, lineWidth: lineWidth))
        case .open:
            shape.stroke(color, lineWidth: 2)
        }
    }
    
    @ViewBuilder
    func renderSymbols(shape: some Shape, color: Color, shading: SetGame.Card.Shading, count: SetGame.Card.SymbolsCount) -> some View {
        let count = count.rawValue
        
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let symbolAreaHeight = height * 0.60
            let symbolHeight = symbolAreaHeight / 3
            let symbolAspectRatio: CGFloat = 3/1
            let symbolWidth = min(width * 0.6, symbolHeight * CGFloat(symbolAspectRatio))
            let lineWidth: CGFloat = symbolHeight * 0.07
            
            VStack(spacing: symbolHeight * 0.3) {
                ForEach(0..<count, id: \.self) { _ in
                    render(shape: shape, color: color, shading: shading, lineWidth: lineWidth)
                        .frame(width: symbolWidth, height: symbolHeight)
                }
            }
            .frame(width: width, height: symbolAreaHeight, alignment: .center)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .scaleEffect(card.isMatched ? 1.1 : 1)
            .animation(
                card.isMatched
                ? .easeInOut(duration: 1).repeatForever()
                : .default,
                value: card.isMatched
            )
            .scaleEffect(card.isMismatched ? 0.9 : 1)
            .animation(
                card.isMismatched
                ? .easeInOut(duration: 1).repeatForever()
                : .default,
                value: card.isMismatched
            )
            
        }
    }
}

extension Animation {
    static func scale(duration: TimeInterval) -> Animation {
        return .easeInOut(duration: 1).repeatForever()
    }
    static func downscale(duration: TimeInterval) -> Animation {
        return .easeInOut(duration: 1).repeatForever()
    }
}

#Preview {
    SetGameView(viewModel: SetGameViewModel())
}
