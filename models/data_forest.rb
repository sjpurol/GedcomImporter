class DataForest

  def initialize groups
    @roots = []
    groups.each do |group|
      @roots << DataTree.new(group)
    end
  end

  def select &block
    if block_given?
      @roots.select &block
    else
      @roots.select
    end
  end
end