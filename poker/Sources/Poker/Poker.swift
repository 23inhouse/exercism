//Solution goes in Sources

// MARK: Poker
class Poker {
  static func bestHand(_ hands: [String]) -> String {
    let pokerHands = hands.map({ PokerHand($0)! })
    guard let best = BestHand.check(pokerHands) else {
      assert(false, "Error: No winner")
    }
    return String(describing: best.hand)
  }
}

class BestHand {
  typealias PokerHandLogic = (PokerHand) -> ([Card])

  static let logics: [PokerHandLogic] = [royalFlush, straightFlush, fourOfAKind, FullHouse, flush, straight, threeOfAKind, twoPair, pair, highCard]

  static let royalFlush: PokerHandLogic = { hand in
    let cards = straightFlush(hand)
    guard cards.count == 5 else { return [] }
    guard cards[0].rank == .ace else { return [] }
    return cards
  }

  static let straightFlush: PokerHandLogic = { hand in
    let cards = straight(hand)
    guard cards.count == 5, flush(hand).count == 5 else { return [] }
    return cards
  }

  static let fourOfAKind: PokerHandLogic = { hand in
    var cards = grouped(hand)
    guard cards.count == 4 && cards.first!.rank == cards.last!.rank else { return [] }
    for card in hand.sorted().filter({ !cards.contains($0) }) {
      cards.append(card)
    }
    return cards
  }

  static let FullHouse: PokerHandLogic = { hand in
    var cards = grouped(hand)
    guard cards.count == 5 else { return cards }
    if cards[0].rank != cards[2].rank {
      cards.reverse()
    }
    return cards
  }

  static let flush: PokerHandLogic = { hand in
    var cards = [Card]()
    for card in hand.sorted() {
      if cards.count == 0 || cards.last!.suit == card.suit {
        cards.append(card)
      }
    }
    return cards
  }

  static let straight: PokerHandLogic = { hand in
    var cards = [Card]()
    for card in hand.sorted().reversed() {
      if cards.count == 0 || cards.last!.rank.index() == card.rank.index() - 1 {
        cards.append(card)
      }
      if cards.count == 4 && cards.last!.rank == .five && card.rank == .ace {
        cards.insert(card, at: 0)
      }
    }
    return cards
  }

  static let threeOfAKind: PokerHandLogic = { hand in
    var cards = grouped(hand)
    guard cards.count == 3 else { return [] }
    for card in hand.sorted().filter({ !cards.contains($0) }) {
      cards.append(card)
    }
    return cards
  }

  static let twoPair: PokerHandLogic = { hand in
    var cards = grouped(hand)
    guard cards.count == 4 && cards.first!.rank != cards.last!.rank else { return [] }
    for card in hand.sorted().filter({ !cards.contains($0) }) {
      cards.append(card)
    }
    return cards
  }

  static let pair: PokerHandLogic = { hand in
    var cards = grouped(hand)
    guard cards.count == 2 else { return [] }
    for card in hand.sorted().filter({ !cards.contains($0) }) {
      cards.append(card)
    }
    return cards
  }

  static let highCard: PokerHandLogic = { hand in
    return hand.cards.sorted()
  }

  static func check(_ hands: [PokerHand]) -> BestHand? {
    return hands.map({ BestHand($0) }).sorted().last
  }

  static func grouped(_ hand: PokerHand) -> [Card] {
    var cards = [Card]()
    for card in hand {
      for other in hand {
        if card == other { continue }
        if cards.contains(card) { continue }

        if card.rank == other.rank {
          cards.append(card)
        }
      }
    }
    return cards.sorted()
  }

  let hand: PokerHand
  let cards: [Card]
  let score: Int

  init(_ hand: PokerHand) {
    var score = 0
    var cards = [Card]()

    for (i, logic) in BestHand.logics.enumerated() {
      cards = logic(hand)
      if cards.count == 5 {
        score = BestHand.logics.count - i
        break
      }
    }

    self.hand = hand
    self.cards = cards
    self.score = score
  }
}

extension BestHand: Comparable {
  static func == (lhs: BestHand, rhs: BestHand) -> Bool {
    return lhs.score == rhs.score && lhs.highCard() == rhs.highCard()
  }

  static func < (lhs: BestHand, rhs: BestHand) -> Bool {
    // print("\(lhs.hand) < \(rhs.hand) == \(lhs.score) < \(rhs.score) || \(lhs.highCard()) < \(rhs.highCard()) || \(lhs.secondHighCard(rhs)) < \(rhs.secondHighCard(lhs)) || \(lhs.cards.first!.suit.index()) < \(rhs.cards.first!.suit.index())")
    return lhs.score < rhs.score
      || (lhs.score == rhs.score && lhs.highCard() < rhs.highCard())
      || (lhs.highCard() == rhs.highCard() && lhs.secondHighCard(rhs) < rhs.secondHighCard(lhs))
      || (lhs.secondHighCard(rhs) == rhs.secondHighCard(lhs) && lhs.cards.first!.suit < rhs.cards.first!.suit)
  }

  func highCard() -> Rank {
    return cards[0].rank
  }

  func secondHighCard(_ other: BestHand) -> Rank {
    let highCards = hand.filter({ !other.hand.ranks().contains($0.rank) })
    guard let highestCard = highCards.sorted().last else { return .two }
    return highestCard.rank
  }
}
