require 'spec_helper'
require_relative 'reader_helper'

describe Reader do

  describe "without redis" do

    before :all do
      spawn 'redis-server', 'spec/fixtures/redis.conf' #spin up some redis on 6381
      sleep 2  #wait for redis to start
      @redis = Redis.new(:port => 6381) #get on that redis
      DataTable.config do |c|
        c.redis = false
        c.redis_port = 6381
        c.flushall
      end
    end

    it "should not use redis" do
      DataTable.config.redis.should == false
    end

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
  
end