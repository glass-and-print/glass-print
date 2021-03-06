require 'find'

cmd = File.basename $0
usage = <<USAGE_MESSAGE
usage: #{cmd} top-level-directory
         top-level-directory -- the directory which will be recursively
                                searched for html sources that will in turn
                                be searched for the copyright notice to be
                                tweaked.
USAGE_MESSAGE

if ARGV.size != 1
  print usage
  exit 1
end

copyright_notice = <<COPYRIGHT_NOTICE
    Happy New Year! Get 25% - 50% off on any item by sending us an <a href="mailto:toni@glass-print.com?subject=HAPPY">email</a> with subject line "HAPPY".
COPYRIGHT_NOTICE

www_page_regex = Regexp.new '^.*\.html$'

Find.find ARGV[0] do |path|
  if www_page_regex.match(path) && File.file?(path) && !File.symlink?(path)
    source = File.new path
    dest_path = path + ".tmp"
    dest = File.new dest_path, "w"
    while line = source.gets
      if line =~ /^\s*&copy;\s+\d{4}(\s*-\s*\d{4})?\s+Glass and Print\s*$/
        dest.puts copyright_notice
      else
        dest.puts line
      end
    end
    source.close
    dest.close
    File.rename dest_path, path 
  end
end
