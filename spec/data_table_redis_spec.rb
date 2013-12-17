require 'spec_helper'

describe DataTable do

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

    let(:valid_table) { DataTable.new(
                        ['col_one','col_two'],
                        [{'col_one'=> 'happy','col_two' => 'two'},{'col_one'=> 'sad','col_two' => 'two'}]
                      )
                    }

    let(:mixed_types) { DataTable.new(
                          ['col_string', 'col_integer', 'col_float'],
                          [{'col_string' => 'happy', 'col_integer' => 100, 'col_float' => 1.11}]
                        )
                      }

    let(:datatable) { DataTable.new(headers, rows, table_id) }
    let(:table_id)  { nil }
    let(:headers)   { nil }
    let(:rows)      { nil }

    it "should accept rows" do
    end

    context "headers not supplied" do
      it "should fail to add headers not in an array" do
        expect {datatable.add_headers(nil)}.to raise_error(DataTableException::NotAnArray)
      end
      it "should fail to add rows" do
        expect {datatable.add_row nil}.to raise_error(DataTableException::HeadersNotSet)
      end

      it "should fail if the headers missmatch" do
        datatable.add_headers ['col_one', 'col_two']
        expect {datatable.add_row [10]}.to raise_error(DataTableException::InvalidRow)
      end

      it "should have a table id" do
        datatable.table_id.nil?.should == false
      end
    end

    context "headers supplied" do
      let(:headers) {['col_one','col_two']}
      it "should have a table id" do
        datatable.table_id.nil?.should == false
      end
    end

    context "table_id supplied" do
      let(:table_id) { valid_table.table_id }
      it "should be able to assume an existing table hash" do
        datatable.table_id.should == table_id
        datatable.row_count.should == valid_table.row_count
        datatable.rows.should == valid_table.rows
      end

      it "should be able to refresh when linked tables update" do
        datatable.table_id.should == table_id
        valid_table.add_row({'col_one' => 'another', 'col_two' => 'three'})
        datatable.row_count.should_not == valid_table.row_count
        datatable.refresh
        datatable.row_count.should == valid_table.row_count
      end
    end

    context "mixed datatypes" do
      it "should return string for strings" do
        mixed_types.rows.first['col_string'].class.should == String
      end
      it "should return FixNum for integers" do
        mixed_types.rows.first['col_integer'].class.should == Fixnum
      end
      it "should return Float for floats" do
        mixed_types.rows.first['col_float'].class.should == Float
      end
      it "should return a headers hash" do
        types = mixed_types.header_types_hash
        types[:col_string].should == String
        types[:col_integer].should == Fixnum
        types[:col_float].should == Float
      end
    end
  end
end