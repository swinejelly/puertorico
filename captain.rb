require 'yaml'

$goods = [:corn, :indigo, :sugar, :tobacco, :coffee]
class Player
  def initialize(name, corn=0, indigo=0, sugar=0, tobacco=0, coffee=0, vp=0, wharfs=0, harbors=0)
    @name = name
    @corn = corn
    @indigo = indigo
    @sugar = sugar
    @tobacco = tobacco
    @coffee = coffee
    @vp = vp
    @wharfs = wharfs
    @harbors = harbors
  end

  # returns whether the player has "what", where "what" is
  # :none, :any, or a symbol of any instance variable's name
  # :none => no goods
  # :any => some type of goods
  def has(what)
    case what
    when :none
      $goods.all? {|x| self.how_many(x) == 0}
    when :any
      $goods.any? {|x| self.how_many(x) > 0}
    else
      self.how_many(what) > 0
    end
  end

  # helper function, looks up how many there are of the named resource
  # e.g. player.how_many :corn
  def how_many(what)
    self.method(what).call
  end

  attr_accessor :id, :corn, :indigo, :sugar, :tobacco, :coffee, :vp, :wharfs, :harbors
end

class Ship
  def initialize(capacity, load=0, type=:none)
    @capacity = capacity
    @load = load
    @type = type
  end

  attr_accessor :capacity, :load, :type
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

  # Retrieve actions that the current player can take.
  def get_actions(current_player_ix=@current_ix)
    player = @players[current_player_ix]
    free_types = ($goods - @ships.map {|s| s.type})
    @ships.each_with_index.flat_map do |ship,ship_ix|
      if ship.type == :none
        types = free_types.select {|g| player.has g}
        types.map do |g|
          {:type => g,
           :ship => ship_ix,
           :amount => [player.how_many(g), ship.capacity].min}
        end
      elsif ship.load < ship.capacity && (player.has ship.type)
        [{:type => ship.type,
          :ship => ship_ix,
          :amount => [player.how_many(ship.type), ship.capacity-ship.load].min}]
      else
        []
      end
    end
  end
  # Whether any actions can be made at this point or not
  def terminal?
    (0..@players.length-1).any? {|ix| get_actions(ix).empty?}
  end

  attr_reader :players, :ships
  attr_accessor :current_ix
end
