class BuildsRepository < ApplicationRepository
  def all
    kube_client.get_all_key_objects(KubernetesObjectTemplate.first).map do |id, objects|
      Build.from_k8s_api(id, objects)
    end
  end

  def find(id)
    Build.from_k8s_api(id, kube_client.get_objects_by_id(id, KubernetesObjectTemplate.all.map { |t| t.define_object(Build.new(id: id, image_tag: 'find')) }))
  end

private

  def create_new(build)
    objects = KubernetesObjectTemplate.all.map { |t| t.define_object(build) }
    objects.each do |o|
      kube_client.create_object(o)
    end
  end

  def update(build)
    if build.changed
      objects = KubernetesObjectTemplate.all.map { |t| t.define_object(build) }
      objects.each do |o|
        kube_client.update_object(o)
      end
    end
  end

  def delete(build)
    objects = build.objects.values.flatten
    objects.each do |o|
      kube_client.delete_object(o)
    end
  end

  def kube_client
    @kube_client ||= Adapters::Kubernetes.client
  end
end
