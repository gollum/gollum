#This class exists to get access to the ssh session factory. 
class DummySSHTransport
  attr_accessor :dummy_factory
  def setSshSessionFactory(dummy_factory)
    @dummy_factory = dummy_factory
  end
end
