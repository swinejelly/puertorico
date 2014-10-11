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

  def test_how_many
    chase = @players2[1]
    assert_equal (chase.how_many :sugar), 6
    assert_equal (chase.how_many :vp), 0
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
end
