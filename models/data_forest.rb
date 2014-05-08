class DataForest

  def initialize groups
    @roots = []
    groups.each do |group|
      @roots << DataTree.new(group)
    end
  end
end