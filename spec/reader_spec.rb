require 'spec_helper'

describe Reader do

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

  describe "without redis" do
    it "Should be able to read a TSV file" do
      data = read_student_txt
      data.include?('spec/fixtures/student.txt').should == true
      values = data.values.first
      values.rows.count.should == 19
      values.rows.empty?.should == false
      values.table_id.should == nil
    end

    it "Should be able to read a CSV file" do
      data = read_staff_txt
      data.include?('spec/fixtures/staff.txt').should == true
      values = data.values.first
      values.rows.count.should == 19
      values.rows.empty?.should == false
      values.table_id.should == nil
    end
  end
  
  describe "with Redis" do
    before :all do
      spawn 'redis-server', 'spec/fixtures/redis.conf' #spin up some redis on 6381
      sleep 2  #wait for redis to start
      @redis = Redis.new(:port => 6381) #get on that redis
      DataTable.config do |c|
        c.redis = true
        c.redis_port = 6381
        c.flushall
      end
    end

    after :all do
      @redis.shutdown
    end

    it "should be able to read a TSV file" do
      data = read_student_txt
      data.include?('spec/fixtures/student.txt').should == true
      values = data.values.first
      values.rows.count.should == 19
      values.rows.empty?.should == false
      values.table_id.nil?.should == false
    end

    it "should be able to read a CSV file" do
      data = read_staff_txt
      data.include?('spec/fixtures/staff.txt').should == true
      values = data.values.first
      values.rows.count.should == 19
      values.rows.empty?.should == false
      values.table_id.nil?.should == false
    end
  end
end