require 'exifr/jpeg'
require 'shellwords'
require 'key_value_parser'

module Jekyll
  class ExifMapTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @params = text
    end

    def render(context)
      argv = Shellwords.split @params
      options = KeyValueParser.new.parse(argv)
      
      image_list = context.registers[:page][options[:images]]
      
      "No Images Selected" unless image_list and not image_list.empty?

      locations = get_gps_locations(image_list)
      
      locations
      
#      create_map(locations)
    end

    def get_gps_locations(image_list)
      locations = []
      image_list.each do |image|
        next unless File.file?(image)

        exif = EXIFR::JPEG.new(image) 
        # surely there's a more ruby way to write this
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

    def create_map(locations)
      "No Locations" unless locations and not locations.empty?

      markers = create_markers(locations)

      center = "[#{locations[0][0]}, #{locations[0][1]}]"
      
      <<~HTML
      <div id='map'></div>
      <script>
        var map = L.map('map').setView(#{center}, 1);
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
