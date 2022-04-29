# ~*~ encoding: utf-8 ~*~

require 'spec_helper'
dir = File.join(File.dirname(File.dirname(File.expand_path( __FILE__))), 'lib', 'java', 'jars')
jgit_jar = File.basename(Dir.glob(File.join(dir, "org.eclipse.jgit-*.jar")).first)
jgit_version = jgit_jar.split("org.eclipse.jgit-").last.split(".jar").first

UPLOAD_PACK_ADVERTISEMENT = "00da55ca9d4360c522d38bc73ef9cce81c2f72c413d5 HEAD\u0000 include-tag multi_ack_detailed multi_ack ofs-delta side-band side-band-64k thin-pack no-progress shallow agent=JGit/#{jgit_version} symref=HEAD:refs/heads/master\n0044f5771ead0e6d9a8d937bf5cabfa3678ee8944a92 refs/heads/alternative\n003f55ca9d4360c522d38bc73ef9cce81c2f72c413d5 refs/heads/master\n0000"

CORRECT_UPLOAD_REQUEST = "0067want f5771ead0e6d9a8d937bf5cabfa3678ee8944a92 multi_ack_detailed side-band-64k thin-pack ofs-delta\n00000009done\n" # Correct request for an object

CORRECT_UPLOAD_REQUEST_RESPONSE = "Counting objects: 26, done" # Server's expected response to CORRECT_UPLOAD_REQUEST

UPLOAD_REQUEST_INVALID_LENGTH = "0065want f5771ead0e6d9a8d937bf5cabfa3678ee8944a92 multi_ack_detailed side-band-64k thin-pack ofs-delta\n" # Request has invalid packet length header

UPLOAD_REQUEST_UNKNOWN_OBJECT = "0067want aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa multi_ack_detailed side-band-64k thin-pack ofs-delta\n00000009done\n" # Unknown object requested

UPLOAD_REQUEST_INVALID_OBJECT = "0067want aaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa multi_ack_detailed side-band-64k thin-pack ofs-delta\n00000009done\n" # Malformed object id requested

RECEIVE_PACK_ADVERTISEMENT = "00a4f5771ead0e6d9a8d937bf5cabfa3678ee8944a92 refs/heads/alternative\u0000 side-band-64k delete-refs report-status quiet atomic ofs-delta agent=JGit/#{jgit_version}\n003f55ca9d4360c522d38bc73ef9cce81c2f72c413d5 refs/heads/master\n0000"

CORRECT_RECEIVE_REQUEST = "00a20000000000000000000000000000000000000000 2f5cc213db87cb9719df0a094cab3a5bb458b361 refs/heads/test\x00 report-status side-band-64k agent=git/2.10.1.(Apple.Git-78)0000PACK\x00\x00\x00\x02\x00\x00\x00\x03\x98\x0Ex\x9C\x9D\xCCA\n\xC20\x10@\xD1}N\x91\xBDP23I\x9A\x80\x88\xA0{7^ \x99Li\xC16\xA5\xA6x}\xA5Gp\xF9\x16\xFF\xB7MD\xA3G+1Xk\xB2/\xE4\f\x93\xC5\f$\xB1\a\x840\x00\xFBLb2\xAB5m\xB24\xED\x1C\xA7X,y\xC3\x0E\xB1P\xC8\xDC\x93\f\x91Y\x020\x0E=\xB2\x05*N\xA5\xBD\x8Du\xD3\xF7\xF4I\xFA1KkU\x9F\xCB\x0F]=p]\xC7\xE9\xD5\xED{\xB7\xBC.\x1A\x1C\x90\xC3\x001\xE8\x93\x01c\x14\xD7y\x9EZ\x93\x7F{\xF5\x94w\xD3\xB7\xE3\xA2\xBE?\xADE\xA7\xFB\x01\x16O\xE5\xB9\xFA\xCD\xDE\x8E\x10iz\x91\xB6c&\x9F\x91\xC98\x06x\x9C\xEBb\xEAb\x9A\xF0M\x84\xF3\x8AVj\xE8\xF6\xF3\xA6\n\xCB\x82\x96\xB8\x14\xED\xFC\x12\xDE\xCA\x7F\x0F\x00\x9C=\f\x17\xF4\x01\x16B\x19\xCA\x17\x87\xBF,~\x869lw\xD1\xCC\x82O\xFC\xFC\x96x\x9C[k\xB7\xD3\x8E'\xC458D!4\xC0\xC51\xC4\x95k\x83\xAE<\x00FV\x06\x18\xB8Y\x92p\x19v\x9EV<A\\u\xFDTS\xEF\x85yb\x91"

CORRECT_RECEIVE_REQUEST_RESPONSE = "0025\u0002Resolving deltas:  50% (1/2)   \r0025\u0002Resolving deltas: 100% (2/2)   \r0022\u0002Resolving deltas: 100% (2/2)\n0028\u0002Updating references: 100% (1/1)   \r0025\u0002Updating references: 100% (1/1)\n002e\u0001000eunpack ok\n0017ok refs/heads/test\n00000000"

RECEIVE_REQUEST_INVALID_LENGTH = "00010000000000000000000000000000000000000000 0ed348defdb66282b02803a8836c5d5fc5b97d0d refs/heads/test\x00 report-status side-band-64k0000PACK\x00\x00\x00\x02\x00\x00\x00\x00\x02\x9D\b\x82;\xD8\xA8\xEA\xB5\x10\xADj\xC7\\\x82<\xFD>\xD3\x1E" # Request has invalid packet length header

RECEIVE_REQUEST_INVALID_OBJECT = "0082wa 0000000000000000000000000000000000000 0ed348defdb66282b02803a8836c5d5fc5b97d0d refs/heads/test\x00 report-status side-band-64k0000PACK\x00\x00\x00\x02\x00\x00\x00\x00\x02\x9D\b\x82;\xD8\xA8\xEA\xB5\x10\xADj\xC7\\\x82<\xFD>\xD3\x1E" # Client pushes a malformed object-id

describe RJGitUploadPack do
  before(:all) do
    @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
    @repo = Repo.new(@temp_repo_path)
  end
  
  before(:each) do
    @pack = RJGitUploadPack.new(@repo)
  end  
  
  it "has a reference to the repository's JGit-repository" do
    expect(@pack.jrepo).to eql @repo.jrepo
  end
  
  it "creates a JGit pack object on creation" do
    expect(@pack.jpack).to be_a org.eclipse.jgit.transport.UploadPack
  end
  
  it "advertises all references" do
    expect(@pack.advertise_refs).to eq UPLOAD_PACK_ADVERTISEMENT
  end
  
  it "returns the server-side response to a client's wants" do
    res, msg = @pack.process(CORRECT_UPLOAD_REQUEST)
    expect(res.read.include?(CORRECT_UPLOAD_REQUEST_RESPONSE)).to be true
    expect(msg).to be_nil
  end
  
  it "advertises its references when processing requests in bidirectional mode" do
    res, msg = @pack.process(CORRECT_UPLOAD_REQUEST)
    expect(res.read.include?(UPLOAD_PACK_ADVERTISEMENT.split("\n").first)).to be false
    @pack.bidirectional = true
    res, msg = @pack.process(CORRECT_UPLOAD_REQUEST)
    expect(res.read.include?(UPLOAD_PACK_ADVERTISEMENT.split("\n").first)).to be true
  end
  
  it "returns a bidirectional pipe when in bidirectional mode"
  
  it "returns nil and a Java IO error exception object when the client's request has the wrong length" do
    res, msg = @pack.process(UPLOAD_REQUEST_INVALID_LENGTH)
    expect(res).to be_nil
    expect(msg).to be_a java.io.IOException
  end
  
  it "returns nil and a JGit internal server error exception object when the client requests an unknown object" do
    res, msg = @pack.process(UPLOAD_REQUEST_UNKNOWN_OBJECT)
    expect(res).to be_nil
    expect(msg).to be_a org.eclipse.jgit.transport.UploadPackInternalServerErrorException
  end
  
  it "returns nil and a JGit invalid object exception object when the client requests an invalid object id" do
    res, msg = @pack.process(UPLOAD_REQUEST_INVALID_OBJECT)
    expect(res).to be_nil
    expect(msg).to be_a org.eclipse.jgit.transport.UploadPackInternalServerErrorException
  end
  
  after(:all) do
    remove_temp_repo(@temp_repo_path)
    @repo = nil
  end
end

describe RJGitReceivePack do
  before(:all) do
    @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
    @repo = Repo.new(@temp_repo_path)
  end
  
  before(:each) do
    @pack = RJGitReceivePack.new(@repo)
  end
  
  it "has a reference to the repository's JGit-repository" do
    expect(@pack.jrepo).to eql @repo.jrepo
  end
  
  it "creates a JGit pack object on creation" do
    expect(@pack.jpack).to be_a org.eclipse.jgit.transport.ReceivePack
  end
  
  it "advertises all references" do
    expect(@pack.advertise_refs).to eq RECEIVE_PACK_ADVERTISEMENT
  end
  
  it "responds correctly to a client's push request" do
    res, msg = @pack.process(CORRECT_RECEIVE_REQUEST)
    expect(res.read).to eql CORRECT_RECEIVE_REQUEST_RESPONSE
    expect(msg).to be_nil
  end
  
  it "advertises its references when processing requests in bidirectional mode" do
    res, msg = @pack.process(CORRECT_RECEIVE_REQUEST)
    expect(res.read.include?(RECEIVE_PACK_ADVERTISEMENT.split("\n").first)).to be false
    @pack.bidirectional = true
    res, msg = @pack.process(CORRECT_RECEIVE_REQUEST)
    expect(res.read.include?(RECEIVE_PACK_ADVERTISEMENT.split("\n").first)).to be true
  end
  
  it "returns a bidirectional pipe when in bidirectional mode"
  
  it "returns nil and a Java IO error exception object when the client's request has the wrong length" do
    res, msg = @pack.process(RECEIVE_REQUEST_INVALID_LENGTH)
    expect(res).to be_nil
    expect(msg).to be_a java.io.IOException
  end
  
  it "returns nil and a JGit invalid object exception object if the client requests an invalid object id" do
    res, msg = @pack.process(RECEIVE_REQUEST_INVALID_OBJECT)
    expect(res).to be_nil
    expect(msg).to be_a org.eclipse.jgit.errors.PackProtocolException
  end
  
  after(:all) do
    remove_temp_repo(@temp_repo_path)
    @repo = nil
  end
end