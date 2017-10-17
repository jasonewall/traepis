module EnvironmentHelper
  def root_application_domain
    domain = ENV.fetch('ROOT_APPLICATION_DOMAIN')
    domain = ".#{domain}" unless domain.start_with?('.')
    domain
  end

  def application_docker_repository
    repository = ENV.fetch('APPLICATION_DOCKER_REPOSITORY')
    repository = "#{repository}:" unless repository.end_with?(':')
    repository
  end
end
