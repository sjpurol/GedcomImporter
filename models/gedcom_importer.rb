class GendomImporter

	ID_REGEX = /@(.{2})@/
	INDI_REGEX = /@(I\d+)@/
	IGNORE_REGEX = /@([NRS]\d+)@/
	TWO_PART_LINE_REGEX = /^(\d+)\s(\b\S+\b)$/
	THREE_PART_LINE_REGEX = /^(\d+)\s(\b\S+\b)\s(\S.*)$/
	ID_LINE_REGEX = /^(\d+)\s(@\S+@)\s(.*)$/
	LINE_REGEX = /^(\d+)\s(@.+@|\b\S+\b)(.*)$/
	NAME_REGEX = /(\w+\b)\s(\w*\b)?\s?\/(\b\w+\b)\//

	SKIP_LIST = ['HEAD','TRLR','VERS','CORP','SOUR','CONT','CONC','TITL','PUBL','REPO','AUTH']


	CODES = {	'DEST'		=>	[],
						'DATE'		=>	['date'],
						'FILE'		=>	[],
						'GEDC'		=>	[],
						'CHAR'		=>	[],
						'NAME'		=>	['text'],
						'SEX'			=>	['text'],
						'FAMS'		=>	[ID_REGEX],
						'HUSB'		=>	[ID_REGEX],
						'WIFE'		=>	[ID_REGEX],
						'CHIL'		=>	[ID_REGEX],
						'CHAN'		=>	[ID_REGEX],
						'MARR'		=>	['status'],
						ID_REGEX	=>	['id']}

	attr_reader :file, :lines, :trees, :persons

	def initialize path
		puts "Initializing Importer"
		puts "File to import: #{path}"
		@file = Rails.root.join(path).open
		raise "Error opening file" unless @file
	end

	def perform
		tokenize
		organize
	end

	def tokenize
		@lines = []
		@file.each { |line|	line.match(LINE_REGEX) { |matches| @lines << Line.new(matches,@lines.last) } }
		nil
	end

	def prune
		@lines.each(&:prune)
	end

	def organize
		@trees = DataTrees.new(@lines)
		@trees.generate
		puts "#{@lines.count} lines became #{@trees.roots.count} items and #{@trees.roots.count{|item| item.code =~ INDI_REGEX }} people."
		@persons = []
		@trees.roots.each do |item|
			if item.code =~ INDI_REGEX
				@persons << item.to_person		
			end
		end
		nil
	end

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

	end
end