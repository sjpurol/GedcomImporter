class DataForestGenerator
  SKIP_LIST = ['HEAD','TRLR','VERS',
               'CORP','SOUR','CONT',
               'CONC','TITL','PUBL',
               'REPO','AUTH']
  IGNORE_REGEX = /@([NRS]\d+)@/
  INDI_REGEX = /@(I\d+)@/

  def initialize lines
    @forest = DataForest.new(trim segment lines)
  end

  private
    # Takes an array of Lines and splits it into
    # an array of arrays of Lines, each sub-array
    # starting with a Line with depth = 0.
    def segment lines
      groups = []
      lines.each do |line|
        groups << [] if line.depth == 0
        groups.last << line
      end
      groups
    end

    # Selects only the groups that represent a person
    def trim groups
      groups.select do |group|
        group.first.code.match(INDI_REGEX)
      end
    end
end