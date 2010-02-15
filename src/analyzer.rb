class Array
	def tail
		self[1..length]
	end	
end	

module Analyzer
	class Base
		@@numbers = (1..9).to_a

		def possible_values(game, cell)
			@@numbers - game.neighbour_values(cell)
		end	

		def each
			@possible_values.each do |value|
				yield @cell, value
			end 
		end
	end

	class Simple < Base
		def initialize(game, analyzer=nil)
			@cell = game.empty_cells.first
			@possible_values = possible_values(game, @cell)
		end
	end

	class ConstraintsChecking < Base
		def initialize(game, analyzer=nil)
			# possible_values_list = game.empty_cells.collect{|cell| possible_values(game, cell)}
			@possible_values = game.empty_cells.tail.any?{|cell| possible_values(game, cell).empty?} ? [] : possible_values(game, game.empty_cells.first)
			@cell = game.empty_cells.first
		end
	end

	class LeastChoicesFirst < Base
		def initialize(game, analyzer=nil)
			cells_with_values = game.empty_cells.sort.collect{|cell| [cell, possible_values(game, cell)]}
			@cell, @possible_values = cells_with_values.min{|pair_1, pair_2| pair_1[1].length <=> pair_2[1].length}
		end
	end

	class ShortCircuitLeast < Base
		def initialize(game, analyzer=nil)
			@cell, @possible_values = least(game)
		end

		def least(game)
			min_cell, min_value = nil, @@numbers
			game.empty_cells.each do |cell|
				values = possible_values(game, cell)
				return cell, values if [0,1].include? values.length 
				min_cell, min_value = cell, values if values.length < min_value.length 
			end
			[min_cell, min_value]
		end	
	end

	class StorageBasedLeast < Base
		attr_reader :cells_with_values, :cell, :value

		def initialize(game, analyzer=nil)
			@cells_with_values = find_cells_with_values(game, analyzer)
			@cell, @possible_values = cells_with_values.min{|pair_1, pair_2| pair_1[1].length <=> pair_2[1].length}
		end

		def each
			@possible_values.each do |value|
				@value = value
				yield @cell, value
			end 
		end

		def find_cells_with_values(game, analyzer)
			return game.empty_cells.collect{|cell| [cell, possible_values(game, cell)]} unless analyzer
			cells_with_values = analyzer.cells_with_values.reject{|pair| pair[0] == analyzer.cell}
			neighbours = game.neighbour_indices(analyzer.cell)
			cells_with_values.collect do |pair|
				values = neighbours.include?(pair[0]) ? pair[1] - [analyzer.value] : pair[1] 
				[pair[0],values]	
			end 
		end	
	end

	class StorageBasedShortCircuit < Base
		attr_reader :cells_with_values, :cell, :value

		def initialize(game, analyzer=nil)
			@cells_with_values = find_cells_with_values(game, analyzer)
			@cell, @possible_values = least
		end

		def each
			@possible_values.each do |value|
				@value = value
				yield @cell, value
			end 
		end

		def least
			min_cell, min_value = nil, @@numbers
			@cells_with_values.each do |cell, values|
				return cell, values if values.length == 1 
				min_cell, min_value = cell, values if values.length < min_value.length 
			end
			[min_cell, min_value]
		end

		def find_cells_with_values(game, analyzer)
			return game.empty_cells.collect{|cell| [cell, possible_values(game, cell)]} unless analyzer
			cells_with_values = analyzer.cells_with_values.reject{|pair| pair[0] == analyzer.cell}
			neighbours = game.neighbour_indices(analyzer.cell)
			cells_with_values.collect do |pair|
				values = neighbours.include?(pair[0]) ? pair[1] - [analyzer.value] : pair[1]
				return [[pair[0],[]]] if values.empty? 
				[pair[0],values]	
			end 
		end	
	end
end	