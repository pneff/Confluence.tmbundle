#!/usr/bin/env ruby

begin
  require 'redcloth'
rescue LoadError
  $LOAD_PATH << File.join(ENV['TM_BUNDLE_SUPPORT'], 'lib')
  require 'redcloth'
end

contents = $stdin.readlines.join()

# Get all the noformat strings out so they don't interfere
noformat = []
contents.gsub!(/\{noformat\}(.*)\{noformat\}/m) do |match|
    pl = "#noformatplaceholder#" + noformat.length.to_s
    noformat.push($1)
    pl
end


## Replace links with Textile ones
# Internal links (replace with dummy)
contents.gsub!(/\[([^|\]]+)\]/, '"\1":http://dummy/\1')
# External links
contents.gsub!(/\[([^|\]]+)\|([^ \]]+)\]/, '"\1":\2')

# Workaround: Remove some Confluence tags that cause problems in Textile
contents.gsub!(/\{table-plus[^}]*\}/, '')
contents.gsub!(/\{excerpt[^}]*\}/, '')

# Textile
html = RedCloth.new(contents).to_html(:textile)

# Put the noformat strings back in
noformat.each_index do |idx|
    nf = noformat[idx]
    nf = '<pre>' + nf + '</pre>'
    html.gsub!("#noformatplaceholder#" + idx.to_s, nf)
end

puts html
