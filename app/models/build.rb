class Build < ApplicationRecord
  TraepisBuildId = 'traepis.build.id'.freeze
  TraepisBuildImageTag = 'traepis.build.image_tag'.freeze

  attr_accessor :id,
                :image_tag

  validates_presence_of :id, :image_tag

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
    image_tag = objects.first[1].first.metadata.annotations[TraepisBuildId]
    build = Build.new(id: id, image_tag: image_tag)
    build.instance_variable_set(:@objects, objects.reduce([]) { |memo, (x,y)| memo += y })
    build
  end
end
