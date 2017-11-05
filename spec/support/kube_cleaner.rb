module KubeCleaner
  module Helpers
    def kubelet(name, &block)
      ivar = "@#{name}"
      before(:each) do
        hash = instance_eval(&block)
        k8s_object = Kubeclient::Resource.new(hash)
        Adapters::Kube
        k8s_objects << k8s_object
        instance_variable_set(ivar, k8s_object)
      end
      define_method(name) { instance_variable_get(ivar) }
    end

    def k8s_objects
      @k8s_objects ||= []
    end
  end
end
