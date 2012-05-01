require 'spec_helper'

describe Recap::Support::ShellCommand do
  subject { Recap::Support::ShellCommand }

  it 'returns stdout output if execution succeeds' do
    subject.execute("echo 'foo'").should eql("foo\n")
  end

  it 'returns stdout output from last command if execution of multiple commands succeeds' do
    subject.execute("echo 'foo'", "echo 'bar'").should eql("bar\n")
  end

  it 'does not raise error if execution succeeds' do
    lambda {
      subject.execute("true")
    }.should_not raise_error
  end

  it 'does not raise error if execution of multiple commands succeeds' do
    lambda {
      subject.execute("true", "true")
    }.should_not raise_error
  end

  it 'raises error if execution fails' do
    lambda {
      subject.execute("false")
    }.should raise_error
  end

  it 'raises error if execution of any command fails' do
    lambda {
      subject.execute("true", "false", "true")
    }.should raise_error
  end

  it 'includes exist status in error message if execution fails' do
    lambda {
      subject.execute("false")
    }.should raise_error(RuntimeError, %r{Command:\sfalse$})
  end

  it 'includes exist status in error message if execution fails' do
    lambda {
      subject.execute("false")
    }.should raise_error(RuntimeError, %r{Status:\s+1$})
  end

  it 'includes stderr output in error message if execution fails' do
    lambda {
      subject.execute("echo 'error' 1>&2 && false")
    }.should raise_error(RuntimeError, %r{Message:\s+error$})
  end
end
