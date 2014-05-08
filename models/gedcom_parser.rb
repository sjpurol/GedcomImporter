include 'line'

class GedcomParser
	
	LINE_REGEX = /^(\d+)\s(@.+@|\b\S+\b)(.*)$/

	def initialize file
		@file = file
	end

	def parse
		lines = []
		@file.each do |line|
			lines << Line.new(line.match(LINE_REGEX),@lines.last)
		end
		@file.close
		lines
	end

end