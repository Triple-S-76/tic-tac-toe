
class TicTacToe

  $selections = Array.new(10, " ")
  $selections_example = Array.new(10) { |n| n+0 }

  $game_over = 'no'
  $boxes_filled = []
  $current_player = 1

  $player_1 = nil
  $player_2 = nil

  def initialize

    puts ""
    puts "Would you like to play a little game of tic tac toe?"
    puts "Y / N"

    answer = gets.chomp.downcase
    answer == ("y" || "yes" || "yeah") ? setup_game : (puts "Too bad.")

  end

  def setup_game

    puts "Player 1 name?"
    $player_1 = Player.new(gets.chomp)
    puts "Player 2 name?"
    $player_2 = Player.new(gets.chomp)

    play_game

  end
  
  class Player
    attr_accessor :box_selections
    attr_reader :name

    def initialize(name)
      @name = name
      @box_selections = []
    end
  
  end
 
  def play_game
    print_board
    until $game_over != "no"
      player_selections
      print_board
      check_if_game_over
      puts $game_over if $game_over != "no"
    end

  end

  def check_if_game_over
    $game_over = "The game has ended in a draw." if $boxes_filled.length == 9
    
    winning_combos = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
      [1, 4, 7],
      [2, 5, 8],
      [3, 6, 9],
      [1, 5, 9],
      [3, 5, 7]
    ]

    winning_combos.each do |combo|
      player_1_check = combo - $player_1.box_selections
      if player_1_check.empty? == true
        $game_over = $player_1.name + " has won the game!"
        break
      end
    end

    winning_combos.each do |combo|
      player_2_check = combo - $player_2.box_selections
      if player_2_check.empty? == true
        $game_over = $player_2.name + " has won the game!"
        break
      end
    end    
  end

  def player_selections
    box_chosen = choose_box.to_i
    $current_player == 1 ? (token = "X") : (token = "O")
    $selections[box_chosen] = token
    $current_player == 1 ? $player_1.box_selections << box_chosen : $player_2.box_selections << box_chosen
    $current_player == 1 ? $current_player = 2 : $current_player = 1
  end

  def choose_box
    choice = "0"
    puts "Please choose a number between 1 & 9 to select a box."

    loop do
      choice = gets.chomp

      if choice.to_s.size != 1 || choice.to_i < 1 || choice.to_i > 9
        puts "Please choose a valid number between 1 & 9."
        next
      elsif $boxes_filled.include?(choice.to_i) == true
        puts "Please choose a box that has not been filled."
        next
      else
        break
      end
    end
    $boxes_filled << choice.to_i
    choice
  end

  def print_board

    vertical_seperator   = " | "
    horizontal_seperator = "   --+---+--"

    row = 1
    column = 1
    box = 1

    puts ""

    while row <= 3
      line = "   "
      while column <= 3
        line += $selections[box].to_s
        line += vertical_seperator if column != 3
        column += 1
        box += 1
      end
      puts line
      puts horizontal_seperator if row != 3
      column = 1
      row += 1
    end
    
    puts ""

    row = 1
    column = 1
    box = 1

  end

end

game = TicTacToe.new
