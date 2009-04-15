require 'find'

cmd = File.basename $0
usage = <<USAGE_MESSAGE
usage: #{cmd} top-level-directory
         top-level-directory -- the directory which will be recursively
                                searched for html files to which the
                                feedback widget will be added
USAGE_MESSAGE

if ARGV.size != 1
  print usage
  exit 1
end

feedback = <<FEEDBACK_WIDGET_END
    <style type='text/css'>@import url('http://s3.amazonaws.com/getsatisfaction.com/feedback/feedback.css');</style>
    <script src='http://s3.amazonaws.com/getsatisfaction.com/feedback/feedback.js' type='text/javascript'></script>
    <script type=text/javascript charset=utf-8>
      var tab_options = {}
      tab_options.placement = "right";
      tab_options.color = "#BFBD00";
      GSFN.feedback('http://getsatisfaction.com/glass-print/feedback/topics/new?display=overlay&style=question', tab_options);
    </script>

  </body>
FEEDBACK_WIDGET_END

www_page_regex = Regexp.new '^.*\.html$'
body_close_tag_regex = Regexp.new '^\s*</body>\s*$'

Find.find ARGV[0] do |path|
  if www_page_regex.match path && File.file?(path) && !File.symlink?(path)
    source = File.new path
    dest_path = path + ".tmp"
    dest = File.new dest_path, "w"
    while line = source.gets
      if body_close_tag_regex.match line
        dest.puts feedback
      else
        dest.puts line
      end
    end
    source.close
    dest.close
    File.rename dest_path, path 
  end
end
