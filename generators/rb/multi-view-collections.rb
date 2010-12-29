require 'find'

cmd = File.basename $0
usage = <<USAGE_MESSAGE
usage: #{cmd} top-level-directory
         top-level-directory -- the directory which will be recursively
                                searched for html files which will 
                                get their Vintage Posters and Art Glass
                                links updated to point to the multi view
                                pages
USAGE_MESSAGE

if ARGV.size != 1
  print usage
  exit 1
end

www_page_regex = Regexp.new '^.*\.html$'
art_glass_regex = Regexp.new '^.*penny\.html.*Art\ Glass.*$'
vintage_posters_regex = Regexp.new '^.*maitres\.html.*Vintage\ Posters.*$'

new_art_glass       = '              <a href="/art-glass/collections.html">Art Glass</a>'
new_vintage_posters = '              <a href="/vintage-posters/collections.html">Vintage Posters</a>'

Find.find ARGV[0] do |path|
  if www_page_regex.match(path) && File.file?(path) && !File.symlink?(path)
    source = File.new path
    dest_path = path + ".tmp"
    dest = File.new dest_path, "w"
    while line = source.gets
      if art_glass_regex.match line
        dest.puts new_art_glass
      elsif vintage_posters_regex.match line
        dest.puts new_vintage_posters
      else
        dest.puts line
      end
    end
    source.close
    dest.close
    File.rename dest_path, path
  end
end
