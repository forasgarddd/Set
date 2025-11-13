//
//  SetGame.swift
//  Set
//
//  Created by Ivan Devitskyi on 08/11/2025.
//

import Foundation

struct SetGame/*<CardContent>*/ {
    var deck: [Card]
    var cardsOnTable: [Card] = []
    var chosenCards: [Card] = []
    var selectedIndices: [Int] = []
    var dealtCards: [Card] = []
    var discardedCards: [Card] = []
    
    init() /*numberOfCards: Int, cardContentFactory: (Int) -> CardContent)*/ {
        deck = []
        for shape in Card.Shape.allCases {
            for color in Card.Color.allCases {
                for shading in Card.Shading.allCases {
                    for numberOfSymbols in Card.SymbolsCount.allCases {
                        deck.append(Card(shape: shape, color: color, shading: shading, symbolsCount: numberOfSymbols, id: "\(shape)-\(color)-\(shading)-\(numberOfSymbols)"))
                    }
                }
            }
        }
        deck.shuffle()
        cardsOnTable = deal(numberOfCards: 12)
        dealtCards = cardsOnTable
        for card in cardsOnTable {
            deck.removeAll { $0.id == card.id }
        }
        //print(dealtCards)
    }
    
    
    mutating func deal(numberOfCards: Int) -> [Card] {
        let trio = selectedIndices.sorted()
        let trioWasMatched = trio.allSatisfy { cardsOnTable[$0].isMatched }
        if trio.count >= 3 {
            if trioWasMatched{
                for i in trio {
                    let newCard = deck.removeLast()
                    cardsOnTable[i].isSelected = false
                    cardsOnTable[i].isMismatched = false
                    cardsOnTable[i].isMatched = false
                    discardedCards.append(cardsOnTable[i])
                    cardsOnTable[i] = newCard
                    dealtCards.append(newCard)
                    selectedIndices.removeAll()
                }
            } else {
                for card in deck[0..<numberOfCards] {
                    cardsOnTable.append(card)
                    dealtCards.append(card)
                    deck.removeAll { $0.id == card.id }
                }
            }
            
        } else {
            for card in deck[0..<numberOfCards] {
                dealtCards.append(card)
                cardsOnTable.append(card)
                deck.removeAll { $0.id == card.id }
            }
        }
        print(dealtCards.count)
        print(deck.count)
        print(dealtCards == cardsOnTable)
        return dealtCards
    }
    
    mutating func discard(_ index: Int) {
        discardedCards.append(cardsOnTable[index])
        cardsOnTable.remove(at: index)
    }
    
    mutating func choose(_ card: Card) {
        print(card)
        if let chosenIndex = cardsOnTable.firstIndex(where: { $0.id == card.id }) {
            // less than 3 selected
            if selectedIndices.count < 3 {
                // if chose selected
                if selectedIndices.contains(chosenIndex) {
                    selectedIndices.removeAll { $0 == chosenIndex }
                    cardsOnTable[chosenIndex].isSelected = false
                    cardsOnTable[chosenIndex].isMismatched = false
                    return
                } else {
                    // if chose not selected
                    selectedIndices.append(chosenIndex)
                    cardsOnTable[chosenIndex].isSelected = true
                }
                // if just chose one more card after two were chosen before
                if selectedIndices.count == 3 {
                    let trio = [cardsOnTable[selectedIndices[0]], cardsOnTable[selectedIndices[1]], cardsOnTable[selectedIndices[2]]]
                    // if three cards are a set
                    if isSet(chosenCards: trio) {
                        for i in selectedIndices {
                            cardsOnTable[i].isMatched = true
                        }
                        // if three cards are not a set
                    } else {
                        for i in selectedIndices {
                            cardsOnTable[i].isMismatched = true
                        }
                    }
                }
                // next tap after 3 selected
            } else {
                let trio = selectedIndices.sorted()
                let tappedWasInTrio = trio.contains(chosenIndex)
                let tappedID = cardsOnTable[chosenIndex].id
                let trioWasMatched = trio.allSatisfy { cardsOnTable[$0].isMatched }
                
                if trioWasMatched {
                    
                    for i in trio.reversed() {
                        cardsOnTable[i].isSelected = false
                        cardsOnTable[i].isMismatched = false
                        cardsOnTable[i].isMatched = false
                        
                        // TODO: - Discarded
                        discard(i)
                        print(discardedCards)
                    }
                    
                } else {
                    for i in trio {
                        cardsOnTable[i].isSelected = false
                        cardsOnTable[i].isMismatched = false
                    }
                }
                selectedIndices.removeAll()
                
                if trioWasMatched && tappedWasInTrio {
                    return
                }
                if let newIndex = cardsOnTable.firstIndex(where: { $0.id == tappedID }) {
                    cardsOnTable[newIndex].isSelected = true
                    selectedIndices = [newIndex]
                }
            }
            
        }
    }
    
    func isSet(chosenCards: [Card]) -> Bool {
        if chosenCards.count == 3 {
            
            let a = chosenCards[0]
            let b = chosenCards[1]
            let c = chosenCards[2]
            
            let shapeOk =
            areAllEqual(a: a.shape, b: b.shape, c: c.shape) || areAllUnequal(a: a.shape, b: b.shape, c: c.shape)
            
            let colorOk =
            areAllEqual(a: a.color, b: b.color, c: c.color) ||
            areAllUnequal(a: a.color, b: b.color, c: c.color)
            
            let shadingOk =
            areAllEqual(a: a.shading, b: b.shading, c: c.shading) ||
            areAllUnequal(a: a.shading, b: b.shading, c: c.shading)
            
            let symbolsCountOk =
            areAllEqual(a: a.symbolsCount, b: b.symbolsCount, c: c.symbolsCount) ||
            areAllUnequal(a: a.symbolsCount, b: b.symbolsCount, c: c.symbolsCount)
            
            return shapeOk && colorOk && shadingOk && symbolsCountOk
        } else {
            return false
        }
    }
    
    func areAllEqual<E: Equatable>(a: E, b: E, c: E) -> Bool {
        if a == b && b == c && c == a {
            return true
        } else {
            return false
        }
    }
    
    func areAllUnequal<E: Equatable>(a: E, b: E, c:E) -> Bool {
        if a != b && b != c && c != a {
            return true
        } else {
            return false
        }
    }
    
    
    struct Card: Identifiable, Equatable, CustomDebugStringConvertible {
        
        let shape: Shape
        let color: Color
        let shading: Shading
        let symbolsCount: SymbolsCount
        var isSelected: Bool = false
        var isMatched: Bool = false
        var isMismatched: Bool = false
        
        var id: String
        
        enum Shape: String, CaseIterable {
            case oval, diamond, rectangle
        }
        enum Color: String, CaseIterable {
            case red, green, blue
        }
        enum Shading: String, CaseIterable {
            case solid, striped, open
        }
        enum SymbolsCount: Int, CaseIterable {
            case one = 1, two, three
        }
        
        var debugDescription: String {
            "\(shape)-\(color)-\(shading)-\(symbolsCount) isSelected: \(isSelected)"
        }
    }
}
