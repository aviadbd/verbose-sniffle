require 'exifr/jpeg'

module Jekyll
  class ExifMapTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @image_list = text.split(',').map(&:strip)
    end

    def render(context)
      locations = get_gps_locations(@image_list)
      markers = create_markers(locations)
      create_map(markers)
    end

    def get_gps_locations(image_list)
      locations = []
      image_list.each do |image|
        exif = EXIFR::JPEG.new(image)
        if exif.gps
          lat = exif.gps.latitude
          lng = exif.gps.longitude
          locations << [lat, lng]
        end
      end
      locations
    end

    def create_markers(locations)
      markers = ""
      locations.each do |location|
        lat = location[0]
        lng = location[1]
        markers += "L.marker([#{lat}, #{lng}]).addTo(map);\n"
      end
      markers
    end

    def create_map(markers)
      <<~HTML
      <div id='map'></div>
      <script>
        var map = L.map('map').setView([0, 0], 1);
        L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
          maxZoom: 19,
          attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        }).addTo(map);        
        
        #{markers}
      </script>
      HTML
    end
  end
end

Liquid::Template.register_tag('exif_map', Jekyll::ExifMapTag)
