require 'yaml'

class Player
  def initialize(name, corn=0, indigo=0, sugar=0, tobacco=0, coffee=0, vp=0, wharfs=0, harbor=0)
    @name = name
    @corn = corn
    @indigo = indigo
    @sugar = sugar
    @tobacco = coffee
    @coffee = coffee
    @vp = vp
    @wharfs = wharfs
  end

  attr_accessor :id, :corn, :indigo, :sugar, :tobacco, :coffee, :vp, :wharfs, :harbor
end

class Ship
  def initialize(capacity)
    @capacity = capacity
    @load = 0
    @type = :none
  end

  attr_reader :capacity, :load, :type
end

class State
  def initialize(players, ships)
    @players = players
    @ships = ships
    @current_ix = 0
  end
  
  def current_player
    return @players[@current_ix]
  end

  # A new state where the current player has shipped as many of type goods
  # as possible onto the given ship and it is the next players turn.
  def act(action)
    nextState = self.clone
    nextState.current_ix = (nextState.current_ix + 1) % @players.size
    return nextState
  end

  attr_reader :players, :ships
  attr_accessor :current_ix
end
