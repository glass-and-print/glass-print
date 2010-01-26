require 'find'

cmd = File.basename $0
usage = <<USAGE_MESSAGE
usage: #{cmd} top-level-directory
         top-level-directory -- the directory which will be recursively
                                searched for html files to which the
                                social links will be added
USAGE_MESSAGE

if ARGV.size != 1
  print usage
  exit 1
end

socials = <<SOCIAL_LINKS_END
    <div class="social-div">
      <div>
        <a href="http://twitter.com/GlassPrint">
          <img border="0" alt="follow us on twitter" src="/images/twitter.png" />
        </a>
      </div>
      <div>
        <a href="http://www.facebook.com/pages/Glass-Print/276281096859">
          <img border="0" alt="fan us on facebook" src="/images/facebook.png" />
        </a>
      </div>
    </div>

SOCIAL_LINKS_END

www_page_regex = Regexp.new '^.*\.html$'

Find.find ARGV[0] do |path|
  if www_page_regex.match(path) && File.file?(path) && !File.symlink?(path)
    source = File.new path
    dest_path = path + ".tmp"
    dest = File.new dest_path, "w"
    while line = source.gets
      if line =~ /.*style.*type.*text.*css.*import.*url.*http:\/\/s3\.amazonaws\.com\/getsatisfaction\.com\/feedback\/feedback\.css.*/
        dest.puts socials
      end
      dest.puts line
    end
    source.close
    dest.close
    File.rename dest_path, path 
  end
end
