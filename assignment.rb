require "./ex1"
require "./ex2"
require "./ex3"
require "./ex4"
require "./ex5"
require "./ex6"

class Assignment
  def initialize
    @excercises = [
      Excercise1.new,
      Excercise2.new,
      Excercise3.new,
      Excercise4.new,
      Excercise5.new,
      Excercise6.new
    ]
    @intros = [
      "data/intros/1.mp3",
      "data/intros/2.mp3",
      "data/intros/3.mp3",
      "data/intros/4.mp3",
      "data/intros/5.mp3",
      "data/intros/6.mp3",
    ]
    @ffmpeg = FFmpeg.new
    @output_dir = "data/final"
    unless File.exists?(@output_dir)
      FileUtils.mkdir_p(@output_dir)
    end
  end

  def create_clips
    @excercises.each do |ex|
      ex.create_clips
    end

    Dir.glob("#{@excercises.first.final_dir}/*.mp3").each do |f|
      write_final(f)
    end
  end

  def write_final(f)
    file_name = File.basename(f)
    output_file = File.join(@output_dir, file_name)
    unless File.exists?(output_file)
      excercise_files = @excercises.select{|ex|
        File.exist?(File.join(ex.final_dir, file_name))
      }.map{|ex|
        File.join(ex.final_dir, file_name)
      }
      @ffmpeg.merge(
        files: @intros.zip(excercise_files),
        output_file: output_file
      )
    end
  end
end

Assignment.new.create_clips


