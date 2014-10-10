require './captain'
require 'minitest/autorun'

class StateTest < MiniTest::Unit::TestCase
  def setup
    @players = [Player.new("Scott"), Player.new("Hudson"), Player.new("Chase")]
    @ships = [Ship.new(4), Ship.new(5), Ship.new(6)]
    @state = State.new(@players, @ships)
  end

  def test_current_player
    assert_equal @players[0], @state.current_player
    
    state2 = @state.act :none
    assert_equal @players[1], state2.current_player
    state3 = state2.act :none
    assert_equal @players[2], state3.current_player
    state4 = state3.act :none
    assert_equal @players[0], state4.current_player
  end
end
