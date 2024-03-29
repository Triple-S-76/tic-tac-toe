require 'pry-byebug'

class TicTacToe
  attr_accessor :player1, :player2, :player1_boxes, :player2_boxes, :board, :current_player, :random_questions, :game_over

  def initialize
    @board = create_board
    @player1_boxes = []
    @player2_boxes = []
    @game_over = false
    set_random_questions
  end

  def start_game
    answer = would_you_like_to_play
    return unless answer == 'play game'

    set_player_names
    game_loop
  end

  def game_loop
    loop do
      system('clear')
      set_current_player
      print_board(board)
      current_move = ask_player
      update_board(current_move)
      update_player_boxes(current_move)

      check_for_winner
      break if @game_over

      draw_game if @player1_boxes.length + @player2_boxes.length == 9
      break if @game_over
    end
  end

  private

  def times_puts(num)
    num.times { puts }
  end

  def would_you_like_to_play
    times_puts(3)
    puts 'Would you like to play Tic Tac Toe?'
    puts 'Yes or No'
    answer = gets.chomp.downcase

    play_game = %w(yes y)
    if play_game.include?(answer)
      'play game'
    else
      puts 'OK then, good-bye'
      'end game'
    end
  end

  def set_player_names
    puts
    puts 'Enter Player 1 Name'
    @player1 = gets.chomp
    puts
    puts 'Enter Player 2 Name'
    @player2 = gets.chomp
  end

  def set_current_player
    @current_player = @current_player == player1 ? player2 : player1
  end

  def update_player_boxes(current_move)
    if current_player == player1
      @player1_boxes << current_move
    else
      @player2_boxes << current_move
    end
  end

  def update_board(current_move)
    current_symbol = @current_player == @player1 ? 'x' : 'o'

    case current_move
    when 1
      @board[2][0] = current_symbol
    when 2
      @board[2][1] = current_symbol
    when 3
      @board[2][2] = current_symbol
    when 4
      @board[1][0] = current_symbol
    when 5
      @board[1][1] = current_symbol
    when 6
      @board[1][2] = current_symbol
    when 7
      @board[0][0] = current_symbol
    when 8
      @board[0][1] = current_symbol
    when 9
      @board[0][2] = current_symbol
    end
  end

  def ask_player
    valid = false
    until valid == true
      current_question = random_questions.sample
      puts "#{current_question[0]} #{current_player}"
      current_move = gets.chomp.to_i
      valid = check_if_valid(current_move)
    end
    current_move
  end

  def check_if_valid(current_move)
    if @board.flatten.include?(current_move)
      true
    else
      puts
      puts 'Please enter a valid selection'
      puts
    end
  end

  def set_random_questions
    random_question_array = [
      ['Your move'],
      ['Go ahead'],
      ["It's time for your move"],
      ["You're up"],
      ['Take your turn'],
      ["The ball's in your court"],
      ["Show us what you've got"],
      ["You're on"],
      ["It's your go"],
      ['Play your move'],
      ['The stage is yours'],
      ['Step up and take your turn'],
      ["It's time to make a move"],
      ['The spotlight is on you'],
      ['Your moment has come'],
      ["You're in control"],
      ['The game is waiting for you'],
      ['Seize the opportunity'],
      ["Don't keep us waiting"],
      ['The game board is calling your name'],
      ["It's your chance to shine"],
      ['Show off your skills'],
      ['Time to take the reins'],
      ['The turn is yours to take'],
      ['The game awaits your next move']
    ]
    @random_questions = []
    random_question_array.each { |question| @random_questions << question }
  end

  def create_board
    board = []
    number = 1
    3.times do
      row = []
      3.times do
        row << number
        number += 1
      end
      board << row
    end
    board.reverse
  end

  def print_board(board)
    times_puts(3)
    array_to_print_board = []
    fill_board(board, array_to_print_board)
    puts array_to_print_board
    puts '           |       |'
    times_puts(3)
  end

  def fill_board(board, array_to_print_board)
    row_count = 0
    row_break = ['           |       |', '   --------+-------+--------']
    3.times do
      fill_row(board[row_count], array_to_print_board)
      row_count += 1
      if row_count == 1 || row_count == 2
        array_to_print_board << row_break
      end
    end
  end

  def fill_row(row, array_to_print_board)
    line_count = 0
    6.times do
      single_line = fill_single_line(row, line_count)
      array_to_print_board << single_line
      line_count += 1
    end
  end

  def fill_single_line(row, line_count)
    single_line = '     '
    current_box = 0
    3.times do
      single_line += x_or_o(row[current_box])[line_count]
      single_line += ' | ' unless current_box == 2
      current_box += 1
    end
    single_line
  end

  def x_or_o(symbol)
    if symbol == 'x'
      ['     ',
       '\   /',
       ' \ / ',
       '  X  ',
       ' / \ ',
       '/   \\',
       '     ']
    elsif symbol == 'o'
      [' ___ ',
       '|   |',
       '|   |',
       '|   |',
       '|   |',
       '|___|',
       '     ']
    else
      ['     ',
       '     ',
       '     ',
       "  #{symbol}  ",
       '     ',
       '     ',
       '     ']
    end
  end

  def check_for_winner
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
    current_player_boxes = @current_player == @player1 ? @player1_boxes : @player2_boxes
    winner = false
    winning_combos.each do |combos|
      winner = combos.all? { |numbers| current_player_boxes.include?(numbers) }
      we_have_a_winner if winner == true
    end
  end

  def draw_game
    system('clear')
    print_board(board)
    puts 'The game has ended in a draw. Too bad!'
    times_puts(3)
    @game_over = true
  end

  def we_have_a_winner
    system('clear')
    print_board(board)
    puts "We have a winner! Congrats #{current_player}"
    times_puts(3)
    @game_over = true
  end
end

if $PROGRAM_NAME == __FILE__
  my_game = TicTacToe.new
  my_game.start_game
end
