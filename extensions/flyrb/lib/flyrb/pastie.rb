# automate creating pasties
%w{platform net/http flyrb}.each {|lib| require lib}
Flyrb.equip(:clipboard)

module Flyrb
  module Pastie
    def pastie(stuff_to_paste = nil)
      stuff_to_paste ||= Clipboard.read if Clipboard.available?
      # return nil unless stuff_to_paste

      pastie_url = Net::HTTP.post_form(URI.parse("http://pastie.caboo.se/pastes/create"),
                                       {"paste_parser" => "ruby",
                                        "paste[authorization]" => "burger",
                                        "paste[body]" => stuff_to_paste}).body.match(/href="([^\"]+)"/)[1]

      Clipboard.write(pastie_url) if Clipboard.available?
      
      case Platform::IMPL
      when :macosx
        Kernel.system("open #{pastie_url}")
      when :mswin
        pastie_url = pastie_url.chop if pastie_url[-1].chr == "\000"
        Kernel.system("start #{pastie_url}")
      end

      return pastie_url
    end
    alias :pst :pastie
  end
end

class Object
  include Flyrb::Pastie
end if Object.const_defined? :IRB
