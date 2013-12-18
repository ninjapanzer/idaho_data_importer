require 'spec_helper'
require_relative 'fixtures/joiner_helper'

describe Joiner do

  let(:student_data) { read_student_fixtures }

  let(:joiner) {Joiner.build_with_data(key_array, join_data)}

  let(:join_data) { student_data }

  context "sqlite3" do #SQL is perfered for proper processing

    let(:key_array) {[:student_code]}

    before :each do
      @db_loader = DatabaseLoader.new join_data
    end

    after :each do
      @db_loader.connection.disconnect
    end

    it "should join data" do
      joined = joiner.run_with_sql @db_loader.connection
      joined.count.should == 1
      joined['student_code'].headers.count.should == 43
      joined['student_code'].row_count.should == 1
    end

    it "should expire data" do

    end
  end

  context "memory" do #memory does not operate the same as SQL

    let(:key_array) {[:student_code]}

    it "should join data" do
      joined = joiner.run
      joined.count.should == 1
      joined['student_code'].headers.count.should == 34
      joined['student_code'].row_count.should == 37
    end
  end
end