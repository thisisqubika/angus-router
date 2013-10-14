require 'rack'

module Picasso
  class Router

    SUPPORTED_HTTP_METHODS = [
      :get,
      :post,
      :put,
      :delete,
      :head,
      :options,
      :patch,
      :trace
    ]

    PathPattern = Struct.new(:re_path, :param_names) do

      # Matches the given path against #re_path.
      #
      # @return [MatchData] when match succeeds
      # @return [nil] when match fails
      def match(path)
        re_path.match(path)
      end
    end

    Route = Struct.new(:method, :proc, :path_pattern) do

      # Returns the parameter names for this route.
      #
      # @return [Array<String>]
      def param_names
        path_pattern.param_names
      end

      # Matches the given path against #path_pattern.
      #
      # @return [MatchData] when match succeeds
      # @return [nil] when match fails
      def match(path)
        path_pattern.match(path)
      end
    end

    # It registers block to be yielded at a given HTTP method and path.
    #
    # @param [Symbol] m HTTP method (see SUPPORTED_HTTP_METHODS)
    # @param [String] path Url path
    # @param [Proc] block The block that will be yielded when an incoming request matches the route
    def on(m, path, &block)
      unless SUPPORTED_HTTP_METHODS.include?(m)
        raise ArgumentError.new("Unsupported HTTP method #{m}")
      end

      routes << Route.new(m.to_s.upcase, block, compile(path))
    end

    # Calls the corresponding previously registered block.
    #
    # When calling, the rack environment and the extracted path params are passed
    # to the route block.
    #
    # @param [Hash] env A Rack environment. (see http://rack.rubyforge.org/doc/SPEC.html)
    #
    # @return The result of the block call
    def route(env)
      request = Rack::Request.new(env)

      matched_route = match_route(env['REQUEST_METHOD'], request.path_info)

      match, route_block, path_param_names = matched_route

      unless match
        raise NotImplementedError, "No route found #{request.path_info}"
      end

      path_params = extract_params(match, path_param_names)
      whole_params = request.params.clone.merge!(path_params)
      whole_params = symbolize(whole_params)

      route_block.call(env, whole_params)
    end

    private
    # Returns a shallow copy with keys as symbols of hash.
    #
    # @param [Hash] hash
    #
    # @return [Hash]
    def symbolize(hash)
      Hash[
        hash.map { |k, v| [k.to_sym, v] }
      ]
    end

    def routes
      @routes ||= []
    end

    # Returns a path pattern base on the given pattern.
    #
    # @example compile('/users/:id')
    #   => PathPattern.new(/^\/users\/([^\/?#]+)$/, ['id']])
    #
    # @param [String] Url path
    #
    # @return [PathPattern]
    def compile(pattern)
      keys = []

      pattern = pattern.to_str.gsub(/[^\?\%\\\/\:\*\w]/) { |c| encoded(c) }
      pattern.gsub!(/(:\w+)/) do |match|
        keys << $1[1..-1]
        "([^/?#]+)"
      end

      PathPattern.new(/^#{pattern}$/, keys)
    end

    # Escapes a char for uri regex matching.
    #
    # @param [String] char
    #
    # @return [String]
    def encoded(char)
      enc = URI.escape(char)
      enc = "(?:#{Regexp.escape enc}|#{URI.escape char, /./})" if enc == char
      enc = "(?:#{enc}|#{encoded('+')})" if char == " "
      enc
    end

    # Returns regexp, block and path param names according to the route that matches
    # the given method and path.
    #
    # @param [String] method HTTP method
    # @param [String] path Url path
    #
    # @return [regexp, route_block, path_param_names]
    def match_route(method, path)
      @routes.each do |route|
        if method == route.method && match = route.match(path)
          return [match, route.proc, route.param_names]
        end
      end

      nil
    end

    # Extracts matched values from the given match.
    #
    # Assoaciates each match to the corresponding key.
    #
    # @param [MatchData] match
    # @param [Array] keys
    #
    # @return [Hash] A hash containing extracted key / values
    def extract_params(match, keys)
      hash = {}

      captures = match.captures

      keys.each_with_index do |k, i|
        hash[k] = captures[i]
      end

      hash
    end

  end
end
