require 'spec_helper'

require 'lib/picasso/router'

describe Picasso::Router do

  subject(:router) { Picasso::Router.new }

  describe '#route' do

    let(:hello) { -> {} }
    let(:hello_dude) { -> {} }

    before do
      router.on(:get, '/hello', &hello)
      router.on(:get, '/hello/:dude', &hello_dude)
    end

    it 'routes to the corresponding block' do
      hello.should_receive(:call)

      env = Picasso::RackTest.env_for('/hello', :method => 'GET')

      router.route(env)
    end

    it 'passes the env to the corresponding block' do
      env = Picasso::RackTest.env_for('/hello', :method => 'GET')

      hello.should_receive(:call).with(env, anything)

      router.route(env)
    end

    it 'also routes to parametrized routes' do
      hello_dude.should_receive(:call)

      env = Picasso::RackTest.env_for('/hello/joe', :method => 'GET')

      router.route(env)
    end

    it 'sends path params' do
      env = Picasso::RackTest.env_for('/hello/joe', :method => 'GET')

      hello_dude.should_receive(:call).with(anything, :dude => 'joe')

      router.route(env)
    end

    it 'raises NotImplementedError when no route matches' do
      env = Picasso::RackTest.env_for('/no-route', :method => 'GET')

      expect {
        router.route(env)
      }.to raise_error(NotImplementedError, /No route found/)
    end
  end

  describe '#on' do
    it 'raises an error when unknown http method' do
      expect {
        router.on(:unknown, '/some-path')
      }.to raise_error(ArgumentError, /Unsupported HTTP method/)
    end
  end
end
