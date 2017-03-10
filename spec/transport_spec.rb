# ~*~ encoding: utf-8 ~*~

require 'spec_helper'
dir = File.join(File.dirname(File.dirname(File.expand_path( __FILE__))), 'lib', 'java', 'jars')
jgit_jar = File.basename(Dir.glob(File.join(dir, "org.eclipse.jgit-*.jar")).first)
jgit_version = jgit_jar.split("org.eclipse.jgit-").last.split(".jar").first

UPLOAD_PACK_ADVERTISEMENT = "00da55ca9d4360c522d38bc73ef9cce81c2f72c413d5 HEAD\u0000 include-tag multi_ack_detailed multi_ack ofs-delta side-band side-band-64k thin-pack no-progress shallow agent=JGit/4.6.1.201703071140-r symref=HEAD:refs/heads/master\n0044f5771ead0e6d9a8d937bf5cabfa3678ee8944a92 refs/heads/alternative\n003f55ca9d4360c522d38bc73ef9cce81c2f72c413d5 refs/heads/master\n0000"

CORRECT_UPLOAD_REQUEST = "0067want f5771ead0e6d9a8d937bf5cabfa3678ee8944a92 multi_ack_detailed side-band-64k thin-pack ofs-delta\n00000009done\n" # Correct request for an object

CORRECT_UPLOAD_REQUEST_RESPONSE = "Counting objects: 26, done" # Server's expected response to CORRECT_UPLOAD_REQUEST

UPLOAD_REQUEST_INVALID_LENGTH = "0065want f5771ead0e6d9a8d937bf5cabfa3678ee8944a92 multi_ack_detailed side-band-64k thin-pack ofs-delta\n" # Request has invalid packet length header

UPLOAD_REQUEST_UNKNOWN_OBJECT = "0067want aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa multi_ack_detailed side-band-64k thin-pack ofs-delta\n00000009done\n" # Unknown object requested

UPLOAD_REQUEST_INVALID_OBJECT = "0067want aaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa multi_ack_detailed side-band-64k thin-pack ofs-delta\n00000009done\n" # Malformed object id requested

RECEIVE_PACK_ADVERTISEMENT = "009df5771ead0e6d9a8d937bf5cabfa3678ee8944a92 refs/heads/alternative\u0000 side-band-64k delete-refs report-status quiet ofs-delta agent=JGit/4.6.1.201703071140-r\n003f55ca9d4360c522d38bc73ef9cce81c2f72c413d5 refs/heads/master\n0000"

CORRECT_RECEIVE_REQUEST = "00820000000000000000000000000000000000000000 0ed348defdb66282b02803a8836c5d5fc5b97d0d refs/heads/test\x00 report-status side-band-64k0000PACK\x00\x00\x00\x02\x00\x00\x00\x00\x02\x9D\b\x82;\xD8\xA8\xEA\xB5\x10\xADj\xC7\\\x82<\xFD>\xD3\x1E" # Client pushes a valid object-id

CORRECT_RECEIVE_REQUEST_RESPONSE = "0028\u0002Updating references: 100% (1/1)   \r0025\u0002Updating references: 100% (1/1)\n002e\u0001000eunpack ok\n0017ok refs/heads/test\n00000000" # Server's expected response to CORRECT_RECEIVE_REQUEST

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