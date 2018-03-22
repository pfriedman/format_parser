require 'ks'

class FormatParser::FLACParser

  MAGIC_BYTES = 4
  BLOCK_HEADER_BYTES = 4

  def call(io)
    magic_bytes = io.read(MAGIC_BYTES)

    return unless magic_bytes == 'fLaC'

    # Skip info we don't need
    io.seek(MAGIC_BYTES + BLOCK_HEADER_BYTES)

    minimum_block_size = io.read(2).unpack("B*")[0].to_i(2)
    maximum_block_size = io.read(2).unpack("B*")[0].to_i(2)
    minimum_frame_size = io.read(3).unpack("B*")[0].to_i(2)
    maximum_frame_size = io.read(3).unpack("B*")[0].to_i(2)

    audio_info = io.read(8).unpack("B*")[0]
    sample_rate = audio_info[0..19].to_i(2)
    num_channels = audio_info[20..22].to_i(2) + 1
    bits_per_sample = audio_info[23..27].to_i(2) + 1
    total_samples = audio_info[28..63].to_i(2)

    FormatParser::Audio.new(
      format: :flac,
      num_audio_channels: num_channels,
      audio_sample_rate_hz: sample_rate,
      media_duration_seconds: total_samples.to_f / sample_rate,
      intrinsics: {
        bits_per_sample: bits_per_sample,
        minimum_frame_size: minimum_frame_size,
        maximum_frame_size: maximum_frame_size,
        minimum_block_size: minimum_block_size,
        maximum_block_size: maximum_block_size,
      }
    )
  end

  FormatParser.register_parser self, natures: :audio, formats: :flac
end
