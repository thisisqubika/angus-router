require 'spec_helper'

require 'lib/angus/router'

describe Angus::Router do

  subject(:router) { Angus::Router.new }

  describe '#route' do

    let(:hello) { -> {} }
    let(:hello_dude) { -> {} }
    let(:bye) { -> {} }

    before do
      router.on(:get, '/hello', &hello)
      router.on(:get, '/hello/:dude', &hello_dude)
      router.on(:get, '/bye/', &bye)
    end

    it 'routes to the corresponding block' do
      hello.should_receive(:call)

      env = Angus::RackTest.env_for('/hello', :method => 'GET')

      router.route(env)
    end

    it 'passes the env to the corresponding block' do
      env = Angus::RackTest.env_for('/hello', :method => 'GET')

      hello.should_receive(:call).with(env, anything)

      router.route(env)
    end

    it 'also routes to parametrized routes' do
      hello_dude.should_receive(:call)

      env = Angus::RackTest.env_for('/hello/joe', :method => 'GET')

      router.route(env)
    end

    it 'sends path params' do
      env = Angus::RackTest.env_for('/hello/joe', :method => 'GET')

      hello_dude.should_receive(:call).with(anything, :dude => 'joe')

      router.route(env)
    end

    context 'when requesting with a trailing slash' do
      it 'invokes the correspoding route' do
        hello.should_receive(:call)

        env = Angus::RackTest.env_for('/hello/', :method => 'GET')

        router.route(env)
      end
    end

    context 'when requesting without a trailing slash' do
      it 'invokes the correspoding route' do
        bye.should_receive(:call)

        env = Angus::RackTest.env_for('/bye', :method => 'GET')

        router.route(env)
      end
    end

    context 'when conflicting routes' do
      let(:get_by_email) { ->(env, params) {} }
      let(:get_by_id) { ->(env, params) {} }

      context 'when parametrized route is defined first' do
        before do
          router.on(:get, '/users/:id', &get_by_id)
          router.on(:get, '/users/by_email', &get_by_email)
        end

        it 'invokes the non parametrized route when no params' do
          get_by_email.should_receive(:call)

          env = Angus::RackTest.env_for('/users/by_email', :method => 'GET')

          router.route(env)
        end

        it 'invokes the parametrized route when params' do
          get_by_id.should_receive(:call)

          env = Angus::RackTest.env_for('/users/1', :method => 'GET')

          router.route(env)
        end
      end

      context 'when parametrized route is defined last' do
        before do
          router.on(:get, '/users/by_email', &get_by_email)
          router.on(:get, '/users/:id', &get_by_id)
        end

        it 'invokes the non parametrized route when no params' do
          get_by_email.should_receive(:call)

          env = Angus::RackTest.env_for('/users/by_email', :method => 'GET')

          router.route(env)
        end

        it 'invokes the parametrized route when params' do
          get_by_id.should_receive(:call)

          env = Angus::RackTest.env_for('/users/1', :method => 'GET')

          router.route(env)
        end
      end
    end

    context 'when consecutive slashes' do
      let(:consecutive) { -> {} }

      before do
        router.on(:get, '/con//se///cu/tive', &consecutive)
      end

      it 'invokes the route' do
        consecutive.should_receive(:call)

        env = Angus::RackTest.env_for('///con//se/cu//tive', :method => 'GET')

        router.route(env)
      end
    end

    it 'raises NotImplementedError when no route matches' do
      env = Angus::RackTest.env_for('/no-route', :method => 'GET')

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
