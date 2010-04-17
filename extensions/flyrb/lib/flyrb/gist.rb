require 'flyrb'
require 'open-uri'
require 'net/http'

Flyrb.equip(:clipboard)

module Flyrb
  module Gist
    def gist(content = nil, filename = nil)
      content  ||= Clipboard.read if Clipboard.available?
      filename ||= "fly.rb"

      url = URI.parse('http://gist.github.com/gists')
      req = Net::HTTP.post_form(url, data(filename, "rb", content))
      
      gist_url = req['Location']
      Clipboard.write(gist_url) if Clipboard.available?
      open(gist_url)
    end
    
    private
      def open(url)
        case Platform::IMPL
        when :macosx
          Kernel.system("open #{url}")
        when :mswin
          pastie_url = url.chop if url[-1].chr == "\000"
          Kernel.system("start #{url}")
        end
      end
      
      def data(filename, ext, content)
        {
          :'file_ext[gistfile1]'      => ext,
          :'file_name[gistfile1]'     => filename,
          :'file_contents[gistfile1]' => content
        }.merge(auth)
      end
      
      def auth
        user  = `git config --global github.user`.strip
        token = `git config --global github.token`.strip

        user.empty? ? {} : { :login => user, :token => token }
      end
  end
end

class Object
  include Flyrb::Gist
end if Object.const_defined? :IRB
