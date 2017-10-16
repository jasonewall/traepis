module RepositoryFactory
  def builds_repository
    @builds_repository ||= BuildsRepository.new
  end
end
