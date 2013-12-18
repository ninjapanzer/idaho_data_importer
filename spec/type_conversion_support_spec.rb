require 'spec_helper'

describe TypeConversionSupport do

  let(:test_string)  { "happy tacos" }
  let(:test_float)   { "3.1415" }
  let(:test_integer) { "1005033" }

  it "should identify string with string" do
    TypeConversionSupport::Utility.convert_numeric(test_string).should == test_string
  end

  it "should identify string with float" do
    TypeConversionSupport::Utility.convert_numeric(test_float).should == 3.1415
  end

  it "should identify string with integer" do
    TypeConversionSupport::Utility.convert_numeric(test_integer).should == 1005033
  end
end