require_relative "memory"
require_relative "data_record"

class Search
  def initialize
    @data = { records: {}, results: [] }
  end

  def select(klass, columns, options = {})
    self.tap do
      data_record = find_or_initialize_data_record(klass, options)
      data_record.select(columns)
      yield data_record, @data[:records] if block_given?
      @data[:results] = data_record.load
    end
  end

  def sort(data_key, column, direction = :asc)
    self.tap do
      @data[:results] = find_or_initialize_data_record(data_key).results.tap do |results|
        sorted_results = results.sort_by! { |s| s[column.to_s] }
        direction == :asc ? sorted_results : sorted_results.reverse!
      end
    end
  end

  def merge(first_key, second_key, columns = nil)
    self.tap do
      first_record = @data[:records][first_key]
      second_record = @data[:records][second_key]

      new_record_key = "#{first_key}_#{second_key}"
      @data[:results] = find_or_initialize_data_record(Memory, alias: new_record_key).results.tap do |results|
        first_record.results.each do |first_record_item|
          second_record.results.each do |second_record_item|
            next unless block_given? ? yield(first_record_item, second_record_item) : true

            new_result = first_record_item.merge(second_record_item).tap do |hash|
              hash.select! { |key| columns.include?(key.to_sym) } if columns
            end
            results << new_result
          end
        end
      end
    end
  end

  def results
    @data[:results]
  end

  private

  def find_or_initialize_data_record(klass, options = {})
    key = options[:alias] || klass.to_s
    @data[:records][key.to_sym] ||= DataRecord.new(klass.new)
  end
end
