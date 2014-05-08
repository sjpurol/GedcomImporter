class Node
	attr_reader :line, :children, :parent

	def initialize line, parent = nil
		@line = line
		@children = []
		@parent = parent
	end

	def add_child child
		case depth - child.depth + 1
		when 0
			@last_child = Node.new(child,self)
			@children << @last_child
		when 1
			last_child.add_child(child)
		end
	end

	def depth
		@line.depth
	end

	def code
		@line.code
	end

	def msg
		@line.msg
	end

	def to_attributes
		out = {}
		case code
		when "NAME"
			out[:first_name], out[:middle_name], out[:last_name] = get_name(msg)
		when "SEX"
			out[:sex] = msg
		when "BIRT"
			puts @children.inspect
			out[:birth_date] = @children.partition { |child| child.code == "DATE" }[0].msg
		when "DEAT"
			out[:death_date] = @children.select { |data| data.code == "DATE" }[0].msg
		when "FAMS" #Spouse
			out[:relationship][msg][:spouse] << @parent.code
		when "FAMC" #Child
			out[:relationship][msg][:child] << @parent.code
		end
		out
	end

	def to_person
		attributes = {:private_id => line.code}
		@children.each do |data|
			if data.children
				attributes.merge!(data.to_attributes)
			else
				attributes[data.code] = data.msg
			end
		end
		relationships = attributes.delete(:relationship)
		relationships.each { |k,v| puts v.inspect }
		person = Person.find_by_private_id(line.code)
		person |= Person.create(attributes)
	end

	def print_trace
		parent.print_trace if parent
		line.print_linear_trace 2
	end

	def print
		line.print_parent_trace
	end

	private

		def get_date_symbol code
			return :birth_date if code == "BIRT"
			return :death_date if code == "DEAT"
		end

		def get_date

			print_trace
			puts @children.inspect
			dates = @children.select { |data| data.code == "DATE" }
			puts dates.inspect
			date = dates.first
			puts date.inspect
			date.msg
		end

		def get_name msg
			parts = msg.match(NAME_REGEX)
			raise "Name not found." if !parts
			return parts[1], parts[2], parts[3]
		end
end