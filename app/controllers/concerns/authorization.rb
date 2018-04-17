module Authorization
  Providers = {
    'basic' => BasicHttpProvider
  }.freeze

  def auth_provider
    return NullProvider.new unless auth_config.present?

    Providers.fetch(auth_config['type']) do
      warn "Auth provider '#{auth_config['type']}' not known. Defaulting to null."
    end.new(auth_config)
  end

  def auth_config
    @auth_config ||= begin
      yaml = Rails.root.join(*%w[config auth config.yml])

      if yaml.exist?
        (YAML.load(ERB.new(yaml.read).result) || {})[Rails.env]
      end
    end
  rescue Psych::SyntasError => e
    raise "YAML syntax error in auth/config.yml"
  end
end
