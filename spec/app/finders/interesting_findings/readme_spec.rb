require 'spec_helper'

describe WPScan::Finders::InterestingFindings::Readme do
  subject(:finder) { described_class.new(target) }
  let(:target)     { WPScan::Target.new(url) }
  let(:url)        { 'http://ex.lo/' }
  let(:fixtures)   { File.join(FINDERS_FIXTURES, 'interesting_findings', 'readme') }

  describe '#aggressive' do
    before do
      expect(target).to receive(:sub_dir).at_least(1).and_return(false)

      finder.potential_files.each do |file|
        stub_request(:get, target.url(file)).to_return(status: 404)
      end
    end

    context 'when no file present' do
      its(:aggressive) { should be_nil }
    end

    # TODO: case when multiple files are present ? (should return only the first one found)
    context 'when a file exists' do
      let(:file)   { finder.potential_files.sample }
      let(:readme) { File.read(File.join(fixtures, 'readme-3.9.2.html')) }

      before { stub_request(:get, target.url(file)).to_return(body: readme) }

      it 'returns the expected InterestingFinding' do
        expected = WPScan::Readme.new(
          target.url(file),
          confidence: 100,
          found_by: described_class::DIRECT_ACCESS
        )

        expect(finder.aggressive).to eql expected
      end
    end
  end

  describe '#potential_files' do
    it 'does not contain duplicates' do
      expect(finder.potential_files.flatten.uniq.length).to eql finder.potential_files.length
    end
  end
end
