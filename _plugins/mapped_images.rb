require 'key_value_parser'
require 'shellwords'

module Jekyll
  module MapsFilter
    def map_marker(input)
      <<~END
      <script>
        /* var marker = */ L.marker([#{input['latitude']}, #{input['longitude']}]).addTo(map);
      </script>
      END
    end
    
    def map_setview(input)
      <<~END
      <script>
        map.setView([lat, lng], 13);
      </script>
      END
    end
  end
  
  class RenderMapTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def render(context)
      argv = Shellwords.split @text
      options = KeyValueParser.new.parse(argv)
      
      <<~END
      <div id='#{options[:name]}'></div>
      
      <script>
        var map = L.map(#{options[:name]})

        L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
          maxZoom: 19,
          attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        }).addTo(map);
      </script>
      END
    end
  end
end

Liquid::Template.register_tag('render_map', Jekyll::RenderMapTag)
Liquid::Template.register_filter(Jekyll::MapsFilter)



