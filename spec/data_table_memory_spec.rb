require 'spec_helper'

describe DataTable do

  describe "without Redis" do

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
    
    it "should not have a table id" do
      datatable.table_id.nil?.should == true
    end

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