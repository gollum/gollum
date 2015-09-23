module RJGit

  import "org.eclipse.jgit.transport.ReceivePack"
  import "org.eclipse.jgit.transport.UploadPack"
  import "org.eclipse.jgit.transport.PacketLineOut"
  import "org.eclipse.jgit.transport.RefAdvertiser$PacketLineOutRefAdvertiser"
  import "java.io.ByteArrayInputStream"
  import "java.io.ByteArrayOutputStream"

  class RJGitPack
    attr_accessor :jpack, :jrepo, :bidirectional
    
    def initialize(repository, bidirectional = false)
      @jrepo = RJGit.repository_type(repository)
      @bidirectional = bidirectional
    end
  
    def advertise_refs
      out_stream = ByteArrayOutputStream.new
      pck_out = PacketLineOut.new(out_stream)
      advertiser = PacketLineOutRefAdvertiser.new(pck_out)
      @jpack.sendAdvertisedRefs(advertiser)
      return out_stream.to_string
    end

    def process(client_msg)
      input, output = init_buffers(client_msg)
      @jpack.set_bi_directional_pipe(@bidirectional)
      begin
        @jpack.send(@action, input, output, nil)
      rescue Java::OrgEclipseJgitErrors::InvalidObjectIdException, Java::OrgEclipseJgitTransport::UploadPackInternalServerErrorException, Java::JavaIo::IOException => e
        return nil, e
      end
      return ByteArrayInputStream.new(output.to_byte_array).to_io, nil
    end

    private

    def init_buffers(client_msg)
      return ByteArrayInputStream.new(client_msg.to_java_bytes), ByteArrayOutputStream.new
    end  

  end

  class RJGitReceivePack < RJGitPack
   
    def initialize(repository, bidirectional = false)
      super
      @jpack = ReceivePack.new(@jrepo)
      @action = :receive
    end
  
  end

  class RJGitUploadPack < RJGitPack
  
    def initialize(repository, bidirectional = false)
      super
      @jpack = UploadPack.new(@jrepo)
      @action = :upload
    end
  
  end

end
