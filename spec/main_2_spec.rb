require 'stringio'
require_relative '../main_2'

describe TicTacToe do
  context 'makes sure everthing is set up in initialize' do
    it 'checks @board' do
      expect(subject.board).to eq([[7, 8, 9], [4, 5, 6], [1, 2, 3]])
    end

    it 'checks @player1_boxes' do
      expect(subject.player1_boxes).to eq([])
    end

    it 'checks @player2_boxes' do
      expect(subject.player2_boxes).to eq([])
    end

    it 'checks @random_questions' do
      random_questions_array = [['Your move'], ['Go ahead'], ["It's time for your move"]]
      expect(subject.random_questions).to include(*random_questions_array)
    end
  end

  context 'run #start_game, would you like to play, say no' do
    it 'return good-bye message' do
      expect(subject).to receive(:puts).exactly(3).times
      expect(subject).to receive(:puts).with('Would you like to play Tic Tac Toe?')
      expect(subject).to receive(:puts).with('Yes or No')
      expect(subject).to receive(:gets).and_return('no')
      expect(subject).to receive(:puts).with('OK then, good-bye')
      subject.start_game
    end
  end

  context 'run #start game, checks #set_player_names' do
    it 'checks that the names are set correctly' do
      allow(subject).to receive(:would_you_like_to_play).and_return('play game')
      allow(subject).to receive(:game_loop)
      expect(subject).to receive(:puts)
      expect(subject).to receive(:puts).with('Enter Player 1 Name')
      expect(subject).to receive(:gets).and_return('John')
      expect(subject).to receive(:puts)
      expect(subject).to receive(:puts).with('Enter Player 2 Name')
      expect(subject).to receive(:gets).and_return('Doe')
      subject.start_game
      expect(subject.player1).to eq('John')
      expect(subject.player2).to eq('Doe')
    end
  end

  context '#game_loop' do
    before(:each) do
      subject.player1 = 'John'
      subject.player2 = 'Doe'
    end

    context 'checks #set_current_player' do
      it 'toggles @current_player and updates @player1_boxes inside game_loop' do
        allow(subject).to receive(:system)
        allow(subject).to receive(:puts)
        allow(subject).to receive(:print_board)
        allow(subject).to receive(:ask_player)
        allow(subject).to receive(:update_board)
        allow(subject).to receive(:update_player_boxes)

        iterations_limit = 100
        iterations = 0
        allow(subject).to receive(:check_for_winner) do
          iterations += 1

          if iterations.even?
            expect(subject.current_player).to eq(subject.player2)
          else
            expect(subject.current_player).to eq(subject.player1)
          end

          subject.game_over = true if iterations == iterations_limit
        end

        subject.game_loop
        expect(subject.game_over).to be true
      end
    end

    context 'checks #print_board' do
      before(:each) do
        allow(subject).to receive(:system)
        allow(subject).to receive(:set_current_player)
        allow(subject).to receive(:ask_player)
        allow(subject).to receive(:update_board)
        allow(subject).to receive(:update_player_boxes)
        subject.player1_boxes = [5, 1, 6, 8, 7]
        subject.player2_boxes = [3, 9, 4, 2]
        subject.board = [%w[x x o], %w[o x x], %w[x o o]]
      end

      it 'checks the output of #print_board with a full board' do

        # set up capture of stdout
        original_stdout = $stdout
        $stdout = StringIO.new

        subject.game_loop

        # reset stdout
        captured_output = $stdout.string
        $stdout = original_stdout

        captured_split = captured_output.split("\n")
        lines_to_check = [6, 10, 14, 18, 22, 35, 39, 43, 47, 51, 58]
        lines_to_check_array = []

        captured_split.each_with_index do |line, index|
          lines_to_check_array << line if lines_to_check.include?(index)
        end

        lines_to_match_array = [
          '       X   |   X   | |   |',
          '   --------+-------+--------',
          '     |   | |   X   |   X  ',
          '   --------+-------+--------',
          '       X   | |   | | |   |',
          '       X   |   X   | |   |',
          '   --------+-------+--------',
          '     |   | |   X   |   X  ',
          '   --------+-------+--------',
          '       X   | |   | | |   |',
          'The game has ended in a draw. Too bad!'
        ]
        expect(lines_to_match_array).to eq(lines_to_check_array)
      end
    end

    context 'checks #ask_player & #check_if_valid' do
      before(:each) do
        allow(subject).to receive(:system)
        allow(subject).to receive(:set_current_player)
        allow(subject).to receive(:print_board)
        allow(subject).to receive(:update_board)
        allow(subject).to receive(:update_player_boxes)
        allow(subject).to receive(:check_for_winner)
        subject.current_player = subject.player1
        subject.game_over = true
      end

      it 'gives 5 invalid moves and then 1 valid move' do
        allow(subject).to receive(:gets).and_return('r', 'f', 'g', 'h', 'j', '5')

        # set up capture of stdout
        original_stdout = $stdout
        $stdout = StringIO.new

        subject.game_loop

        # reset stdout
        captured_output = $stdout.string
        $stdout = original_stdout

        captured_split = captured_output.split("\n")
        captured_questions = []
        captured_error = []
        #sort captured output
        name_length = subject.current_player.length + 1
        captured_split.each do |line|
          unless line.empty?
            if line.end_with?(subject.current_player)
              captured_questions << line.slice(0, line.length - name_length)
            else
              captured_error << line
            end
          end
        end
        #make sure captured info is correct
        captured_questions.each do |line|
          question_with_removed_name = []
          question_with_removed_name << line
          expect(subject.random_questions).to include(question_with_removed_name)
        end
        expect(captured_error).to all(eq('Please enter a valid selection'))
      end
    end

    context 'checks #update_board' do
      before(:each) do
        allow(subject).to receive(:system)
        allow(subject).to receive(:print_board)
        allow(subject).to receive(:ask_player).and_return(7, 8, 9, 4, 5, 6, 1, 2, 3)
        allow(subject).to receive(:update_player_boxes)
        allow(subject).to receive(:check_for_winner)
        allow(subject).to receive(:set_current_player) do
          subject.current_player = subject.current_player == subject.player1 ? subject.player2 : subject.player1
        end
      end

      it 'checks the board after the box is full' do
        iterations_limit = 9
        iterations = 0

        allow(subject).to receive(:system) do
          iterations += 1
          subject.game_over = true if iterations == iterations_limit
        end

        expect(subject.board).to eq([[7, 8, 9], [4, 5, 6], [1, 2, 3]])
        subject.game_loop
        expect(subject.board).to eq([%w(x o x), %w(o x o), %w(x o x)])
      end

      it 'checks the board mid game' do
        iterations_limit = 5
        iterations = 0

        allow(subject).to receive(:system) do
          iterations += 1
          subject.game_over = true if iterations == iterations_limit
        end

        expect(subject.board).to eq([[7, 8, 9], [4, 5, 6], [1, 2, 3]])
        subject.game_loop
        expect(subject.board).to eq([%w(x o x), ['o', 'x', 6], [1, 2, 3]])
      end
    end

    context 'checks #update_player_boxes and ending the game with draw_game' do
      before(:each) do
        allow(subject).to receive(:system)
        allow(subject).to receive(:puts)
        allow(subject).to receive(:set_current_player) do
          subject.current_player = subject.current_player == subject.player1 ? subject.player2 : subject.player1
        end
        allow(subject).to receive(:print_board)
        allow(subject).to receive(:ask_player).and_return(7, 8, 9, 4, 5, 6, 1, 2, 3)
        allow(subject).to receive(:update_board)
        allow(subject).to receive(:check_for_winner)
      end
      
      it 'runs the loop to fill all boxes with #update_player_boxes and ends with draw_game' do
        expect(subject.player1_boxes).to be_empty
        expect(subject.player2_boxes).to be_empty
        subject.game_loop
        expect(subject.player1_boxes).to eq([7, 9, 5, 1, 3])
        expect(subject.player2_boxes).to eq([8, 4, 6, 2])
        expect(subject.game_over).to be true
      end
    end

    context 'checks #checks_for_winner' do
      before(:each) do
        allow(subject).to receive(:system)
        allow(subject).to receive(:set_current_player)
        allow(subject).to receive(:print_board).once
        allow(subject).to receive(:ask_player)
        allow(subject).to receive(:update_board)
        allow(subject).to receive(:update_player_boxes)
        subject.current_player = subject.player1
        subject.game_over = true
      end

      it 'checks #check_for_winner with an empty board' do
        expect(subject).not_to receive(:we_have_a_winner)
        subject.game_loop
      end

      it 'checks #check_for_winner with a non winning board' do
        subject.player1_boxes = [1, 5, 3, 8]
        expect(subject).not_to receive(:we_have_a_winner)
        subject.game_loop
      end

      it 'checks #check_for_winner with a winning board' do
        subject.player1_boxes = [3, 2, 1]
        expect(subject).to receive(:we_have_a_winner)
        subject.game_loop
      end

      it 'checks #check_for_winner with a winning board' do
        subject.player1_boxes = [4, 5, 6]
        expect(subject).to receive(:we_have_a_winner)
        subject.game_loop
      end

      it 'checks #check_for_winner with a winning board' do
        subject.player1_boxes = [8, 9, 7]
        expect(subject).to receive(:we_have_a_winner)
        subject.game_loop
      end

      it 'checks #check_for_winner with a winning board' do
        subject.player1_boxes = [7, 4, 1]
        expect(subject).to receive(:we_have_a_winner)
        subject.game_loop
      end

      it 'checks #check_for_winner with a winning board' do
        subject.player1_boxes = [5, 2, 8]
        expect(subject).to receive(:we_have_a_winner)
        subject.game_loop
      end

      it 'checks #check_for_winner with a winning board' do
        subject.player1_boxes = [3, 6, 9]
        expect(subject).to receive(:we_have_a_winner)
        subject.game_loop
      end

      it 'checks #check_for_winner with a winning board' do
        subject.player1_boxes = [9, 5, 1]
        expect(subject).to receive(:we_have_a_winner)
        subject.game_loop
      end

      it 'checks #check_for_winner with a winning board' do
        subject.player1_boxes = [3, 7, 5]
        expect(subject).to receive(:we_have_a_winner)
        subject.game_loop
      end

      it 'checks the output of #we_have_a_winner' do
        allow(subject).to receive(:print_board)
        subject.player1_boxes = [1, 2, 3]

        # set up capture of stdout
        original_stdout = $stdout
        $stdout = StringIO.new

        subject.game_loop

        # reset stdout
        captured_output = $stdout.string
        $stdout = original_stdout

        expect(captured_output).to include('We have a winner! Congrats ')
      end
    end
  end
end
