require './captain'
require './minimax'


players1 = [Player.new("Scott", 3, 0, 0, 1, 2),
             Player.new("Chase", 0, 0, 6, 2, 2),
             Player.new("Brian", 8, 4, 0, 0, 0)]
ships1 = [Ship.new(4), Ship.new(5), Ship.new(6, 2, :corn)]
state1 = State.new(players1, ships1)

puts "Result 1: Three players, moderate goods, no special buildings."

result1_points = minimax(state1, :points)
puts "Points:"
print(report(result1_points, state1,true))
$visited = 0
result1_delta = minimax(state1, :delta)
puts "Delta:"
print(report(result1_delta, state1,true))

players2 = [Player.new("Scott",   0, 3, 1, 0, 2),
            Player.new("Travis",  2, 0, 0, 3, 0),
            Player.new("Moffitt", 5, 0, 0, 0, 4),
            Player.new("Swan",    2, 3, 2, 1, 1),
            Player.new("Joshua",  0, 2, 4, 0, 0)]
ships2 = [Ship.new(6), Ship.new(7), Ship.new(8)]
state2 = State.new(players2, ships2)

puts "\nResult 2: Five players, heavy goods, no special buildings."
puts "Points:"
$visited = 0
result2_points = minimax(state2, :points)
puts(report(result2_points, state2,true))
puts "Delta:"
$visited = 0
result2_delta = minimax(state2, :delta)
puts(report(result2_delta, state2,true))


players3 = [Player.new("Scott",   0, 3, 1, 0, 2, 0, 1, 1),
            Player.new("Travis",  2, 3, 0, 3, 0, 0, 0, 0),
            Player.new("Moffitt", 5, 0, 0, 0, 4, 0, 0, 1),
            Player.new("Swan",    2, 3, 2, 1, 1, 0, 0, 0),
            Player.new("Joshua",  0, 2, 4, 0, 0, 0, 1, 0)]
ships3 = [Ship.new(6), Ship.new(7), Ship.new(8)]
state3 = State.new(players3, ships3)

puts "\nResult 3: Five players, heavy goods, all special buildings."
puts "Points:"
$visited = 0
result3_points = minimax(state3, :points)
puts(report(result3_points, state3,true))
puts "Delta:"
$visited = 0
result3_delta = minimax(state3, :delta)
puts(report(result3_delta, state3,true))