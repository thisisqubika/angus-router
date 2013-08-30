# Based on code extrated from the following source.
# - https://raw.github.com/brynary/rack-test/280ff54f50d25dd70e2ec1c55049e5ef7de126f3/lib/rack/test.rb
# - https://raw.github.com/brynary/rack-test/280ff54f50d25dd70e2ec1c55049e5ef7de126f3/lib/rack/test/utils.rb

require "uri"
require "rack"

module Picasso
  module RackTest

    def self.env_for(path, env)
      uri = URI.parse(path)
      uri.path = "/#{uri.path}" unless uri.path[0] == ?/
      uri.host ||= @default_host

      env = default_env.merge(env)

      env["HTTP_HOST"] ||= [uri.host, (uri.port if uri.port != uri.default_port)].compact.join(":")

      env.update("HTTPS" => "on") if URI::HTTPS === uri
      env["HTTP_X_REQUESTED_WITH"] = "XMLHttpRequest" if env[:xhr]

      if env["REQUEST_METHOD"] == "GET"
        # merge :params with the query string
        if params = env[:params]
          params = parse_nested_query(params) if params.is_a?(String)
          params.update(parse_nested_query(uri.query))
          uri.query = build_nested_query(params)
        end
      elsif !env.has_key?(:input)
        env["CONTENT_TYPE"] ||= "application/x-www-form-urlencoded"

        if env[:params].is_a?(Hash)
          env[:input] = params_to_string(env[:params])
        else
          env[:input] = env[:params]
        end
      end

      env.delete(:params)

      if env.has_key?(:cookie)
        set_cookie(env.delete(:cookie), uri)
      end

      Rack::MockRequest.env_for(uri.to_s, env)
    end

    def self.default_env
      { "rack.test" => true, "REMOTE_ADDR" => "127.0.0.1" }
    end

    def self.params_to_string(params)
      case params
      when Hash then build_nested_query(params)
      when nil  then ""
      else params
      end
    end

    def self.build_nested_query(value, prefix = nil)
      case value
      when Array
        value.map do |v|
          unless unescape(prefix) =~ /\[\]$/
            prefix = "#{prefix}[]"
          end
          build_nested_query(v, "#{prefix}")
        end.join("&")
      when Hash
        value.map do |k, v|
          build_nested_query(v, prefix ? "#{prefix}[#{escape(k)}]" : escape(k))
        end.join("&")
      when NilClass
        prefix.to_s
      else
        "#{prefix}=#{escape(value)}"
      end
    end
  end

end
