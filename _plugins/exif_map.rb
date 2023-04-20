require 'exiftool'
require 'shellwords'
require 'key_value_parser'

module Jekyll
  class ExifMapTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @params = text
    end

    def render(context)
      options = parse_params(context)
      
      image_list = context.registers[:page][options[:images]]
      center = context.registers[:page][options[:center]]
      
      
      return "No Images Selected" unless not image_list&.empty?

      locations = get_gps_locations(image_list)
      locations = [center] unless not locations&.empty?
      
      create_map(locations)
    end

    private
    
    def parse_params(context)
      argv = Shellwords.split @params
      options = KeyValueParser.new.parse(argv)
      
      options
    end
    
    def get_gps(image)
      exif = Exiftool.new(image)
      gps = exif&[:gpsposition]
      gps  
      ? [
        gps[0].to_f,
        gps[1].to_f
      ]
      : nil
    end
    
    def get_gps_locations(image_list)
      locations = []
      image_list.each do |image|
        next unless File.file?(image)
        
        gps = get_gps(image)
        
        next unless gps

        locations << gps
        end
      end
      locations
    end

    def create_markers(locations)
      markers = ""
      return markers unless not locations&.empty?
      
      locations.each do |location|
        lat = location[0]
        lng = location[1]
        markers += "L.marker([#{lat}, #{lng}]).addTo(map);\n"
      end
      markers
    end

    def create_map(locations)
      return "No Locations" unless not locations&.empty?

      markers = create_markers(locations)

      center = "[#{locations[0][0]}, #{locations[0][1]}]"
      
      <<~HTML
      <div id='map'></div>
      <script>
        var map = L.map('map').setView(#{center}, 10);
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
