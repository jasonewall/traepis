class Build < ApplicationRecord
  attr_accessor :id,
                :image_tag

  validates_presence_of :id, :image_tag

  def as_path
    {
      :namespace => 'fart',
      :id => 'name'
    }
  end

  def annotations
    @annotations ||= {
      'metadata' => {
        'labels' => {
          'traepis-entity' => 'yes'
        },
        'annotations' => {
          'traepis.build.id' => id,
          'traepis.build.image_tag' => image_tag
        }
      }
    }
  end
end
