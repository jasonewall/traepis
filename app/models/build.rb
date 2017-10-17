class Build < ApplicationRecord
  include EnvironmentHelper
  TraepisBuildId = 'traepis.build.id'.freeze
  TraepisBuildImageTag = 'traepis.build.image_tag'.freeze

  attr_accessor :id,
                :image_tag

  validates_presence_of :id, :image_tag

  attr_reader :objects

  def to_param
    id
  end

  def domain
    "#{id}#{root_application_domain}"
  end

  def image
    "#{application_docker_repository}#{image_tag}"
  end

  def annotations
    @annotations ||= {
      'metadata' => {
        'labels' => {
          'traepis.instance.id' => ENV.fetch(TraepisInstanceId),
          TraepisBuildId => id,
          TraepisBuildImageTag => image_tag
        }
      }
    }
  end

  def self.from_k8s_api(id, objects)
    image_tag = objects.first[1].first.metadata.labels[TraepisBuildImageTag]
    build = Build.new(id: id, image_tag: image_tag)
    build.instance_variable_set(:@objects, objects)
    build
  end
end
