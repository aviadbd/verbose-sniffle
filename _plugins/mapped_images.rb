module Jekyll
  module MapsFilter
    def map_marker(input, map)
      <<~END
      <script>
      /* var marker = */ L.marker([#{input.latitude}, #{input.longitude}]).addTo(#{map});
      </script>
      END
    end
    
    def render_map(input, name)
      <<~END
      <div id='#{name}'></div>
      
      <script>
      var lat = #{input.latitude}
      var lng = #{input.longitude}
  
      var map = L.map('name').setView([lat, lng], 13);
  
      L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
      }).addTo(map);
      </script>
      END
    end
  end
end


Liquid::Template.register_filter(Jekyll::MapsFilter)



