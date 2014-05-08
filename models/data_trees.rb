class DataTrees

	attr_reader :roots, :lines

	def initialize lines
		@lines = lines
	end

	def generate
		@roots = []
		parent = nil
		@lines.each do |line|
			if line.depth == 0
				parent = Node.new(line)
				@roots << parent
			else
				parent.add_child(line)
			end
		end

		prune
	end

	def prune
		# Prune roots
		@roots.reject! { |root|
			puts "Pruning root: #{root.inspect}" if SKIP_LIST.include?(root.code)
			SKIP_LIST.include?(root.code)
		}
		@roots.reject! { |root|
			puts "Pruning root: #{root.inspect}" if root.code =~ IGNORE_REGEX
			root.code =~ IGNORE_REGEX
	  }

		# Prune linear
		@roots[0].line.prune
	end
end