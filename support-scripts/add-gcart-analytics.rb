require 'find'

cmd = File.basename $0
usage = <<USAGE_MESSAGE
usage: #{cmd} top-level-directory
         top-level-directory -- the directory which will be recursively
                                searched for html sources that will in turn
                                be searched for google cart code where the
                                analytics account link will be added.
USAGE_MESSAGE

if ARGV.size != 1
  print usage
  exit 1
end

analytics_aid = <<ANALYTICS_AID_PARAM
            aid='UA-2338100-1'
ANALYTICS_AID_PARAM

www_page_regex = Regexp.new '^.*\.html$'

Find.find ARGV[0] do |path|
  if www_page_regex.match(path) && File.file?(path) && !File.symlink?(path)
    source = File.new path
    dest_path = path + ".tmp"
    dest = File.new dest_path, "w"
    while line = source.gets
      dest.puts line
      if line =~ /.*src=\'https:\/\/checkout.google.com\/seller\/gsc\/v2\/cart.js\?mid=411692329378924\'.*/
        dest.puts analytics_aid
      end
    end
    source.close
    dest.close
    File.rename dest_path, path 
  end
end
