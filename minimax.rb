require './captain'

def minimax(state)
  if state.terminal?
    return [state.utility, []]
  else
    actions = state.get_actions
    if !actions.empty?
      results = actions.map do |a|
        r = minimax(state.act a)
        # insert the action at the beginning
        r[1] = [a] + r[1]
        r
      end
      best = results.max_by {|r| r[0][state.current_ix]}
      return best
    else
      return minimax(state.act :none)
    end
  end
end
