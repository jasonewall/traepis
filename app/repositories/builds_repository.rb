class BuildsRepository
  def save(build)
    if build.valid?
      commit(build)
    else
      @errors = build.errors
      false
    end
  end

  def all
    kube_client.get_all_key_objects(KubernetesObjectTemplate.first).map do |id, objects|
      Build.from_k8s_api(id, objects)
    end
  end

  def errors
    @errors
  end

private

  def commit(build)
    objects = KubernetesObjectTemplate.all.map { |t| t.define_object(build) }
    objects.each do |o|
      kube_client.create_object(o)
    end
  end

  def kube_client
    @kube_client ||= Adapters::Kubernetes.client
  end
end
