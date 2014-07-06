class Card
  attr_accessor :suit, :value

  def initialize(suit, value)
    @suit = suit
    @value = value
  end

  def to_s
    "#{value} of #{suit}"
  end
end

class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    ['Hearts', 'Diamonds', 'Spades', 'Clubs'].each do |suit|
      ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'].each do |value|
        @cards << Card.new(suit, value)
      end
    end
    scramble!
  end

  def scramble!
    cards.shuffle!
  end
end

class Player

end

class Dealer

end
