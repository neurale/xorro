class Contact
  attr_reader :id, :ip, :port, :last_seen
  attr_accessor :active

  def initialize(options)    ### {id: '2342342', ip: '23.24.55.8', port: 80}
    @id = options[:id]
    @ip = options[:ip] || 'localhost'
    @port = options[:port] || 80
    @last_seen = Time.now
    @active = nil
  end

  def update_last_seen
    @last_seen = Time.now
  end
end