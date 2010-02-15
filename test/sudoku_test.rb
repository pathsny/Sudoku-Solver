require 'test/unit'
require File.join(File.dirname(__FILE__),"../src/analyzer")
require File.join(File.dirname(__FILE__), "../src/game")
require File.join(File.dirname(__FILE__), "../src/back_tracking_solver")
require 'active_support'

class GameTest < Test::Unit::TestCase
	def setup
		@game = Game.new(test_array)
	end

	def game_value(row,col)
		@game[row_col_to_index(row, col)]
	end

	def game_neighbour_values(row, col)
		@game.neighbour_values(row_col_to_index(row, col)).sort
	end	

	def row_col_to_index(row,col)
		(row-1)*9 + col -1
	end		 	

	def test_game_reports_cell_values_correctly
		assert_equal 0, game_value(1,1)
		assert_equal 4, game_value(4,4)
	end

	def test_game_returns_values_as_an_array
		assert_equal test_array, @game.cell_values
	end	

	def test_game_allows_a_cell_to_be_set
		@game[row_col_to_index(5,5)] = 9
		question = test_array
		question[40] = 9
		assert_equal question, @game.cell_values
	end

	[:row, :col, :block].each do |attr|
		define_method "#{attr}_values" do |row, col|
			@game.send("#{attr}_indices", row_col_to_index(row, col)).collect {|i| test_array[i]}
		end 
	end	 

	def test_game_reports_row_values_correctly
		assert_equal [2, 0, 9, 5, 0, 4, 1, 7, 3], row_values(8,3)
		assert_equal [2, 0, 9, 5, 0, 4, 1, 7, 3], row_values(8,1)
		assert_equal [2, 0, 9, 5, 0, 4, 1, 7, 3], row_values(8,9)
	end		

	def test_game_reports_col_values_correctly
		assert_equal [0,0,5,0,0,0,0,7,6], col_values(3,8)
		assert_equal [0,0,5,0,0,0,0,7,6], col_values(1,8)
		assert_equal [0,0,5,0,0,0,0,7,6], col_values(9,8)
	end

	def test_game_reports_block_values_correctly
		assert_equal [0,2,3,0,5,8,7,0,0], block_values(1,1)
		assert_equal [8,0,0,9,7,6,2,0,0], block_values(1,6)
		assert_equal [0,0,7,2,0,0,0,5,0], block_values(3,9)
		assert_equal [0,0,7,5,0,4,0,0,3], block_values(9,6)
		assert_equal [4,0,2,0,0,0,7,0,8], block_values(5,5)
	end			

	def test_game_reports_neighbour_values_correctly
		assert_equal [2,3,5,6,7,9], game_neighbour_values(2,3) 
		assert_equal [1,2,5,6,7],   game_neighbour_values(5,7) 
	end
	
	def test_cells_returns_an_accessor_to_every_cell
		assert_equal test_array, @game.cells.collect{|cell| @game.cell_values[cell]}
	end
	
	def test_game_reports_a_cell_as_empty_if_it_has_a_zero
		assert @game.empty?(row_col_to_index(1,1))
		assert !@game.empty?(row_col_to_index(1,2))
	end
	
	def test_clear_resets_a_cell_value_to_zero
		@game.clear(row_col_to_index(1,2))
		assert @game.empty?(row_col_to_index(1,2))
	end
	
	def test_empty_cells_returns_all_empty_cells
		assert_equal 44, @game.empty_cells.size
		assert @game.empty_cells.all?{|cell| @game.empty?(cell)}
	end	
	
	def test_game_is_complete_when_there_are_no_empty_cells
		assert !@game.complete?
		assert Game.new(puzzles[:simple][:solution]).complete?
	end
end

class SolutionTest < Test::Unit::TestCase
	def test_solution
		analyzers = Analyzer.constants
		actual = analyzers - [(analyzers.include?(:Base) ? :Base : "Base")]
		actual.each do |analyzer|
			run_solver "Analyzer::#{analyzer}".constantize
		end
	end
	
	def run_solver(analyzer)
		total_start, moves, rollbacks = Time.now, 0, 0
		puzzles.each do |name, puzzle|
			start = Time.now
			solver = BackTrackingSolver.new(analyzer, puzzle[:question])
			assert_equal puzzle[:solution], solver.solution
			moves += solver.moves
			rollbacks += solver.rollbacks
			puts "Solved #{name} with #{solver.moves} moves and #{solver.rollbacks} rollbacks in #{Time.now - start} seconds"
		end
		puts "\n#{analyzer} ran 5 puzzles in #{Time.now - total_start} seconds with #{moves} moves and #{rollbacks} rollbacks \n\n"	
	end
end	

def test_array
  [0, 2, 3, 8, 0, 0, 0, 0, 7,
  0, 5, 8, 9, 7, 6, 2, 0, 0,
  7, 0, 0, 2, 0, 0, 0, 5, 0,
  9, 0, 0, 4, 0, 2, 0, 0, 0,
  6, 0, 7, 0, 0, 0, 4, 0, 5,
  0, 0, 0, 7, 0, 8, 0, 0, 6,
  0, 1, 0, 0, 0, 7, 0, 0, 8,
  2, 0, 9, 5, 0, 4, 1, 7, 3,
  8, 0, 0, 0, 0, 3, 5, 6, 0]
end	

def puzzles
	
	{:simple =>
	    {:question =>
	    [0, 2, 3, 8, 0, 0, 0, 0, 7,
	    0, 5, 8, 9, 7, 6, 2, 0, 0,
	    7, 0, 0, 2, 0, 0, 0, 5, 0,
	    9, 0, 0, 4, 0, 2, 0, 0, 0,
	    6, 0, 7, 0, 0, 0, 4, 0, 5,
	    0, 0, 0, 7, 0, 8, 0, 0, 6,
	    0, 1, 0, 0, 0, 7, 0, 0, 8,
	    0, 0, 9, 5, 8, 4, 1, 7, 0,
	    8, 0, 0, 0, 0, 3, 5, 6, 0],
	    :solution =>
	    [1, 2, 3, 8, 4, 5, 6, 9, 7,
	    4, 5, 8, 9, 7, 6, 2, 1, 3,
	    7, 9, 6, 2, 3, 1, 8, 5, 4,
	    9, 3, 5, 4, 6, 2, 7, 8, 1,
	    6, 8, 7, 3, 1, 9, 4, 2, 5,
	    2, 4, 1, 7, 5, 8, 9, 3, 6,
	    5, 1, 2, 6, 9, 7, 3, 4, 8,
	    3, 6, 9, 5, 8, 4, 1, 7, 2,
	    8, 7, 4, 1, 2, 3, 5, 6, 9]}, 
	:hard =>
	  {:question =>
	  [0, 4, 0, 6, 0, 3, 0, 0, 9,
	  7, 0, 1, 0, 8, 0, 0, 0, 2,
	  0, 0, 0, 0, 1, 0, 0, 0, 0,
	  0, 0, 0, 0, 0, 0, 0, 5, 8,
	  0, 0, 6, 8, 9, 5, 1, 0, 0,
	  4, 8, 0, 0, 0, 0, 0, 0, 0,
	  0, 0, 0, 0, 5, 0, 0, 0, 0,
	  1, 0, 0, 0, 2, 0, 6, 0, 3,
	  9, 0, 0, 7, 0, 1, 0, 4, 0],
	  :solution =>
	  [8, 4, 2, 6, 7, 3, 5, 1, 9,
	  7, 9, 1, 5, 8, 4, 3, 6, 2,
	  5, 6, 3, 9, 1, 2, 4, 8, 7,
	  3, 1, 9, 2, 4, 6, 7, 5, 8,
	  2, 7, 6, 8, 9, 5, 1, 3, 4,
	  4, 8, 5, 1, 3, 7, 9, 2, 6,
	  6, 2, 4, 3, 5, 9, 8, 7, 1,
	  1, 5, 7, 4, 2, 8, 6, 9, 3,
	  9, 3, 8, 7, 6, 1, 2, 4, 5]},
	:evil =>
	    {:question =>
	    [0, 0, 0, 0, 8, 7, 0, 0, 0,
	    8, 0, 1, 0, 2, 0, 0, 5, 0,
	    4, 0, 0, 0, 0, 9, 8, 0, 0,
	    0, 9, 0, 0, 0, 0, 0, 6, 0,
	    0, 0, 8, 0, 7, 0, 9, 0, 0,
	    0, 6, 0, 0, 0, 0, 0, 1, 0,
	    0, 0, 2, 7, 0, 0, 0, 0, 3,
	    0, 8, 0, 0, 3, 0, 7, 0, 2,
	    0, 0, 0, 4, 5, 0, 0, 0, 0],
	    :solution =>
	    [9, 5, 6, 1, 8, 7, 3, 2, 4,
	    8, 7, 1, 3, 2, 4, 6, 5, 9,
	    4, 2, 3, 5, 6, 9, 8, 7, 1,
	    2, 9, 5, 8, 1, 3, 4, 6, 7,
	    1, 4, 8, 2, 7, 6, 9, 3, 5,
	    3, 6, 7, 9, 4, 5, 2, 1, 8,
	    6, 1, 2, 7, 9, 8, 5, 4, 3,
	    5, 8, 4, 6, 3, 1, 7, 9, 2,
	    7, 3, 9, 4, 5, 2, 1, 8, 6]},
	:escargot =>
	    {:question =>
	    [1, 0, 0, 0, 0, 7, 0, 9, 0,
	    0, 3, 0, 0, 2, 0, 0, 0, 8,
	    0, 0, 9, 6, 0, 0, 5, 0, 0,
	    0, 0, 5, 3, 0, 0, 9, 0, 0,
	    0, 1, 0, 0, 8, 0, 0, 0, 2,
	    6, 0, 0, 0, 0, 4, 0, 0, 0,
	    3, 0, 0, 0, 0, 0, 0, 1, 0,
	    0, 4, 0, 0, 0, 0, 0, 0, 7,
	    0, 0, 7, 0, 0, 0, 3, 0, 0],
	    :solution =>
	    [1, 6, 2, 8, 5, 7, 4, 9, 3,
	    5, 3, 4, 1, 2, 9, 6, 7, 8,
	    7, 8, 9, 6, 4, 3, 5, 2, 1,
	    4, 7, 5, 3, 1, 2, 9, 8, 6,
	    9, 1, 3, 5, 8, 6, 7, 4, 2,
	    6, 2, 8, 7, 9, 4, 1, 3, 5,
	    3, 5, 6, 4, 7, 8, 2, 1, 9,
	    2, 4, 1, 9, 3, 5, 8, 6, 7,
	    8, 9, 7, 2, 6, 1, 3, 5, 4]},
	 :other_hard =>
	    {:question =>
	    [4, 0, 0, 8, 0, 0, 0, 0, 0,
	    0, 0, 0, 0, 0, 0, 9, 1, 3,
	    6, 0, 0, 5, 0, 0, 0, 0, 0,
	    1, 0, 0, 4, 0, 0, 0, 5, 8,
	    0, 9, 0, 0, 7, 0, 2, 0, 0,
	    0, 0, 0, 0, 0, 0, 0, 0, 0,
	    5, 0, 0, 0, 0, 0, 0, 6, 4,
	    0, 0, 0, 0, 0, 0, 0, 0, 0,
	    0, 3, 0, 0, 2, 0, 7, 0, 0],
	    :solution =>
	    [4, 1, 9, 8, 3, 7, 5, 2, 6,
	    7, 5, 8, 2, 4, 6, 9, 1, 3,
	    6, 2, 3, 5, 1, 9, 4, 8, 7,
	    1, 6, 7, 4, 9, 2, 3, 5, 8,
	    3, 9, 5, 6, 7, 8, 2, 4, 1,
	    2, 8, 4, 3, 5, 1, 6, 7, 9,
	    5, 7, 2, 9, 8, 3, 1, 6, 4,
	    9, 4, 1, 7, 6, 5, 8, 3, 2,
	    8, 3, 6, 1, 2, 4, 7, 9, 5]}}
end	