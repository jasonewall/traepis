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
        v.discover unless v.discovered
        memo
      end
    end

    def kube_clients
      @kube_clients.values
    end

    def entities
      @entities = @kube_clients.reduce({}) do |memo, (k,v)|
        memo[k] = v.instance_variable_get(:@entities).values
        memo
      end
    end

    def create_object(object)
      client = @kube_clients[object['apiVersion']]
      client.send(:create_entity, object.kind, resource_names[object.kind], object, resource_class(object))
    end

    def update_object(object)
      client = @kube_clients[object['apiVersion']]
      client.send(:patch_entity, resource_names[object.kind], object.metadata.name, object, object.metadata.namespace)
    end

    def delete_object(object)
      client = @kube_clients[object['apiVersion']]
      client.send(:delete_entity, resource_names[object.kind], object.metadata.name, object.metadata.namespace)
    end

    def get_all_key_objects(key_resource)
      klass = resource_class(key_resource)
      kind = key_resource['kind']
      entities = @kube_clients[key_resource['apiVersion']].get_entities(key_resource['kind'], klass, resource_names[kind], default_options)

      entities.reduce({}) do |memo, e|
        id = e.metadata.labels['traepis.build.id']
        memo[id] ||= {}
        memo[id][kind] ||= []
        memo[id][kind] << e
        memo
      end
    end

    def get_objects_by_id(id, resources)
      resources.reduce({}) do |memo, r|
        memo[r.kind] ||= []
        memo[r.kind] << @kube_clients[r['apiVersion']].get_entity(
          resource_class(r),
          resource_names[r.kind],
          r.metadata.name,
          r.metadata.namespace,
          default_options.merge(Build::TraepisBuildId => id)
        )
        memo
      end
    end

    def resource_class(resource)
      Kubeclient::ClientMixin.resource_class(Kubeclient, resource['kind'])
    end

    def resource_names
      @resource_names ||= Hash.new do |h, kind|
        h[kind] = entities.values.flatten.find { |x| x.entity_type == kind }.resource_name
      end
    end

    def default_options
      @default_options = { label_selector: "traepis.instance.id=#{ENV.fetch(TraepisInstanceId)}" }
    end
  end
end
