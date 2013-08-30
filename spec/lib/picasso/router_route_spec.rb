require 'spec_helper'

require 'lib/picasso/router'

describe Picasso::Router::Route do
  subject(:route) do
    path_pattern = Picasso::Router::PathPattern.new(/[a-z]/, [])

    Picasso::Router::Route.new('POST', -> {}, path_pattern)
  end

  describe '#match' do
    it 'matches the given path' do
      route.match('/route').should be
    end
  end
end
