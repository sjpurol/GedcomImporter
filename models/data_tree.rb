class DataTree

	attr_reader :root, :lines

	def initialize lines
		@root = Node.new(lines.shift)
		lines.each do |line|
			@root.add_child(line)
		end
	end
end