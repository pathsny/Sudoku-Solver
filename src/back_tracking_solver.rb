class BackTrackingSolver
  def initialize(analyzer_klass, question)
      @game = Game.new(question)
      @analyzer_klass = analyzer_klass
      @moves = 0
      @rollbacks = 0
  end

  attr_reader :moves, :rollbacks

	def solution
		raise "could not solve" unless solve
		@game.cell_values
	end
	
	def solve(analyzer=nil)
		return true if @game.complete?
		analyzer = @analyzer_klass.new(@game, analyzer)
		analyzer.each do |cell, value|
			make_move cell, value
			return true if solve(analyzer)
			rollback cell
		end
		false
	end
	
	def make_move(cell, value)
		@game[cell] = value
		@moves += 1
	end
	
	def rollback(cell)
		@game.clear(cell)
		@rollbacks += 1
	end			
end	

