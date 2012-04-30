require 'spec_helper'

describe Recap::Support::Environment do
  describe '#empty?' do
    it 'returns true if no variables set' do
      Recap::Support::Environment.new.empty?.should be_true
    end

    it 'returns false if no variables set' do
      Recap::Support::Environment.new('FIRST' => 'One').empty?.should be_false
    end
  end

  describe '#include?(key)' do
    it 'returns true if variables set' do
      Recap::Support::Environment.new('FIRST' => 'One').include?('FIRST').should be_true
    end

    it 'returns false if variable has not been set' do
      Recap::Support::Environment.new('DIFFERENT' => 'One').include?('FIRST').should be_false
    end
  end

  describe '#get(name)' do
    subject do
      Recap::Support::Environment.new('FIRST' => 'One')
    end

    it 'returns value if variable set' do
      subject.get('FIRST').should eql('One')
    end

    it 'returns nil if variable not set' do
      subject.get('MISSING').should be_nil
    end
  end

  describe '#set(name, value)' do
    subject do
      Recap::Support::Environment.new('FIRST' => 'One')
    end

    it 'sets variable value' do
      subject.set('SECOND', 'Two')
      subject.get('SECOND').should eql('Two')
    end

    it 'unsets variable if value is nil' do
      subject.set('FIRST', nil)
      subject.get('FIRST').should be_nil
      subject.include?('FIRST').should be_false
    end

    it 'unsets variable if value is empty' do
      subject.set('FIRST', '')
      subject.get('FIRST').should be_nil
      subject.include?('FIRST').should be_false
    end
  end

  describe '#each' do
    subject do
      Recap::Support::Environment.new('FIRST' => 'One', 'SECOND' => 'Two', 'THIRD' => 'Three', 'FOURTH' => 'Four')
    end

    it 'yields each variable and value in turn (ordered alphabetically)' do
      result = []
      subject.each do |k, v|
        result << [k, v]
      end
      result.should eql([['FIRST', 'One'], ['FOURTH', 'Four'], ['SECOND', 'Two'], ['THIRD', 'Three']])
    end
  end

  describe '#merge(variables)' do
    subject do
      Recap::Support::Environment.new('FIRST' => 'One')
    end

    it 'sets each variable value' do
      subject.merge('SECOND' => 'Two', 'THIRD' => 'Three')
      subject.get('SECOND').should eql('Two')
      subject.get('THIRD').should eql('Three')
    end

    it 'preserves existing values if not provided' do
      subject.merge('ANYTHING' => 'Goes')
      subject.get('FIRST').should eql('One')
    end

    it 'overides existing values if provided' do
      subject.merge('FIRST' => 'Un')
      subject.get('FIRST').should eql('Un')
    end
  end

  describe '#to_s' do
    subject do
      Recap::Support::Environment.new('FIRST' => 'One', 'SECOND' => 'Two', 'THIRD' => nil, 'FOURTH' => 'Four').to_s
    end

    it 'declares each variable on its own line' do
      subject.match(/^FIRST=One\n/).should_not be_nil
      subject.match(/^SECOND=Two\n/).should_not be_nil
      subject.match(/^FOURTH=Four\n/).should_not be_nil
    end

    it 'ignores nil variable values' do
      subject.match(/THIRD/).should be_nil
    end

    it 'orders variables alphabetically' do
      indexes = ['FIRST', 'FOURTH', 'SECOND'].map {|k| subject.index(k)}
      indexes.sort.should eql(indexes)
    end
  end

  describe '.from_string(declarations)' do
    it 'builds instance using string representation' do
      instance = Recap::Support::Environment.from_string("FIRST=One\nSECOND=Two\n")
      instance.get('FIRST').should eql('One')
      instance.get('SECOND').should eql('Two')
    end

    it 'handles variables with numbers and underscores in their names' do
      instance = Recap::Support::Environment.from_string("THIS_1=One\nThose_2=Two\n")
      instance.get('THIS_1').should eql('One')
      instance.get('Those_2').should eql('Two')
    end

    it 'gracefully ignores missing newline at end of string' do
      instance = Recap::Support::Environment.from_string("FIRST=One\nSECOND=Two")
      instance.get('FIRST').should eql('One')
      instance.get('SECOND').should eql('Two')
    end

    it 'acts as the inverse of #to_s' do
      string = "FIRST=One\nSECOND=Two\nTHIRD=three\n"
      excercised = Recap::Support::Environment.from_string(Recap::Support::Environment.from_string(string).to_s).to_s
      excercised.should eql(string)
    end
  end
end