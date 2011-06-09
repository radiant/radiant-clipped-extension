require File.dirname(__FILE__) + '/../spec_helper'

describe Paperclip::Geometry do
  let(:original) { Paperclip::Geometry.new(1200,600) }
  let(:small) { Paperclip::Geometry.new(100, 50) }
  let(:scaled) {Paperclip::Geometry.new(300, 150) }
  let(:incomplete) { Paperclip::Geometry.parse("300x") }
  let(:simple) { Paperclip::Geometry.parse("300x200") }
  let(:cropper) { Paperclip::Geometry.parse("300x200#") }
  let(:if_bigger) { Paperclip::Geometry.parse("300x200>") }
  let(:if_smaller) { Paperclip::Geometry.parse("300x200<") }
  let(:percentage) { Paperclip::Geometry.parse("25%") }
  let(:area) { Paperclip::Geometry.parse("180000@") }

  context "=~" do
    it "should compare sizes" do
      (original =~ small).should be_false
      (original =~ Paperclip::Geometry.new(1200,600)).should be_true
    end
    it "should ignore modifiers" do
      (simple =~ cropper).should be_true
    end
  end
  context "==" do
    it "should compare sizes and modifiers" do
      (original == Paperclip::Geometry.new(1200,600)).should be_true
      (simple == cropper).should be_false
    end
  end

  context "stripping modifier" do
    it "should return the same geometry with no modifier" do
      cropper.without_modifier.should == simple
      if_bigger.without_modifier.should == simple
    end
  end
  
  context "calculating thumbnail dimensions" do
    it "should raise an exception if called on a partial geometry" do
      lambda{incomplete * simple}.should raise_error(Paperclip::TransformationError)
    end
    it "should not raise an exception if called on a complete geometry" do
      lambda{original * simple}.should_not raise_error
    end
    it "should calculate the result of applying another geometry" do
      (original * simple).should == scaled
      (original * cropper).should == cropper.without_modifier
      (original * if_bigger).should == scaled
      (original * if_smaller).should == original
      (small * if_smaller).should == scaled
      (small * cropper).should == cropper.without_modifier
      (original * percentage).should == scaled
      (original * area).should == scaled
    end
    it "should cope with a partial-geometry argument" do
      (original * incomplete).should == scaled
    end
    it "should instantiate a non-geometry argument" do
      (original * "300x200").should == scaled
    end
  end
  
end
