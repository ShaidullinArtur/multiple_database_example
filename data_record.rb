class DataRecord
  DATA_SOURCE_METHODS = %i(select filter group_by).freeze

  attr_accessor :results

  def initialize(data_source)
    @data_source = data_source
    @results = []
  end

  def pluck(column)
    results.map{ |result| result[column.to_s] }
  end

  def joined_column(column)
    pluck(column).join(", ")
  end

  def load
    @results = @data_source.load.to_a
  end

  private

  def method_missing(method_name, *args)
    data_source_method(method_name, args)
  end

  def data_source_method(method_name, *args)
    self.tap do
      @data_source.public_send(method_name, args)
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    DATA_SOURCE_METHODS.include?(method_name) || super
  end
end
