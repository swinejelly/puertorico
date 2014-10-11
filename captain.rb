require 'yaml'
require 'forwardable'

$goods = [:corn, :indigo, :sugar, :tobacco, :coffee]

#Generic superclass for entities that hold, take, and transfer
#numeric quantities internally stored in a hash. Intended to be
#abstract
class Container
  extend Forwardable
  def initialize(hash)
    @hash = hash
  end

  # returns whether the container has "what", where "what" is
  # :none, :any, or a symbol of any variable's name
  # :none, :any should follow the implementer's semantics
  # :none =>
  # :any => some type of goods
  def has(what)
    @hash[what] > 0
  end

  def ==(other)
    self.class == other.class && @hash == other.hash
  end

  attr_accessor :hash
  def_delegators :@hash, :[], :[]=
end

class Player < Container
  def initialize(name, corn=0, indigo=0, sugar=0, tobacco=0, coffee=0, vp=0, wharfs=0, harbors=0)
    super :name => name, :corn => corn, :indigo => indigo, :sugar => sugar, :tobacco => tobacco,
            :coffee => coffee, :vp => vp, :wharfs => wharfs, :harbors => harbors
  end

  # returns whether the player has "what", where "what" is
  # :none, :any, or a symbol of any instance variable's name
  # :none => no goods
  # :any => some type of goods
  def has(what)
    case what
    when :none
      $goods.all? {|x| @hash[x] == 0}
    when :any
      $goods.any? {|x| @hash[x] > 0}
    else
      super what
    end
  end
end

class Ship < Container
  def initialize(capacity, load=0, type=:none)
    super :capacity => capacity, :load => load, :type => type
  end
end

class State
  def initialize(players, ships, current_ix=0)
    @players = players
    @ships = ships
    @current_ix = current_ix
  end

  def current_player
    return @players[@current_ix]
  end

  # A new state where the current player has shipped as many of type goods
  # as possible onto the given ship and it is the next players turn.
  def act(action)
    nextState = Marshal.load(Marshal.dump(self))
    nextState.current_player
    nextState.current_ix = (nextState.current_ix + 1) % @players.size
    return nextState
  end

  # Retrieve actions that the current player can take.
  def get_actions(current_player_ix=@current_ix)
    player = @players[current_player_ix]
    free_types = ($goods - @ships.map {|s| s[:type]})
    @ships.each_with_index.flat_map do |ship,ship_ix|
      if ship[:type] == :none
        types = free_types.select {|g| player.has g}
        types.map do |g|
          {:type => g,
           :ship => ship_ix,
           :amount => [player[g], ship[:capacity]].min}
        end
      elsif ship[:load] < ship[:capacity] && (player.has ship[:type])
        [{:type => ship[:type],
          :ship => ship_ix,
          :amount => [player[ship[:type]], ship[:capacity]-ship[:load]].min}]
      else
        []
      end
    end
  end
  # Whether any actions can be made at this point or not
  def terminal?
    (0..@players.length-1).any? {|ix| get_actions(ix).empty?}
  end

  def ==(other)
    @players == other.players && @ships == other.ships && @current_ix == other.current_ix
  end

  attr_reader :players, :ships
  attr_accessor :current_ix
end
