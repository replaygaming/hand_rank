require "mkmf"
$CFLAGS+=" -O3"
create_makefile "hand_rank/hand_rank"

require 'pathname'

data_file = Pathname.new(File.expand_path('..', __dir__)).join "../lib/hand_rank/ranks.data"

begin
  %x[gunzip -f #{data_file}.gz] unless File.exists?(data_file)
rescue => e
  $stderr.puts <<-EOF
  Something has gone wrong with copying ranks.data file from

  #{data_file}

  to the gem folder. Please unpack it manually to this path
  EOF
end
