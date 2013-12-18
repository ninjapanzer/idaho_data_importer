module ArbitraryDataImporter
  def read_student_fixtures
    files = Dir.glob(['spec/fixtures/student.txt', 'spec/fixtures/attendance.txt', 'spec/fixtures/enrollment.txt', 'spec/fixtures/program.txt']).map do |file|
      FileEncodingSupport.new(file).file_with_encoding
    end
    reader = Reader.new(files).read_all
    reader.data
  end
  module_function :read_student_fixtures
end