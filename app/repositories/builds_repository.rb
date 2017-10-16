class BuildsRepository
  def save(build)
    if build.valid?
      commit(build)
    else
      @errors = build.errors
      false
    end
  end

  def errors
    @errors
  end

private

  def commit(build)
    objects = KubernetesObjectTemplate.all.map { |t| t.define_object(build) }
  end
end
