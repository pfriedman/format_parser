require 'spec_helper'

describe FormatParser::WEBPParser do
  describe 'is able to parse all the WEBP examples' do
    Dir.glob(fixtures_dir + '/*.webp').each do |webp_path|
      it "is able to parse #{File.basename(webp_path)}" do
        parsed = subject.call(File.open(webp_path, 'rb'))
        expect(parsed).not_to be_nil
        expect(parsed.nature).to eq(:image)
        expect(parsed.format).to eq(:webp)
      end
    end

    it 'is able to parse a lossy WEBP file (VP8)' do
      parsed = subject.call(File.open(fixtures_dir + '/WEBP/webp_sample.webp', 'rb'))
      expect(parsed).not_to be_nil
      expect(parsed.nature).to eq(:image)
      expect(parsed.format).to eq(:webp)
      expect(parsed.width_px).to eq(1024)
      expect(parsed.height_px).to eq(772)
      expect(parsed.display_width_px).to eq(1024)
      expect(parsed.display_height_px).to eq(772)
      expect(parsed.has_transparency).to be false
    end

    it 'is able to parse a lossless WEBP file (VP8L)' do
      parsed = subject.call(File.open(fixtures_dir + '/WEBP/lossless.webp', 'rb'))
      expect(parsed).not_to be_nil
      expect(parsed.nature).to eq(:image)
      expect(parsed.format).to eq(:webp)
      expect(parsed.width_px).to eq(400)
      expect(parsed.height_px).to eq(301)
      expect(parsed.display_width_px).to eq(400)
      expect(parsed.display_height_px).to eq(301)
    end

    it 'is able to parse an alpha WEBP file (VP8X)' do
      parsed = subject.call(File.open(fixtures_dir + '/WEBP/alpha.webp', 'rb'))
      expect(parsed).not_to be_nil
      expect(parsed.nature).to eq(:image)
      expect(parsed.format).to eq(:webp)
      expect(parsed.width_px).to eq(400)
      expect(parsed.height_px).to eq(301)
      expect(parsed.display_width_px).to eq(400)
      expect(parsed.display_height_px).to eq(301)
    end

    it 'is able to parse an animated WEBP file (VP8X)' do
      parsed = subject.call(File.open(fixtures_dir + '/WEBP/animated.webp', 'rb'))
      expect(parsed).not_to be_nil
      expect(parsed.nature).to eq(:image)
      expect(parsed.format).to eq(:webp)
      expect(parsed.width_px).to eq(400)
      expect(parsed.height_px).to eq(400)
      expect(parsed.display_width_px).to eq(400)
      expect(parsed.display_height_px).to eq(400)
    end

  end

  describe 'returns nil for non .webp files' do
    Dir.glob(fixtures_dir + '/*.jpg').each do |jpg_path|
      it "is not able to parse #{File.basename(jpg_path)}" do
        parsed = subject.call(File.open(jpg_path, 'rb'))
        expect(parsed).to be_nil
      end
    end
  end
end
