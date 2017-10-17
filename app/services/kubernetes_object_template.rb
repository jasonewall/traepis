class KubernetesObjectTemplate
  class << self
    def all
      config_files.map do |f|
        new(File.read(f))
      end
    end

    def first
      new(File.read(config_files.first))
    end

    def config_files
      Dir["#{ENV.fetch('KUBERNETES_OBJECT_CONFIG_FILE_DIR', Rails.root.join('config', 'k8s').to_s)}/*"]
    end

    def defaults
      @defaults ||= {
        'metadata' => {
          'namespace' => ENV.fetch('KUBERNETES_DEFAULT_NAMESPACE', 'default')
        }
      }
    end
  end

  delegate :[], to: :resource_template

  def initialize(template)
    @template = template
  end

  def define_object(build)
    hash = build.annotations.deep_merge(load_yaml(build))
    Kubeclient::Resource.new(self.class.defaults.deep_merge(hash))
  end

private

  def load_yaml(build)
    YAML.load(render_yaml(build))
  end

  def render_yaml(build)
    ERB.new(@template).result(binding)
  end

  def resource_template
    @resource_template ||= Kubeclient::Resource.new(self.class.defaults.deep_merge(YAML.load(@template)))
  end
end
