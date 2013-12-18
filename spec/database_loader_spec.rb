require 'spec_helper'
module ArbitraryDataImporter
  require_relative 'fixtures/reader_helper'
  describe DatabaseLoader do

    let(:data) {ArbitraryDataImporter::read_staff_txt}
    
    context "sqlite3" do
      
      let(:loader) {DatabaseLoader.new data}

      it "should use sqlite3" do
        DatabaseLoader.config.dbengine.should == :sqlite
      end

      it "should loader data" do
        orig_headers = data["spec/fixtures/staff.txt"].rows.first.keys
        loader_headers = loader.connection['staff.txt'.to_sym].first.keys
        loader_first_row = loader.connection['staff.txt'.to_sym].first
        loader_first_row[:staff_code].class.should == Fixnum
        (orig_headers.count+1).should == loader_headers.count # account for the new Id column
        loader.connection['staff.txt'.to_sym].count.should == 19
      end

    end

    context "postgres" do
      before :all do
        #config for postgres
      end
      after :all do
        #unconfig for postges
      end
      let(:loader) {DatabaseLoader.new data}
=begin  NOT READY YET
      it "should use sqlite3" do
        DatabaseLoader.config.dbengine.should == :postgres
      end

      it "should loader data" do
        orig_headers = data["spec/fixtures/staff.txt"].rows.first.keys
        loader_headers = loader.connection['staff.txt'.to_sym].first.keys
        loader_first_row = loader.connection['staff.txt'.to_sym].first
        loader_first_row[:staff_code].class.should == Fixnum
        (orig_headers.count+1).should == loader_headers.count # account for the new Id column
        loader.connection['staff.txt'.to_sym].count.should == 19
      end
=end
    end
  end
end