class Game
	def initialize(cell_values)
		@cell_values = cell_values
		@neighbour_indices = []
		@cells = (0..80).to_a
		@empty_cells = @cells.select { |cell|  empty? cell}
	end

	attr_reader :cell_values, :empty_cells, :cells	

	def [](i)
		cell_values[i]
	end

	def []=(i,value)
		@empty_cells.insert(0,i) if value == 0 and cell_values[i] != 0
		@empty_cells.delete i if value != 0 and cell_values[i] == 0
		cell_values[i] = value
	end

	def cell_pos(i)
		@empty_cells.find_with_index(-1){|cell, index| return index if cell > i}
	end	

	def row_indices(i)
		row_number = (i/9)*9
		(row_number..row_number+8).to_a
	end

	def col_indices(i)
		col_number = i%9
		(0..8).collect{|x| x*9+col_number}
	end

	def block_indices(i)
		block_row = ((i/9)/3)*3
		block_col = ((i%9)/3)*3
		(0..8).collect {|x| (block_row + x/3)*9 + (block_col + x%3)}
	end			

	def neighbour_indices(i)
		@neighbour_indices[i] ||= (row_indices(i) + col_indices(i) + block_indices(i) - [i])
	end	

	def neighbour_values(i)
		neighbour_indices(i).collect{|index| cell_values[index] unless empty? index}.compact.uniq
	end

	def empty?(i)
		self[i] == 0
	end

	def clear(i)
		self[i] = 0
	end

	def complete?
		empty_cells.empty?
	end			
end