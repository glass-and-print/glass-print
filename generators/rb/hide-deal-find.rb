require 'find'

cmd = File.basename $0
usage = <<USAGE_MESSAGE
usage: #{cmd} top-level-directory
         top-level-directory -- the directory which will be recursively
                                searched for html files which will be
                                scanned for the deal|find divs which if
                                found will be commented
USAGE_MESSAGE

if ARGV.size != 1
  print usage
  exit 1
end

www_page_regex = Regexp.new '^.*\.html$'
deal_regex = Regexp.new '^(.*)<div.*\"(make-a-deal|find-request)\".*>.*<\/div>(.*)$'

Find.find ARGV[0] do |path|
  if www_page_regex.match(path) && File.file?(path) && !File.symlink?(path)
    source = File.new path
    dest_path = path + ".tmp"
    dest = File.new dest_path, "w"
    while line = source.gets
      if m = deal_regex.match(line)
        g1, g2, g3 = m.captures
        dest.puts g1 + '<!-- ' + line.strip + ' -->' + g3
      else
        dest.puts line
      end
    end
    source.close
    dest.close
    File.rename dest_path, path 
  end
end
