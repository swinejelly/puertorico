require './captain'
$visited = 0
def minimax(state, mode=:points)
  $visited += 1
  if state.terminal?
    return [state.utility(mode), []]
  else
    actions = state.get_actions
    if !actions.empty?
      results = actions.map do |a|
        r = minimax(state.act(a), mode)
        # insert the action at the beginning
        r[1] = [a] + r[1]
        r
      end
      best = results.max_by {|r| r[0][state.current_ix]}
      return best
    else
      return minimax(state.act(:none), mode)
    end
  end
end

def report(mm_result, init_state, report_visited=false)
  # Report player scores
  s = ''
  if report_visited
    s << "#{$visited} nodes were visited in this search.\n"
  end
  max_length = init_state.players.map{|p| p[:name].length}.max
  s << init_state.players.map{|p| p[:name].ljust(max_length)}.join(" ")
  s << "\n"
  s << mm_result[0].map{|n| n.to_s.ljust(max_length)}.join(" ")
  s << "\n"
  # Report the moves taken
  for move in mm_result[1]
    p_name = init_state.players[move[:player]][:name]
    s << "#{p_name} moves #{move[:amount]} #{move[:type]} to ship #{move[:ship]}.\n"
  end
  s
end