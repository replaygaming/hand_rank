require "mkmf"
$CFLAGS+=" -O3"
create_makefile "hand_rank/hand_rank"
puts "Done making file"


puts "Unzipping zip data"
curr_dir = File.dirname(__FILE__)
zip_dir  = File.join(curr_dir, "../../lib/hand_rank/")
system("unzip", File.join(zip_dir, "ranks.data.zip"), "-d", zip_dir)
system('rm', File.join(zip_dir, "ranks.data.zip"))