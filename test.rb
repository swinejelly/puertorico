require './captain'
require 'minitest/autorun'

class StateTest < MiniTest::Unit::TestCase
  def setup
    @players = [Player.new("Scott"), Player.new("Hudson"), Player.new("Chase")]
    @ships = [Ship.new(4), Ship.new(5), Ship.new(6)]
    @state = State.new(@players, @ships)

    @players2 = [Player.new("Scott", 3, 0, 0, 1, 2),
                 Player.new("Chase", 0, 0, 6, 2, 2),
                 Player.new("Brian", 8, 4, 0, 0, 0)]
    @ships2 = [Ship.new(4), Ship.new(5), Ship.new(6, 2, :corn)]
    @state2 = State.new(@players2, @ships2)

    @ships3 = [Ship.new(4,4,:corn), Ship.new(5,5, :tobacco), Ship.new(6,6,:indigo)]
    @state3 = State.new(@players2, @ships3)

  end

  def test_has
    scott = @players[0]
    assert scott.has :none
    assert !(scott.has :any)
    assert !(scott.has :vp)

    chase = @players2[1]
    assert chase.has :any
    assert !(chase.has :none)
    assert chase.has :sugar
    assert !(chase.has :harbors)
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

  def test_get_actions_no_goods
    # Players with no goods of course cannot take actions
    (0..2).each do |x|
      assert_empty @state.get_actions(x)
    end
  end

  def test_get_actions
    expected0 = [{:type => :coffee,  :ship => 0, :amount => 2},
                 {:type => :coffee,  :ship => 1, :amount => 2},
                 {:type => :tobacco, :ship => 0, :amount => 1},
                 {:type => :tobacco, :ship => 1, :amount => 1},
                 {:type => :corn,    :ship => 2, :amount => 3}]

    expected1 = [{:type => :sugar, :ship => 0, :amount => 4},
                 {:type => :sugar, :ship => 1, :amount => 5},
                 {:type => :tobacco, :ship => 0, :amount => 2},
                 {:type => :tobacco, :ship => 1, :amount => 2},
                 {:type => :coffee, :ship => 0, :amount => 2},
                 {:type => :coffee, :ship => 1, :amount => 2}]

    expected2 = [{:type => :indigo, :ship => 0, :amount => 4},
                 {:type => :indigo, :ship => 1, :amount => 4},
                 {:type => :corn, :ship => 2, :amount => 4}]

    actual0 = @state2.get_actions(0)
    actual1 = @state2.get_actions(1)
    actual2 = @state2.get_actions(2)

    assert expected0 - actual0 == [] && actual0 - expected0 == [], actual0
    assert expected1 - actual1 == [] && actual1 - expected1 == [], actual1
    assert expected2 - actual2 == [] && actual2 - expected2 == [], actual2
  end

  def test_get_actions_full_ships
    # If ships are full no players can take actions (excepting wharfs)
    (0..2).each do |x|
      assert_empty @state3.get_actions(x)
    end
  end

  def test_terminal?
    assert @state.terminal?
    assert !@state2.terminal?
    assert @state3.terminal?
  end

  def test_act
    # Player 0 loads all of two coffee onto ship 0, which is empty
    new_state2 = @state2.act({:type => :coffee, :ship => 0, :amount => 2})
    assert_equal new_state2.players[1], new_state2.current_player
    # should have 2 less coffee, 2 more VP
    assert_equal Player.new("Scott", 3, 0, 0, 1, 0, 2), new_state2.players[0]
    assert_equal Ship.new(4,2,:coffee), new_state2.ships[0]

    # Player 1 loads 5 out of 6 sugar onto ship 0, filling it
    new_state3 = new_state2.act({:type => :sugar, :ship => 1, :amount => 5})
    assert_equal new_state3.players[2], new_state3.current_player
    assert_equal Player.new("Chase", 0, 0, 1, 2, 2, 5), new_state3.players[1]
    assert_equal Ship.new(5,5,:sugar), new_state3.ships[1]

    # Player 2 loads 4 out of 8 corn onto ship 2, filling it
    new_state4 = new_state3.act({:type => :corn, :ship => 2, :amount => 4})
    assert_equal new_state4.players[0], new_state4.current_player
    assert_equal Player.new("Brian", 4, 4, 0, 0, 0, 4), new_state4.players[2]
    assert_equal Ship.new(6,6,:corn), new_state4.ships[2]

    # Player 0 has no shippable commodities
    assert_empty new_state4.get_actions
    new_state5 = new_state4.act :none

    # Player 1 loads 2 out of 2 coffee onto ship 0, filling it and ending the round
    new_state6 = new_state5.act({:type => :coffee, :ship => 0, :amount => 2})
    assert_equal new_state6.players[2], new_state6.current_player
    assert_equal Player.new("Chase", 0, 0, 1, 2, 0, 7), new_state6.players[1]
    assert_equal Ship.new(4,4,:coffee), new_state6.ships[0]

    assert new_state6.terminal?
  end
end
