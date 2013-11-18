require_relative 'exceptions'

class DataTable
  attr_reader :rows, :headers

  def initialize (headers=[], rows=[])
    @headers = headers
    @rows = rows
    add_headers = headers unless headers.empty?
    add_rows = rows unless rows.empty?
  end

  def add_rows (rows)
    detect_array_exception_for! rows
    @rows = rows
  end

  def add_row (row=[])
    detect_headers_not_set_and_raise!
    raise DataTableException::InvalidRow, "Your row doesn't match Your headers row:#{row.count} headers:#{@headers.count}" unless @headers.count == row.count
    @rows.push row
  end

  def add_headers (headers)
    detect_array_exception_for! headers
    @headers = headers
  end

  def by_rows
    detect_headers_not_set_and_raise!
    rows = []
    @rows.each do |row|
      rows.push @headers.map { |h| row[h] }
    end
    rows
  end

  def by_cols
    detect_headers_not_set_and_raise!
    cols = []
    @headers.each do |h|
      cols.push @rows.map { |row| row[h] }
    end
    cols
  end

private

  def create_empty_row
    detect_headers_not_set_and_raise!
    Hash[@headers.zip]
  end

  catch DataTableException::InvalidRow do
    
  end

  def detect_headers_not_set_and_raise!
    raise DataTableException::HeadersNotSet, "You must set headers before you can add a row" if @headers.empty?
  end

  def detect_array_exception_for! var
    raise DataTableException::NotAnArray, "#{var} is not an array" unless var.is_a? Array
  end
  
end