require 'spec_helper'
require_relative 'fixtures/reader_helper'
module ArbitraryDataImporter
  describe Reader do

    context "with Redis" do
      before :all do
        DataTable.config do |c|
          c.redis = true
          c.redis_port = 6381
          c.flushall
        end
      end

      after :all do
        DataTable.config do |c|
          c.redis = false
        end
      end

      it "should use redis" do
        DataTable.config.redis.should == true
      end

      it "should be able to read a TSV file" do
        data = ArbitraryDataImporter::read_student_txt
        data.include?('spec/fixtures/student.txt').should == true
        values = data.values.first
        values.rows.count.should == 19
        values.rows.empty?.should == false
        values.table_id.nil?.should == false
      end

      it "should be able to read a CSV file" do
        data = ArbitraryDataImporter::read_staff_txt
        data.include?('spec/fixtures/staff.txt').should == true
        values = data.values.first
        values.rows.count.should == 19
        values.rows.empty?.should == false
        values.table_id.nil?.should == false
      end
    end
  end
end