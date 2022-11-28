#!/usr/bin/env ruby
require 'erb'
require 'nokogiri'


tmpl = <<~EOF
                <%= k %> => {
                    <%- (1..k-1).each do |i| -%>
                    var l<%= i %>: usize = k - <%= i %>;
                    while (l<%= i %> < <% if i==1 %>n<% else %>l<%= i-1 %><% end %>) : (l<%= i %> += 1) {
                        var p<%= i %>: T = <%if i==1 %>items[l<%= i %>];<% else %>p<%= i-1 %> * items[l<%= i %>];<% end %>
                    <%- end -%>
                        var l<%= k %>: usize = k - <%= k %>;
                        while (l<%= k %> < l<%= k-1 %>) : (l<%= k %> += 1) {
                            s += p<%= k-1 %> * items[l<%= k %>];
                    <%- (1..k).each do |i| -%>
                    }
                    <%- end -%>
                },
EOF

(2..64).each do |k|
  puts ERB.new(tmpl, trim_mode: '-').result(binding)
end
