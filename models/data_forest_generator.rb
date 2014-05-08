class DataForestGenerator
  SKIP_LIST = ['HEAD','TRLR','VERS',
               'CORP','SOUR','CONT',
               'CONC','TITL','PUBL',
               'REPO','AUTH']
  IGNORE_REGEX = /@([NRS]\d+)@/

  def initialize lines

    @forest = DataForest.new(trim segment lines)
  end

  def segment lines
    groups = []
    lines.each do |line|
      groups << [] if line.depth == 0
      groups.last << line
    end
    groups
  end

  def trim groups
    groups.map do |group|
      code = group.first.code
      return nil if code =~ IGNORE_REGEX || SKIP_LIST.include?(code)
      return group
    end.delete_if(&:nil?)
  end
end