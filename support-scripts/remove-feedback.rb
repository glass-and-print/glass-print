require 'find'

cmd = File.basename $0
usage = <<USAGE_MESSAGE
usage: #{cmd} top-level-directory
         top-level-directory -- the directory which will be recursively
                                searched for html files which will be
                                scanned for the feedback widget which if
                                found will be removed
USAGE_MESSAGE

if ARGV.size != 1
  print usage
  exit 1
end

www_page_regex = Regexp.new '^.*\.html$'
feedback_css_regex = Regexp.new '^.*import.*url.*getsatisfaction\.com.*feedback\.css.*$'
script_close_tag_regex = Regexp.new '^\s*</script>\s*$'

Find.find ARGV[0] do |path|
  if www_page_regex.match(path) && File.file?(path) && !File.symlink?(path)
    source = File.new path
    dest_path = path + ".tmp"
    dest = File.new dest_path, "w"
    in_feedback_block = false;
    while line = source.gets
      if feedback_css_regex.match line
        in_feedback_block = true
      elsif in_feedback_block && (script_close_tag_regex.match line)
        in_feedback_block = false
      else
        if not in_feedback_block
          dest.puts line
        end
      end
    end
    source.close
    dest.close
    File.rename dest_path, path 
  end
end
