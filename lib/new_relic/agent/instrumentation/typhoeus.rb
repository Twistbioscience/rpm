# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

DependencyDetection.defer do
  @name = :typhoeus

  depends_on do
    defined?(Typhoeus)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Typhoeus instrumentation'
    require 'new_relic/agent/cross_app_tracing'
    require 'new_relic/agent/http_clients/typhoeus_wrappers'
  end

  executes do
    Typhoeus.before do |request|
      if NewRelic::Agent.is_execution_traced?
        wrapped_request = ::NewRelic::Agent::HTTPClients::TyphoeusHTTPRequest.new(request)
        t0, segment = ::NewRelic::Agent::CrossAppTracing.start_trace(wrapped_request)
        request.on_complete do
          wrapped_response = ::NewRelic::Agent::HTTPClients::TyphoeusHTTPResponse.new(request.response)
          ::NewRelic::Agent::CrossAppTracing.finish_trace(t0, segment, wrapped_request, wrapped_response)
        end
      end
    end
  end
end
