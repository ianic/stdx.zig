#!/usr/bin/env ruby
require 'erb'

remove = ARGV.length > 0 and ARGV[0].include?("-remove")

header=`sed '/START GEN/q' sum_of_products.zig`
footer=`sed -ne '/END GEN/,$ p' sum_of_products.zig`

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

body = ""
(2..64).each do |k|
  body += ERB.new(tmpl, trim_mode: '-').result(binding)
end

content = header
content += body unless remove
content += footer

File.write('sum_of_products.zig', content)
`zig fmt sum_of_products.zig`
