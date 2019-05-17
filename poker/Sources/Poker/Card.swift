// MARK: Rank
enum Rank: String {
  case two = "2"
  case three = "3"
  case four = "4"
  case five = "5"
  case six = "6"
  case seven = "7"
  case eight = "8"
  case nine = "9"
  case ten = "10"
  case jack = "J"
  case queen = "Q"
  case king = "K"
  case ace = "A"
}

extension Rank: Comparable {
  static let ranks: [Rank] = [two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace]

  static func == (lhs: Rank, rhs: Rank) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }

  static func < (lhs: Rank, rhs: Rank) -> Bool {
    return lhs.index() < rhs.index()
  }

  func index() -> Int {
    return Int(Rank.ranks.firstIndex(of: self)!)
  }
}

extension Rank: CustomStringConvertible {
  var description: String {
        return rawValue
    }
}

// MARK: Suit
enum Suit: String {
  case clubs = "♧"
  case diamonds = "♢"
  case hearts = "♡"
  case spades = "♤"
}

extension Suit: Comparable {
  static let order: [Suit] = [clubs, diamonds, hearts, spades]

  static func == (lhs: Suit, rhs: Suit) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }

  static func < (lhs: Suit, rhs: Suit) -> Bool {
    return lhs.index() < rhs.index()
  }

  func index() -> Int {
    return Int(Suit.order.firstIndex(of: self)!)
  }
}

extension Suit: CustomStringConvertible {
  var description: String {
        return rawValue
    }
}

// MARK: Card
struct Card {
  let rank: Rank
  let suit: Suit

  init?(_ from: String) {
    guard from.count > 1 else { return nil }

    let rankRange = 0 ..< Array(from).count - 1
    let rankFrom = Array(from)[rankRange].map({ String($0) }).joined()
    let suitFrom = String(from.last!)

    guard let rank = Rank(rawValue: rankFrom) else { return nil }
    guard let suit = Suit(rawValue: suitFrom) else { return nil }
    self.rank = rank
    self.suit = suit
  }
}

extension Card: Comparable {

  static func == (lhs: Card, rhs: Card) -> Bool {
    return lhs.rank == rhs.rank && lhs.suit == rhs.suit
  }

  static func < (lhs: Card, rhs: Card) -> Bool {
    return lhs.rank > rhs.rank || (lhs.rank == rhs.rank && lhs.suit > rhs.suit)
  }
}
