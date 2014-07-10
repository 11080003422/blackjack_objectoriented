# Blackjack is played by a dealer and one or more players.
# In the beginning of the game dealer gets a card, then gives a card to the players,
# gets another card, then gives another card to the players.
# Players can only see the first card of the dealer.
# First, one of the players goes and hits until he decides to stand, goes bust, or hits blackjack or 21.
# This goes on until all the players are finished.
# Then plays the dealer.
# If the dealer and a player both hit 21, they are tied.
# Otherwise, the one with 21, the one that is not bust, or the one with a higher total wins.

require 'pry'

class Card
  attr_reader :suit, :value

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

  def take_card
    cards.pop
  end
end

module PlayerDecision
  def hit_or_stand
    begin
      puts "(H)it or (S)tand?"
      input = gets.chomp.downcase
    end until input == 'h' || input == 's'
    input
  end
end

module DealerDecision
  def hit_or_stand
    total = Blackjack.get_total(self.hand)
    
    return 'h' if total < 17
    's'
  end
end

class Player
  include PlayerDecision

  attr_accessor :hand
  attr_reader :dealer

  def initialize(dealer)
    @hand = []
    @dealer = dealer
  end

  def hit
    hand << dealer.give_card
  end
end

class Dealer
  include DealerDecision

  attr_accessor :hand
  attr_reader :deck

  def initialize(deck)
    @deck = deck
    @hand = []
  end

  def give_card
    # An edge case that I currently do not
    # want to deal with is what happens when
    # the deck runs out of cards. Should
    # probably be dealt with in the take_card
    # method.
    deck.take_card
  end

  def hit
    hand << self.give_card
  end

  def deal_cards(player)
    player.hand << self.give_card
    self.hand << self.give_card
    player.hand << self.give_card
    self.hand << self.give_card
  end
end

module Output
  
end

class Blackjack
  attr_reader :deck, :dealer, :player

  def self.get_total(hand)
    # binding.pry
    total = 0
    has_ace = false
    hand.each do |card|
      if card.value.to_i != 0
        total += card.value.to_i
      elsif card.value == 'A'
        has_ace = true
        total += 1
      else
        total += 10
      end
    end

    total += 10 if total <= 11 && has_ace
    total
  end

  def initialize
    @deck = Deck.new
    @dealer = Dealer.new(@deck)
    @player = Player.new(@dealer)
  end

  def show_table(user_hand, dealer_hand, hide_dealer = true)
    system 'clear' or system 'cls'
    show_cards("Dealer", dealer_hand, hide_dealer)
    show_cards("User", user_hand)
  end

  def show_cards(name, hand, hide_dealer_card = false)
    print "#{name} cards: " 
    hand.each_with_index do |card, i|
      if i == 0 && hide_dealer_card
        print 'XXXXXXXXXXX'
      else
        print card.to_s
      end

      print ', ' if i < hand.size - 1
    end

    # binding.pry

    print "\t Total: " + Blackjack.get_total(hand).to_s if !hide_dealer_card

    puts "\n\n"
  end

  def run
    dealer.deal_cards(player)
    show_table(player.hand, dealer.hand)

    if has_blackjack?(dealer) && has_blackjack?(player)
      print_and_quit "Tie."
    elsif has_blackjack?(dealer)
      print_and_quit "Dealer won."
    elsif has_blackjack?(player)
      print_and_quit "Player won."
    end

    begin
      user_action = player.hit_or_stand
      player.hit if user_action == 'h'
      show_table(player.hand, dealer.hand)
      if Blackjack.get_total(player.hand) > 21
        print_and_quit "You're bust, dealer won."
      end
    end until user_action == 's'

    begin
      dealer_action = dealer.hit_or_stand
      dealer.hit if dealer_action == 'h'
      show_table(player.hand, dealer.hand, false)
      if Blackjack.get_total(dealer.hand) > 21
        print_and_quit "Dealer's bust, you won."
      end
    end until dealer_action == 's'

    if Blackjack.get_total(dealer.hand) == Blackjack.get_total(player.hand)
      print_and_quit "Tie."
    elsif Blackjack.get_total(dealer.hand) > Blackjack.get_total(player.hand)
      print_and_quit "Dealer won."
    else
      print_and_quit "Player won."
    end
  end

  private

  def print_and_quit(message)
    show_table(player.hand, dealer.hand, false)
    puts message
    exit
  end

  def has_blackjack?(person)
    person.hand.count == 2 && Blackjack.get_total(person.hand) == 21
  end
end

Blackjack.new.run