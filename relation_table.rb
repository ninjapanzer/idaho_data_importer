#require 'axiom'

class RelationTable
  def initialize dtable
    @table = dtable
    puts @table.inspect
    determine_header_types
  end

  def determine_header_types
    first_row = @table.rows.first
    first_row.each do |r|
      puts r.inspect
    end
    headers = @table.headers
  end
end