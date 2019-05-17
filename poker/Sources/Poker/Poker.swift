//Solution goes in Sources

// MARK: Poker
class Poker {
  static func bestHand(_ hands: [String]) -> String {
    let pokerHands = hands.map({ PokerHand($0)! })
    guard let winner = PokerHandRules.check(pokerHands) else {
      assert(false, "Error: No winner")
    }
    return String(describing: winner.hand)
  }
}

// MARK: Rules
struct PokerHandRules {
  static let WinningHands: [(PlayableHand & Hand).Type] = [
    RoyalFlush.self,
    StraightFlush.self,
    FourOfAKind.self,
    FullHouse.self,
    Flush.self,
    Straight.self,
    ThreeOfAKind.self,
    TwoPair.self,
    OnePair.self,
    HighCard.self,
  ]

  static func check(_ hands: [PokerHand]) -> PlayableHand? {
    var bestHands = [Any]()

    for hand in hands {
      for winningHand in WinningHands {
        if let possible = winningHand.init(hand) {
          bestHands.append(possible)
          break
        }
      }
    }

    assert(bestHands.count > 0, "Error: No best hand")

    return (bestHands as! [PlayableHand]).sorted().last
  }
}

class PlayableHand {
  var score: Int
  var hand: PokerHand
  var cards: [Card]!

  func pairedCards(_ hand: PokerHand) -> [Card] {
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

  func describable(_ str: String) -> String {
    return "\(PokerHand(cards: cards)): \(str)"
  }

  init(score: Int, hand: PokerHand) {
    self.score = score
    self.hand = hand
  }
}

extension PlayableHand: Comparable {
  static func == (lhs: PlayableHand, rhs: PlayableHand) -> Bool {
    return lhs.score == rhs.score && lhs.highCard() == rhs.highCard()
  }

  static func < (lhs: PlayableHand, rhs: PlayableHand) -> Bool {
    // print("\(lhs.hand) < \(rhs.hand) == \(lhs.score) < \(rhs.score) || \(lhs.highCard()) < \(rhs.highCard()) || \(lhs.secondHighCard(rhs)) < \(rhs.secondHighCard(lhs)) || \(lhs.cards.first!.suit.index()) < \(rhs.cards.first!.suit.index())")
    return lhs.score < rhs.score
      || (lhs.score == rhs.score && lhs.highCard() < rhs.highCard())
      || (lhs.highCard() == rhs.highCard() && lhs.secondHighCard(rhs) < rhs.secondHighCard(lhs))
      || (lhs.secondHighCard(rhs) == rhs.secondHighCard(lhs) && lhs.cards.first!.suit < rhs.cards.first!.suit)
  }

  func highCard() -> Rank {
    return cards[0].rank
  }

  func secondHighCard(_ other: PlayableHand) -> Rank {
    let highCards = hand.filter({ !other.hand.ranks().contains($0.rank) })
    guard let highestCard = highCards.sorted().last else { return .two }
    return highestCard.rank
  }
}

protocol Hand {
  init?(_: PokerHand)
  static var score: Int { get }
}

class RoyalFlush: PlayableHand, Hand {
  static let score = 10

  func check(_ hand: PokerHand) -> [Card] {
    guard let straightFlush = StraightFlush.init(hand) else { return [] }
    guard straightFlush.cards.first!.rank == .ace else { return [] }

    return straightFlush.cards
  }

  required init?(_ hand: PokerHand) {
    super.init(score: type(of: self).score, hand: hand)
    self.cards = check(hand)

    guard cards.count == 5 else { return nil }
  }
}

extension RoyalFlush: CustomStringConvertible {
  var description: String {
    return describable("Royal Flush \(cards.first!.rank)")
  }
}

class StraightFlush: PlayableHand, Hand {
  static let score = 10

  func check(_ hand: PokerHand) -> [Card] {
    guard let straight = Straight.init(hand), let _ = Flush.init(hand) else { return [] }

    return straight.cards
  }

  required init?(_ hand: PokerHand) {
    super.init(score: type(of: self).score, hand: hand)
    self.cards = check(hand)

    guard cards.count == 5 else { return nil }
  }
}

extension StraightFlush: CustomStringConvertible {
  var description: String {
    return describable("Straight Flush \(cards.first!.rank) high")
  }
}

class FourOfAKind: PlayableHand, Hand {
  static let score = 10

  func check(_ hand: PokerHand) -> [Card] {
    var cards = pairedCards(hand)
    guard cards.count == 4 && cards.first!.rank == cards.last!.rank else { return [] }
    for card in hand.sorted().filter({ !cards.contains($0) }) {
      cards.append(card)
    }

    return cards
  }

  required init?(_ hand: PokerHand) {
    super.init(score: type(of: self).score, hand: hand)
    self.cards = check(hand)

    guard cards.count == 5 else { return nil }
  }
}

extension FourOfAKind: CustomStringConvertible {
  var description: String {
    return describable("Four of a kind of \(cards.first!.rank)s")
  }
}

class FullHouse: PlayableHand, Hand {
  static let score = 9

  func check(_ hand: PokerHand) -> [Card] {
    var cards = pairedCards(hand)
    guard cards.count == 5 else { return cards }
    if cards[0].rank != cards[2].rank {
      cards.reverse()
    }
    return cards
  }

  required init?(_ hand: PokerHand) {
    super.init(score: type(of: self).score, hand: hand)
    self.cards = check(hand)

    guard cards.count == 5 else { return nil }
  }
}

extension FullHouse: CustomStringConvertible {
  var description: String {
    return describable("Full House \(cards.first!.rank)s and \(cards.last!.rank)s")
  }
}

class Flush: PlayableHand, Hand {
  static let score = 8

  func check(_ hand: PokerHand) -> [Card] {
    var cards = [Card]()
    for card in hand.sorted() {
      if cards.count == 0 || cards.last!.suit == card.suit {
        cards.append(card)
      }
    }
    return cards
  }

  required init?(_ hand: PokerHand) {
    super.init(score: type(of: self).score, hand: hand)
    self.cards = check(hand)

    guard cards.count == 5 else { return nil }
  }
}

extension Flush: CustomStringConvertible {
  var description: String {
    return describable("Flush \(cards.first!.rank) high")
  }
}

class Straight: PlayableHand, Hand {
  static let score = 7

  func check(_ hand: PokerHand) -> [Card] {
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

  required init?(_ hand: PokerHand) {
    super.init(score: type(of: self).score, hand: hand)
    self.cards = check(hand)

    guard cards.count == 5 else { return nil }
  }
}

extension Straight: CustomStringConvertible {
  var description: String {
    return describable("Straight \(cards.first!.rank) high")
  }
}

class ThreeOfAKind: PlayableHand, Hand {
  static let score = 4

  func check(_ hand: PokerHand) -> [Card] {
    var cards = pairedCards(hand)
    guard cards.count == 3 else { return [] }
    for card in hand.sorted().filter({ !cards.contains($0) }) {
      cards.append(card)
    }

    return cards
  }

  required init?(_ hand: PokerHand) {
    super.init(score: type(of: self).score, hand: hand)
    self.cards = check(hand)

    guard cards.count == 5 else { return nil }
  }
}

extension ThreeOfAKind: CustomStringConvertible {
  var description: String {
    return describable("Three of a kind of \(cards.first!.rank)s")
  }
}

class TwoPair: PlayableHand, Hand {
  static let score = 3

  func check(_ hand: PokerHand) -> [Card] {
    var cards = pairedCards(hand)
    guard cards.count == 4 && cards.first!.rank != cards.last!.rank else { return [] }
    for card in hand.sorted().filter({ !cards.contains($0) }) {
      cards.append(card)
    }

    return cards
  }

  required init?(_ hand: PokerHand) {
    super.init(score: type(of: self).score, hand: hand)
    self.cards = check(hand)

    guard cards.count == 5 else { return nil }
  }
}

extension TwoPair: CustomStringConvertible {
  var description: String {
    return describable("Two Pair \(cards[0].rank)s and \(cards[2].rank)s")
  }
}

class OnePair: PlayableHand, Hand {
  static let score = 2

  func check(_ hand: PokerHand) -> [Card] {
    var cards = pairedCards(hand)
    guard cards.count == 2 else { return [] }
    for card in hand.sorted().filter({ !cards.contains($0) }) {
      cards.append(card)
    }

    return cards
  }

  required init?(_ hand: PokerHand) {
    super.init(score: type(of: self).score, hand: hand)
    self.cards = check(hand)

    guard cards.count == 5 else { return nil }
  }
}

extension OnePair: CustomStringConvertible {
  var description: String {
    return describable("Pair of \(cards.first!.rank)s")
  }
}

class HighCard: PlayableHand, Hand {
  static let score = 1

  func check(_ hand: PokerHand) -> [Card] {
    var cards = [Card]()
    for card in hand.sorted() {
      guard cards.count == 0 || cards.last?.rank != card.rank else { return [] }
      cards.append(card)
    }
    return cards
  }

  required init?(_ hand: PokerHand) {
    super.init(score: type(of: self).score, hand: hand)
    self.cards = check(hand)

    guard cards.count == 5 else { return nil }
  }
}

extension HighCard: CustomStringConvertible {
  var description: String {
    return describable("\(cards.first!.rank) card high")
  }
}
