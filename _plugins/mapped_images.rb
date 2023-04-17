require 'key_value_parser'
require 'shellwords'
require 'exifr/jpeg'


module Jekyll
  class RenderTimeTag < Liquid::Tag
    include Jekyll::Filters::URLFilters    
    
    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def render(context)
      argv = Shellwords.split @text
      options = KeyValueParser.new.parse(argv)
      
      
      if options[:images].start_with?("page.") then
        images = context.registers[:page][options[:images][5..]]
      else
        images = context[options[:images]]
      end
        
      @context = context # for the relative_url method
        
      markers = images.map { |image| EXIFR::JPEG.new(relative_url(image)).gps }

        # see https://leafletjs.com/examples/quick-start/ 
      <<~END
      var lat = #{markers[0].latitude}
      var lng = #{markers[0].longitude}
  
      var map = L.map('map').setView([lat, lng], 13);
  
      L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
      }).addTo(map);
      END

#       {% for marker in include.markers do %}
#         /* var marker = */ L.marker([{{ marker.latitude }}, {{ marker.longitude }}]).addTo(map);
#       {% endfor %}
    end
  end
end

Liquid::Template.register_tag('mapped_images', Jekyll::RenderTimeTag)
