require 'spec_helper'

require 'lib/angus/router'

describe Angus::Router::PathPattern do

  subject { Angus::Router::PathPattern.new(/[a-z]/, [:id]) }

  describe '#match' do

    it 'matches an expected path' do
      subject.match('a').should be
    end

    it 'does not match an unexpected path' do
      subject.match('0').should_not be
    end
  end
end
