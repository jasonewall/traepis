require 'support/kube_cleaner'

RSpec.configure do |config|
  config.after(:each) do |example|
    if example.metadata[:kubernetes_api]
      KubeCleaner.clean_up
    end
  end

  config.extend KubeCleaner::Helpers, :kubernetes_api
end
