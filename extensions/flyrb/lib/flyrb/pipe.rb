# This extension adds a UNIX-style pipe to strings
#
# Synopsis:
#
# >> puts "Flyrb is better than alfalfa" | "cowsay"
#  ____________________________________
# < Flyrb is better than alfalfa >
#  ------------------------------------
#         \   ^__^
#          \  (oo)\_______
#             (__)\       )\/\
#                 ||----w |
#                 ||     ||
# => nil
#
class String
  def |(cmd)
    IO.popen(cmd, 'r+') do |pipe|
      pipe.write(self)
      pipe.close_write
      pipe.read
    end
  end
end
