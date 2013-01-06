module RJGit

  java_import "org.eclipse.jgit.transport.ReceivePack"
  java_import "org.eclipse.jgit.transport.UploadPack"
  java_import "org.eclipse.jgit.transport.PacketLineOut"
  java_import "org.eclipse.jgit.transport.RefAdvertiser$PacketLineOutRefAdvertiser"
  java_import "java.io.ByteArrayInputStream"
  java_import "java.io.ByteArrayOutputStream"

  class RJGitPack
    attr_accessor :jpack, :jrepo, :bidirectional
    
    def initialize(repository, bidirectional = false)
      @jrepo = RJGit.repository_type(repository)
      @bidirectional = bidirectional
    end

    def init_buffers(client_msg)
      return ByteArrayInputStream.new(client_msg.to_java_bytes), ByteArrayOutputStream.new
    end    
  
    def advertise_refs
      out_stream = ByteArrayOutputStream.new
      pck_out = PacketLineOut.new(out_stream)
      advertiser = PacketLineOutRefAdvertiser.new(pck_out)
      @jpack.sendAdvertisedRefs(advertiser)
      return out_stream.to_string
    end
  end

  class RJGitReceivePack < RJGitPack
   
    def initialize(repository, bidirectional = false)
      super
      @jpack = ReceivePack.new(@jrepo)
    end
  
    def process(client_msg)
      self.receive(client_msg)
    end
  
    def receive(client_msg)
      in_stream, out_stream = init_buffers(client_msg)
      @jpack.set_bi_directional_pipe(@bidirectional)
      begin
        @jpack.receive(in_stream, out_stream, nil)
      rescue Java::OrgEclipseJgitErrors::InvalidObjectIdException, Java::JavaIo::IOException => e
        return nil, e
      end
      return ByteArrayInputStream.new(out_stream.to_byte_array).to_io, nil
  end
  
end

  class RJGitUploadPack < RJGitPack
  
    def initialize(repository, bidirectional = false)
      super
      @jpack = UploadPack.new(@jrepo)
    end
  
    def process(client_msg)
      self.upload(client_msg)
    end
  
    def upload(client_msg)
      in_stream, out_stream = init_buffers(client_msg)
      @jpack.set_bi_directional_pipe(@bidirectional)
      begin
        @jpack.upload(in_stream, out_stream, nil)
      rescue Java::OrgEclipseJgitErrors::InvalidObjectIdException, Java::OrgEclipseJgitTransport::UploadPackInternalServerErrorException, Java::JavaIo::IOException => e
        return nil, e
      end
      return ByteArrayInputStream.new(out_stream.to_byte_array).to_io, nil
    end
  
  end

end
