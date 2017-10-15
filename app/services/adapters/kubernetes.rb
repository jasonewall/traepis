module Adapters::Kubernetes
  HttpsServicePortEnv = ENV.fetch('HTTPS_SERVICE_PORT_ENV', 'KUBERNETES_SERVICE_PORT_HTTPS')
  HttpsServiceHostEnv = ENV.fetch('HTTPS_SERVICE_HOST_ENV', 'KUBERNETES_SERVICE_HOST')
  TokenFilePath = ENV.fetch('KUBERNETES_SERVICE_ACCOUNT_TOKEN_PATH', '/var/run/secrets/kubernetes.io/serviceaccount/token')
  CaFilePath = ENV.fetch('KUBERNETES_SERVICE_CA_CERT_PATH', '/var/run/secrets/kubernetes.io/serviceaccount/ca.crt')

module_function

  def client
    @client ||= Kubeclient::Client.new(service_url, 'v1', auth_options: auth_options, ssl_options: ssl_options)
  end

  def clients
    @clients ||= {}
  end

  def service_url(api = 'api')
    @service_url ||= "https://#{ENV[HttpsServiceHostEnv]}:#{ENV[HttpsServicePortEnv]}/#{api}/"
  end

  def auth_options
    @auth_options ||= {
      bearer_token_file: TokenFilePath
    }
  end

  def ssl_options
    @ssl_options ||= {
      ca_file: CaFilePath
    }
  end
end
