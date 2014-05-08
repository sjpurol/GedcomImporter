include 'gedcom_parser'

class GedcomImporter

	ID_REGEX = /@(.{2})@/
	INDI_REGEX = /@(I\d+)@/
	IGNORE_REGEX = /@([NRS]\d+)@/
	TWO_PART_LINE_REGEX = /^(\d+)\s(\b\S+\b)$/
	THREE_PART_LINE_REGEX = /^(\d+)\s(\b\S+\b)\s(\S.*)$/
	ID_LINE_REGEX = /^(\d+)\s(@\S+@)\s(.*)$/
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
		lines = GedcomParser.new(@file).parse
		organize
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
end