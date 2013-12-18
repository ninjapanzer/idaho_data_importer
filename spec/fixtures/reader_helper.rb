module ArbitraryDataImporter

  def read_student_txt
    files = Dir.glob('spec/fixtures/student.txt').map do |file|
      FileEncodingSupport.new(file).file_with_encoding
    end
    reader = Reader.new(files).read_all
    reader.data
  end

  def read_staff_txt
    files = Dir.glob('spec/fixtures/staff.txt').map do |file|
      FileEncodingSupport.new(file).file_with_encoding
    end
    reader = Reader.new(files).read_all
    reader.data
  end
  module_function :read_student_txt, :read_staff_txt
end