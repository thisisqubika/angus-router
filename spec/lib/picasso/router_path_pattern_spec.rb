require 'spec_helper'

require 'lib/picasso/router'

describe Picasso::Router::PathPattern do

  subject { Picasso::Router::PathPattern.new(/[a-z]/, [:id]) }

  describe '#match' do

    it 'matches an expected path' do
      subject.match('a').should be
    end

    it 'does not match an unexpected path' do
      subject.match('0').should_not be
    end
  end
end
