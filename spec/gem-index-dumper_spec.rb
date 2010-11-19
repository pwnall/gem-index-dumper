require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'GemIndexDumper' do
  describe 'gem_digest' do
    let(:gem_info) { ['activerecord', Gem::Version.new('3.0.0'), 'ruby'] }
    it 'should compute the digest correctly' do
      GemIndexDumper.gem_digest(gem_info).should ==
          'b4025f8396c9d784b26fa22c0dbf27e80a513469'
    end
  end
  
  describe 'all_remote_gems' do
    before :all do
      @all = GemIndexDumper.all_remote_gems
    end
    
    it 'should include all versions for all gems' do
      @all.should include(['activerecord', Gem::Version.new('3.0.0'), 'ruby'])
      @all.should include(['activerecord', Gem::Version.new('3.0.3'), 'ruby'])
    end
  end
  
  describe 'dump_remote_gems' do
    before do
      GemIndexDumper.should_receive(:all_remote_gems).and_return([
        ['activerecord', Gem::Version.new('3.0.2'), 'ruby'],
        ['activerecord', Gem::Version.new('3.0.3'), 'ruby'],
        ['activerecord', Gem::Version.new('3.0.0'), 'ruby'],
        ['activerecord', Gem::Version.new('3.0.1'), 'ruby'],
        ['actionpack', Gem::Version.new('3.0.1'), 'ruby'],
        ['actionpack', Gem::Version.new('3.0.0'), 'ruby'],
        ['actionpack', Gem::Version.new('3.0.2'), 'ruby'],
        ['actionpack', Gem::Version.new('2.3.5'), 'ruby']
      ])
    end
    
    it 'without an argument should return all gems sorted' do
      GemIndexDumper.dump_remote_gems.should == <<END
actionpack / ruby   v2.3.5
actionpack / ruby   v3.0.0
actionpack / ruby   v3.0.1
actionpack / ruby   v3.0.2
activerecord / ruby   v3.0.0
activerecord / ruby   v3.0.1
activerecord / ruby   v3.0.2
activerecord / ruby   v3.0.3
END
    end
  end

  describe 'dump_gem_digests' do
    before do
      GemIndexDumper.should_receive(:all_remote_gems).and_return([
        ['activerecord', Gem::Version.new('3.0.2'), 'ruby'],
        ['activerecord', Gem::Version.new('3.0.3'), 'ruby'],
        ['activerecord', Gem::Version.new('3.0.0'), 'ruby'],
        ['activerecord', Gem::Version.new('3.0.1'), 'ruby'],
        ['actionpack', Gem::Version.new('3.0.1'), 'ruby'],
        ['actionpack', Gem::Version.new('3.0.0'), 'ruby'],
        ['actionpack', Gem::Version.new('3.0.2'), 'ruby'],
        ['actionpack', Gem::Version.new('2.3.5'), 'ruby']
      ])
      GemIndexDumper.stub!(:gem_digest).
          with(['actionpack', Gem::Version.new('3.0.2'), 'ruby']).
          and_return('0011001100110011001100110011001100110011')
      GemIndexDumper.stub!(:gem_digest).
          with(['activerecord', Gem::Version.new('3.0.3'), 'ruby']).
          and_return('2233223322332233223322332233223322332233')
      GemIndexDumper.stub!(:gem_digest).
          with(['activerecord', Gem::Version.new('3.0.2'), 'ruby']).
          and_return('4455445544554455445544554455445544554455')
    end

    it 'without a version pattern should return the latest gem versions' do
      GemIndexDumper.dump_gem_digests(/.*/).should == <<END
actionpack / ruby   v3.0.2   = 0011001100110011001100110011001100110011
activerecord / ruby   v3.0.3   = 2233223322332233223322332233223322332233
END
    end
    
    it 'with a version pattern should return specific versions' do
      GemIndexDumper.dump_gem_digests(/.*/, /2$/).should == <<END
actionpack / ruby   v3.0.2   = 0011001100110011001100110011001100110011
activerecord / ruby   v3.0.2   = 4455445544554455445544554455445544554455
END
    end
    
    it 'with a name pattern should return the latest version' do
      GemIndexDumper.dump_gem_digests(/pack/).should == <<END
actionpack / ruby   v3.0.2   = 0011001100110011001100110011001100110011
END
    end
    
    it 'with name and version patterns should return that version' do
      GemIndexDumper.dump_gem_digests(/record/, /2$/).should == <<END
activerecord / ruby   v3.0.2   = 4455445544554455445544554455445544554455
END
    end
  end
end
