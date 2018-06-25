# @see https://developers.google.com/speed/webp/docs/riff_container
# @see https://tools.ietf.org/html/rfc6386
# @see https://chromium.googlesource.com/webm/libwebp/+/master/doc/webp-lossless-bitstream-spec.txt
class FormatParser::WEBPParser
  include FormatParser::IOUtils
  include FormatParser::EXIFParser

  # VP8 Data Format and Decoding Guide
  # @see https://tools.ietf.org/html/rfc6386
  LOSSY    = 'VP8'
  LOSSLESS = 'VP8L'
  EXTENDED = 'VP8X'

  attr_accessor :width_px
  attr_accessor :height_px
  attr_accessor :has_transparency

  def call(io)
    @buffer = FormatParser::IOConstraint.new(io)
    scan
  end

  private

  def scan
    return unless valid_webp?

    read_vp8_data(vp8_format)

    FormatParser::Image.new(
      format: :webp,
      width_px: width_px,
      height_px: height_px,
      has_transparency: has_transparency
    )
  end

  # Returns false unless the RIFF Header matches the specification
  # @see https://developers.google.com/speed/webp/docs/riff_container
  # @return [Boolean]
  def valid_webp?
    webp_file_header = safe_read(@buffer, 12).unpack('A4lA4')

    return false unless webp_file_header[0] == 'RIFF'
    return false unless webp_file_header[1] > 0
    return false unless webp_file_header[2] == 'WEBP'

    true
  end

  # Read the next four characters to determine file format
  # * VP8  - Simple File Format Lossy
  # * VP8L - Simple File Format Lossless
  # * VP8X - Extended File Format
  # @return [String] one of the following: 'VP8 ', 'VP8L', or 'VP8X'
  def vp8_format
    @vp8_format ||= safe_read(@buffer, 4).unpack('A4')[0]
  end

  def read_vp8_data(format)
    case format.strip
    when LOSSY
      read_simple_file_format_lossy
    when LOSSLESS
      read_simple_file_format_lossless
    when EXTENDED
      read_extended_file_format
    end
  end

  def read_simple_file_format_lossy
    vp8_header(10)
    @width_px, @height_px = safe_read(@buffer, 4).unpack('vv')

    # lossy format does not support an alpha channel
    @has_transparency = false
  end

  def read_simple_file_format_lossless
    vp8_header(5)
    num = safe_read(@buffer, 4).unpack('V')[0]
    @width_px  = (num & 0x3fff) + 1
    @height_px = (num >> 14 & 0x3fff) + 1
  end

  def read_extended_file_format
    header = vp8_header(1)
    safe_skip(@buffer, 7)

    w16, w8, h16, h8 = safe_read(@buffer, 6).unpack('vCvC')
    @width_px  = (w16 | w8 << 16) + 1
    @height_px = (h16 | h8 << 16) + 1
  end

  # TODO: determine if the header needs to be read or skipped
  # e.g. for VP8L safe_read(@buffer, 5).unpack('lc') returns file size and byte signature
  # but the other formats (VP8 and VP8X) are not as clear in the specs as to what this header is returning
  def vp8_header(n)
    # safe_skip(@buffer, n) # or
    safe_read(@buffer, n)
  end

  FormatParser.register_parser self, natures: :image, formats: :webp
end