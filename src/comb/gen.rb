#!/usr/bin/env ruby
require 'erb'
require 'nokogiri'


tmpl = <<~EOF
                <%= r %> => {
                    <%- (1..r-1).each do |i| -%>
                    var l<%= i %>: usize = r - <%= i %>;
                    while (l<%= i %> < <% if i==1 %>n<% else %>l<%= i-1 %><% end %>) : (l<%= i %> += 1) {
                        var p<%= i %>: T = <%if i==1 %>items[l<%= i %>];<% else %>p<%= i-1 %> * items[l<%= i %>];<% end %>
                    <%- end -%>
                        var l<%= r %>: usize = r - <%= r %>;
                        while (l<%= r %> < l<%= r-1 %>) : (l<%= r %> += 1) {
                            s += p<%= r-1 %> * items[l<%= r %>];
                    <%- (1..r).each do |i| -%>
                    }
                    <%- end -%>
                },
EOF

(2..64).each do |r|
  puts ERB.new(tmpl, trim_mode: '-').result(binding)
end
