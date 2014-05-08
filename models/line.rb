class Line

	IGNORE_REGEX = /@([NRS]\d+)@/

	SKIP_LIST = ['HEAD','TRLR','VERS','CORP','SOUR','CONT','CONC','TITL','PUBL','REPO','AUTH']

	attr_reader :depth, :code, :msg, :pre, :post

	def initialize line, pre
		@depth = line[1].to_i
		@code = line[2]
		@msg = line[3]
		@pre = pre
		@pre.add_next(self) if @pre
	end

	def print_parent_trace
		puts "Line: #{to_s}"
	end

	def print_linear_trace n
		puts print_parent_trace
		post.print_linear_trace(n-1) if n >= 0
	end

	def add_next post
		@post = post
	end

	def add_pre pre
		@pre = pre
	end

	def to_s
		puts "#{@depth} | #{@code} | #{@msg}"
	end

	def prune
		if (code =~ IGNORE_REGEX || SKIP_LIST.include?(code))
			#puts "Pruning line: #{self.to_s}"
			# Prune linearly from this line to the next line with same or smaller depth
			to_remove = []
			next_root = @post
			while next_root && (next_root.depth > @depth)
				#puts "Pruning line: #{next_root.to_s}"
				to_remove << next_root
				next_root = next_root.post
			end

			puts "Connecting #{@pre} to #{next_root}"
			@pre.add_next next_root if @pre
			next_root.add_pre @pre if next_root
			return to_remove
		else
			return false
		end
	end

end