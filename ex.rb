require "./interval_generator"
require "./ffmpeg"
require "fileutils"
require "pry-byebug"
class Excercise
  attr_reader :input_file, :merged_dir, :clip_dir, :final_dir

  SAFE_RANGE_PADDING = 3
  NOTES = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
  MIN_NOTE = 1
  MAX_NOTE = 44


  def initialize
    @generator = IntervalGenerator.new(MIN_NOTE, MAX_NOTE)
    @ffmpeg = FFmpeg.new
    @finished_clips = {  }
    @data_dir = "data/#{self.class}"
    @merged_dir = "#{@data_dir}/merged"
    @clip_dir = "#{@data_dir}/clips"
    @final_dir = "#{@data_dir}/final"
    FileUtils.mkdir_p(@merged_dir) unless File.exists?(@merged_dir)
    FileUtils.mkdir_p(@clip_dir) unless File.exists?(@clip_dir)
    FileUtils.mkdir_p(@final_dir) unless File.exists?(@final_dir)
  end

  def create_clips
    final_files = []
    @generator.each_interval(@interval) do |ranges|
      ranges.each do |range|
        unless @finished_clips[range]
          output_file = split_file_name(range)
          unless File.exists?(output_file)
            start = (range.min - 1) * @interval_length
            @ffmpeg.split(start: start,
                          trim: @interval_length,
                          input: input_file,
                          output_file: output_file)
          end
          @finished_clips[range] = output_file
        end
      end
      final_file = merged_file_name(ranges)
      unless File.exists?(final_file)
        @ffmpeg.merge(files: ranges.map{|r| split_file_name(r) }, output_file: final_file)
      end
    end
    @generator.each_interval(@interval) do |ranges|
      final_files << link_final(ranges.first.min, ranges.last.max)
    end
    final_files
  end

  def merged_file_name(ranges)
    File.join(@merged_dir, file_name((ranges.first.min..ranges.last.max)))
  end

  def split_file_name(range)
    File.join(@clip_dir, file_name(range))
  end

  def final_file_name(range, extra = nil)
    File.join(@final_dir, file_name(range, extra))
  end

  private
  def link_final(start, finish)
    padded_range = (start - SAFE_RANGE_PADDING)..(finish + SAFE_RANGE_PADDING)
    actual = merged_file_name([padded_range])
    link = final_file_name(start..finish, "_aka_#{range_name(padded_range)}")
    return if !File.exist?(actual) || File.exists?(link)
    FileUtils.ln(actual, link)
    link
  end

  def range_name(range)
    "#{number_to_note(range.min)}-#{number_to_note(range.max)}"
  end
  def file_name(range, extra = nil)
    "#{range_name(range)}#{extra}.mp3"
  end

  def number_to_note(n)
    n = MIN_NOTE if n < MIN_NOTE
    n = MAX_NOTE if n > MAX_NOTE
    letter = NOTES[(n % NOTES.count) - 1]
    # new octaves start on C so shift over 8 from A to C
    octave = ((n + 8) / NOTES.count)+2
    "#{letter}#{octave}"
  end

  # wip
  # def note_to_number(note)
  #   NOTES.index(note)
  # end
end
