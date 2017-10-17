module Adapters::Kubernetes
  HttpsServicePortEnv = ENV.fetch('HTTPS_SERVICE_PORT_ENV', 'KUBERNETES_SERVICE_PORT_HTTPS')
  HttpsServiceHostEnv = ENV.fetch('HTTPS_SERVICE_HOST_ENV', 'KUBERNETES_SERVICE_HOST')
  TokenFilePath = ENV.fetch('KUBERNETES_SERVICE_ACCOUNT_TOKEN_PATH', '/var/run/secrets/kubernetes.io/serviceaccount/token')
  CaFilePath = ENV.fetch('KUBERNETES_SERVICE_CA_CERT_PATH', '/var/run/secrets/kubernetes.io/serviceaccount/ca.crt')

module_function

  def client
    @client ||= Client.new(
      Kubeclient::Client.new(service_url, 'v1', auth_options: auth_options, ssl_options: ssl_options),
      Kubeclient::Client.new(service_url('apis'), 'extensions/v1beta1', auth_options: auth_options, ssl_options: ssl_options)
    )
  end

  def clients
    @clients ||= {}
  end

  def service_url(api = 'api')
    "https://#{ENV[HttpsServiceHostEnv]}:#{ENV[HttpsServicePortEnv]}/#{api}/"
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

  class Client
    def initialize(*kube_clients)
      @kube_clients = kube_clients.reduce({}) do |memo, v|
        memo[v.instance_variable_get(:@api_version)] = v
        memo
      end
    end

    def kube_clients
      @kube_clients.values
    end

    def create_object(object)
      client = @kube_clients[object['apiVersion']]
      client.send("create_#{object.kind.underscore}", object)
    end

    def get_all_managed_objects
      entities = kube_clients.reduce({}) do |m, c|
        m.merge(c.all_entities(label_selector: "traepis.instance.id=#{ENV.fetch(TraepisInstanceId)}").except('component_status'))
      end

      pertinent_keys = entities.keys.select { |x| entities[x].count > 0 }
      pertinent_keys.reduce({}) do |memo, k|
        entities[k].each do |e|
          id = e.metadata.labels['traepis.build.id']
          memo[id] ||= {}
          memo[id][k] ||= []
          memo[id][k] << e
        end
        memo
      end
    end
  end
end
