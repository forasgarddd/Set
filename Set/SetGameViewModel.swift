//
//  SetGameViewModel.swift
//  Set
//
//  Created by Ivan Devitskyi on 08/11/2025.
//

import Foundation
import SwiftUI

class SetGameViewModel: ObservableObject {
    
    private static func createSetGame() -> SetGame {
        return SetGame()
    }
    
    @Published private var model: SetGame
    
    init() {
        self.model = SetGameViewModel.createSetGame()
    }
    
    var deck: [SetGame.Card] {
        get {
            return model.deck
        }
        set {
            model.deck = newValue
        }
    }
    
    var cardsOnTable: [SetGame.Card] {
        get {
            return model.cardsOnTable
        }
        set {
            model.cardsOnTable = newValue
        }
    }
    
    var chosenCards: [SetGame.Card] {
        return model.chosenCards
    }
    
    var dealtCards: [SetGame.Card] {
        get {
            return model.dealtCards
        }
        set {
            model.dealtCards = newValue
        }
    }
    
    var discardedCards: [SetGame.Card] {
        return model.discardedCards
    }
    
    // MARK: - Intents
    
    func dealThreeCards() {
        _ = model.deal(numberOfCards: 3)
    }
    
    func dealOneCard() {
        _ = model.deal(numberOfCards: 1)
    }
    
    func createNewGame() {
        model = SetGameViewModel.createSetGame()
    }
    
    func choose(_ card: SetGame.Card) {
        model.choose(card)
    }

}
