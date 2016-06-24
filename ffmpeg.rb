class FFmpeg
  attr_reader :bin
  def initialize
    @bin = `which ffmpeg`.chomp
  end

  def split(opts={  })
    start_time = opts.delete(:start)
    trim = opts.delete(:trim)
    input = opts.delete(:input)
    output_file = opts.delete(:output_file)
    run("#{bin} -i #{ input } -ss #{ start_time } -t #{ trim } -acodec copy #{ output_file }")
    output_file
  end

  def merge(opts={  })
    files = opts[:files].join("|")
    run("#{ bin } -i 'concat:#{ files }' -acodec copy #{ opts[:output_file] }")
  end

  private
  def run(cmd)
    puts cmd
    puts `#{cmd}`
  end
end
